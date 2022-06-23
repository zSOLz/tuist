import ArgumentParser
import Foundation
import TSCBasic

/// A command to fetch any remote content necessary to interact with the project.
struct FetchCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "fetch",
            abstract: "Fetches any remote content necessary to interact with the project."
        )
    }

    @Option(
        name: .shortAndLong,
        help: "The path to the directory that contains the definition of the project.",
        completion: .directory
    )
    var path: String?

    @Flag(
        name: .shortAndLong,
        help: "Instead of simple fetch, update external content when available."
    )
    var update: Bool = false

    @Flag(
        name: .long,
        help: "Fetch only plugins."
    )
    var pluginsOnly: Bool = false

    func run() async throws {
        try await FetchService().run(
            path: path,
            update: update,
            pluginsOnly: pluginsOnly
        )
    }
}
