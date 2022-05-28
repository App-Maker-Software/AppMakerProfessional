//
//  Solar2DRunner.swift
//

import Foundation
#if MAIN_APP
import AppMakerCore
#elseif COMPANION
import AppMakerCompanionCore
#endif
import SwiftUI

final class Solar2DRunner: AppMakerBuildProductRunnerImplementation {
    let logger: RunnerLogger
    let _buildProduct: GeneratedHiddenFolderOfflineBuildProduct
    var buildProduct: AnyBuildProduct { _buildProduct }
    let sendAction: (BuildProductRunnerAction) -> Void
    var canRender: Bool {
        true
    }
    init(
        logger: RunnerLogger,
        buildProduct: AnyBuildProduct,
        sendAction: @escaping (BuildProductRunnerAction) -> Void
    ) {
        self.logger = logger
        self._buildProduct = buildProduct as! GeneratedHiddenFolderOfflineBuildProduct
        self.sendAction = sendAction
    }
    private func log(_ msg: String, addNewLine: Bool = true) {
        if addNewLine {
            logger.log(msg + "\n")
        } else {
            logger.log(msg)
        }
    }
    func resume() {
        self.sendAction(.render(AnyView(
            SafeSolar2DSwiftUIView(
                coronaSdkFilePath: self._buildProduct.buildProductPath.path
            )
        )))
    }
    func suspend() {
        
    }
    
    func destroyRunner() async {
        
    }
}

