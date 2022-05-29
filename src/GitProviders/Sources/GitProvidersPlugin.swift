//
//  GitProvidersPlugin.swift
//
//

#if MAIN_APP
import Foundation
import AppMakerCore
import GitClient
import GitProviders
import KeychainAccess

private let gitProviderStore = GitProviderStore(with: Keychain())

func gitproviders_main() {
    let gitProviders = SourceControl(
        named: "Git Providers",
        infoURL: "https://github.com/App-Maker-Software/GitProviders",
        buildCloneUI: { onCloseModal in
            GitCloneOptionsView(
                gitProviderStore: gitProviderStore,
                appName: "App Maker Professional",
                closeModal: onCloseModal
            )
        }
    )
    gitProviders.licenseInformation = [
        "SwiftGit2 (c) SwiftGit2 contributors, MIT license", // https://github.com/SwiftGit2/SwiftGit2/blob/master/LICENSE.md
        "Zip (c) Roy Marmelstein contributors, MIT license", // https://github.com/marmelroy/Zip/blob/master/LICENSE
        "Git Providers (c) App Maker Software LLC contributors, MIT license", // https://github.com/App-Maker-Software/GitProviders
    ]
    try! gitProviders.install()
}
#endif
