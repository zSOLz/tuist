import ArgumentParser
import Foundation
import OpenAPIRuntime
import Path
import TuistAnalytics
import TuistAsyncQueue
import TuistCache
import TuistCore
import TuistServer
import TuistSupport
import XcodeGraph

/// `TrackableCommandInfo` contains the information to report the execution of a command
public struct TrackableCommandInfo {
    let runId: String
    let name: String
    let subcommand: String?
    let commandArguments: [String]
    let durationInMs: Int
    let status: CommandEvent.Status
    let graph: Graph?
    let graphBinaryBuildDuration: TimeInterval?
    let binaryCacheItems: [AbsolutePath: [String: CacheItem]]
    let selectiveTestingCacheItems: [AbsolutePath: [String: CacheItem]]
    let previewId: String?
    let resultBundlePath: AbsolutePath?
    let ranAt: Date
    let buildRunId: String?
}

/// A `TrackableCommand` wraps a `ParsableCommand` and reports its execution to an analytics provider
public class TrackableCommand {
    private var command: ParsableCommand
    private let clock: Clock
    private let commandArguments: [String]
    private let commandEventFactory: CommandEventFactory
    private let asyncQueue: AsyncQueuing
    private let fileHandler: FileHandling

    public init(
        command: ParsableCommand,
        commandArguments: [String],
        clock: Clock = WallClock(),
        commandEventFactory: CommandEventFactory = CommandEventFactory(),
        asyncQueue: AsyncQueuing = AsyncQueue.sharedInstance,
        fileHandler: FileHandling = FileHandler.shared,
    ) {
        self.command = command
        self.commandArguments = commandArguments
        self.clock = clock
        self.commandEventFactory = commandEventFactory
        self.asyncQueue = asyncQueue
        self.fileHandler = fileHandler
    }

    public func run(
        backend: TuistAnalyticsServerBackend?
    ) async throws {
        let timer = clock.startTimer()
        let ranAt = clock.now
        let pathIndex = commandArguments.firstIndex(of: "--path")
        let path: AbsolutePath
        if let pathIndex, commandArguments.endIndex > pathIndex + 1 {
            path = try AbsolutePath(validating: commandArguments[pathIndex + 1], relativeTo: fileHandler.currentPath)
        } else {
            path = fileHandler.currentPath
        }
        let runMetadataStorage = RunMetadataStorage()
        try await RunMetadataStorage.$current.withValue(runMetadataStorage) {
            do {
                if var asyncCommand = command as? AsyncParsableCommand {
                    try await asyncCommand.run()
                } else {
                    try command.run()
                }
                if let backend {
                    try await dispatchCommandEvent(
                        timer: timer,
                        status: .success,
                        runId: runMetadataStorage.runId,
                        path: path,
                        runMetadataStorage: runMetadataStorage,
                        backend: backend,
                        ranAt: ranAt
                    )
                }
            } catch {
                if let backend {
                    try await dispatchCommandEvent(
                        timer: timer,
                        status: .failure("\(error)"),
                        runId: await runMetadataStorage.runId,
                        path: path,
                        runMetadataStorage: runMetadataStorage,
                        backend: backend,
                        ranAt: ranAt
                    )
                }
                throw error
            }
        }
    }

    private func dispatchCommandEvent(
        timer: any ClockTimer,
        status: CommandEvent.Status,
        runId: String,
        path: AbsolutePath,
        runMetadataStorage: RunMetadataStorage,
        backend: TuistAnalyticsServerBackend,
        ranAt _: Date
    ) async throws {
        let durationInSeconds = timer.stop()
        let durationInMs = Int(durationInSeconds * 1000)
        let configuration = type(of: command).configuration
        let (name, subcommand) = extractCommandName(from: configuration)
        let info = await TrackableCommandInfo(
            runId: runId,
            name: name,
            subcommand: subcommand,
            commandArguments: commandArguments,
            durationInMs: durationInMs,
            status: status,
            graph: runMetadataStorage.graph,
            graphBinaryBuildDuration: runMetadataStorage.graphBinaryBuildDuration,
            binaryCacheItems: runMetadataStorage.binaryCacheItems,
            selectiveTestingCacheItems: runMetadataStorage.selectiveTestingCacheItems,
            previewId: runMetadataStorage.previewId,
            resultBundlePath: runMetadataStorage.resultBundlePath,
            ranAt: Date(),
            buildRunId: runMetadataStorage.buildRunId
        )
        let commandEvent = try commandEventFactory.make(
            from: info,
            path: path
        )
        if (command as? TrackableParsableCommand)?.analyticsRequired == true || Environment.current.isCI {
            Logger.current.info("Uploading run metadata...")
            do {
                let serverCommandEvent: ServerCommandEvent = try await backend.send(commandEvent: commandEvent)
                Logger.current
                    .info(
                        "You can view a detailed run report at: \(serverCommandEvent.url.absoluteString)"
                    )
            } catch let error as ClientError {
                Logger.current
                    .warning("Failed to upload run metadata: \(String(describing: error.underlyingError))")
            } catch {
                Logger.current.warning("Failed to upload run metadata: \(String(describing: error))")
            }
        } else {
            try asyncQueue.dispatch(event: commandEvent)
        }
    }

    private func extractCommandName(from configuration: CommandConfiguration) -> (name: String, subcommand: String?) {
        let name: String
        let subcommand: String?
        if let superCommandName = configuration._superCommandName {
            name = superCommandName
            subcommand = configuration.commandName!
        } else {
            name = configuration.commandName!
            subcommand = nil
        }
        return (name, subcommand)
    }
}
