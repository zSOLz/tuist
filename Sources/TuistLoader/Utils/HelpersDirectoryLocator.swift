import Foundation
import TSCBasic
import TuistCore
import TuistSupport

public protocol HelpersDirectoryLocating {
    /// Returns the path to the helpers directory if it exists.
    /// - Parameter at: Path from which we traverse the hierarchy to obtain the helpers directory.
    func locate(at: AbsolutePath) -> AbsolutePath?
}

public final class HelpersDirectoryLocator: HelpersDirectoryLocating {
    /// Instance to locate the root directory of the project.
    let rootDirectoryLocator: RootDirectoryLocating

    /// Default constructor.
    public convenience init() {
        self.init(rootDirectoryLocator: RootDirectoryLocator())
    }

    /// Initializes the locator with its dependencies.
    /// - Parameter rootDirectoryLocator: Instance to locate the root directory of the project.
    init(rootDirectoryLocator: RootDirectoryLocating) {
        self.rootDirectoryLocator = rootDirectoryLocator
    }

    // MARK: - HelpersDirectoryLocating

    public func locate(at: AbsolutePath) -> AbsolutePath? {
        guard let rootDirectory = rootDirectoryLocator.locate(from: at) else { return nil }
        let helpersDirectory = rootDirectory
            .appending(component: Constants.tuistDirectoryName)
            .appending(component: Constants.helpersDirectoryName)

        if !FileHandler.shared.exists(helpersDirectory) {
            let tuistDirectory = rootDirectory
                .appending(component: Constants.tuistDirectoryName)

            if FileHandler.shared.exists(tuistDirectory) {
                let parentDirectory = at.removingLastComponent()
                return locate(at: parentDirectory)
            }

            return nil
        }
        return helpersDirectory
    }
}
