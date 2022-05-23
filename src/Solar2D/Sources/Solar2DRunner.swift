//
//  Solar2DRunner.swift
//

import Foundation
#if MAIN_APP
import AppMakerCore
#elseif COMPANION
import AppMakerCompanionCore
#endif

final class Solar2DRunner: AppMakerBuildProductRunnerImplementation {
    let logger: RunnerLogger
    let buildProduct: SimpleOfflineBuildProduct
    let sendAction: (BuildProductRunnerAction) -> Void
    init(
        logger: RunnerLogger,
        buildProduct: SimpleOfflineBuildProduct,
        sendAction: @escaping (BuildProductRunnerAction) -> Void
    ) {
        self.logger = logger
        self.buildProduct = buildProduct
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
        self.sendAction(.finished(success: true))
    }
    func suspend() {
        
    }
    
    func destroyRunner() async {
        
    }
}

