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
    var isSuspended = true
    var allDelegates: [WeakSolar2DSwiftUIViewDelegate] = []
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
        self.isSuspended = false
        self.sendAction(.render(
            .init(
                makeSimulatorRendererDelegate: {
                    Solar2DSwiftUIViewDelegate(solar2DRunner: self, instanceId: $0)
                },
                makeSimulatorRenderer: {
                    SafeSolar2DSwiftUIView(
                        delegate: $0 as! Solar2DSwiftUIViewDelegate
                    )
                }
            )
        ))
    }
    func suspend() {
        self.isSuspended = true
        for delegate in allDelegates {
            if let delegate: Solar2DSwiftUIViewDelegate = delegate.value, delegate.isFocused {
                delegate.suspend()
            }
        }
    }
    
    func destroyRunner() async {
        self.suspend()
    }
    
    final class WeakSolar2DSwiftUIViewDelegate {
        weak var value: Solar2DSwiftUIViewDelegate?
        init(delegate: Solar2DSwiftUIViewDelegate) {
            self.value = delegate
        }
    }
}

