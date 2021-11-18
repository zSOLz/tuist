import Foundation
import TSCBasic
import TuistCore
import TuistGraph
import TuistLoader
import XcodeProj
import XCTest
import TuistPluginTesting
@testable import TuistCoreTesting
@testable import TuistKit
@testable import TuistLoaderTesting
@testable import TuistSupportTesting

private typealias GeneratorParameters = (sources: Set<String>, xcframeworks: Bool, cacheProfile: TuistGraph.Cache.Profile, ignoreCache: Bool)

final class FocusServiceTests: TuistUnitTestCase {
    private var subject: FocusService!
    private var opener: MockOpener!
    private var generator: MockGenerator!
    private var generatorFactory: MockGeneratorFactory!
    private var configLoader: MockConfigLoader!
    private var manifestLoader: MockManifestLoader!
    private var pluginService: MockPluginService!
    private var manifestGraphLoader: MockManifestGraphLoader!

    override func setUp() {
        super.setUp()
        opener = MockOpener()
        generator = MockGenerator()
        generatorFactory = MockGeneratorFactory()
        generatorFactory.stubbedFocusResult = generator
        configLoader = MockConfigLoader()
        manifestLoader = MockManifestLoader()
        pluginService = MockPluginService()
        manifestGraphLoader = MockManifestGraphLoader()
        subject = FocusService(
            configLoader: configLoader,
            manifestLoader: manifestLoader,
            opener: opener,
            generatorFactory: generatorFactory,
            pluginService: pluginService,
            manifestGraphLoader: manifestGraphLoader
        )
    }

    override func tearDown() {
        opener = nil
        generator = nil
        subject = nil
        generatorFactory = nil
        configLoader = nil
        manifestLoader = nil
        pluginService = nil
        manifestGraphLoader = nil
        super.tearDown()
    }

    func test_run_fatalErrors_when_theworkspaceGenerationFails() throws {
        let error = NSError.test()
        generator.generateStub = { _, _ in
            throw error
        }

        XCTAssertThrowsError(try subject.run(path: nil, sources: ["Target"], noOpen: true, xcframeworks: false, profile: nil, ignoreCache: false)) {
            XCTAssertEqual($0 as NSError?, error)
        }
    }

    func test_run() throws {
        let workspacePath = AbsolutePath("/test.xcworkspace")

        generator.generateStub = { _, _ in
            workspacePath
        }

        try subject.run(path: nil, sources: ["Target"], noOpen: false, xcframeworks: false, profile: nil, ignoreCache: false)

        XCTAssertEqual(opener.openArgs.last?.0, workspacePath.pathString)
    }
}
