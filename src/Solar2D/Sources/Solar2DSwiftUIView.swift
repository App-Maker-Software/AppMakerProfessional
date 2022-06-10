//
//  Solar2DSwiftUIView.swift
//

import Foundation
import SwiftUI
#if MAIN_APP
import AppMakerCore
#elseif COMPANION
import AppMakerCompanionCore
#endif


struct SafeSolar2DSwiftUIView: View, SimulatorRenderer {
    let delegate: Solar2DSwiftUIViewDelegate
    
    var body: some View {
        Solar2DSwiftUIViewBody(delegate: delegate)
    }
    
    private struct Solar2DSwiftUIViewBody: View {
        @ObservedObject var delegate: Solar2DSwiftUIViewDelegate
        
        init(delegate: Solar2DSwiftUIViewDelegate) {
            self._delegate = .init(wrappedValue: delegate)
        }
        
        var body: some View {
            GeometryReader { geo in
                let _: Void = {
                    if delegate.containingSize == nil {
                        delegate.setNewContainingSize(size: geo.size)
                    }
                }()
                delegate.view.onChange(of: geo.size) { (newSize: CGSize) in
                    delegate.setNewContainingSize(size: newSize)
                }
            }
        }
    }
}
final class Solar2DSwiftUIViewDelegate: NSObject, ObservableObject, CoronaViewDelegate, SimulatorRendererDelegate {
    let instanceId: UUID
    var isFocused: Bool = false
    func onFocus() {
        self.isFocused = true
        if self.solar2DRunner.isSuspended == false {
            if self.solar2DRunner.isSuspended {
                if self.isRunning {
                    self.suspend()
                }
            } else {
                if !self.isRunning {
                    self.run()
                }
            }
        }
    }
    
    func onUnfocus() {
        self.isFocused = false
        self.suspend()
    }
    
    func coronaViewDidResume(_ view: CoronaView!) {}
    func coronaViewWillSuspend(_ view: CoronaView!) {}
    func coronaView(_ view: CoronaView!, receiveEvent event: [AnyHashable : Any]!) -> Any! {
        guard let eventName = event["eventName"] as? String,
              let args = event["args"] as? Dictionary<AnyHashable, Any>,
              let isForAppMaker: Bool = event["isForAppMaker"] as? Bool, isForAppMaker else {
            return nil
        }
        switch eventName {
        case "print":
            var strings: [String] = []
            var i = 1
            while let nextString: String = args[i] as? String {
                strings.append(nextString)
                i += 1
            }
            let finalString = strings.joined(separator: "\t")
            self.solar2DRunner.logger.log(finalString + "\n")
            return nil
        case "error":
            let rawErrorStr: String = (args["message"] as? String) ?? "Unknown error"
            let correctedPathStringsErrorStr = self.solar2DRunner._buildProduct.fixPathStrings(in: rawErrorStr)
            let nameRemappings: [(String, String)] = [
                ("_original_main.lua", "main.lua")
            ]
            var errorStr = correctedPathStringsErrorStr
            for nameRemapping in nameRemappings {
                errorStr = errorStr.replacingOccurrences(
                    of: nameRemapping.0,
                    with: nameRemapping.1
                )
            }
            self.solar2DRunner.logger.log("❌: " + errorStr + "\n")
            return nil
        case "configLuaDetails":
            self.configLuaInfo = .init(args: args)
            if let containingSize = self.containingSize {
                self.setNewContainingSize(size: containingSize)
            }
            return nil
        default:
            return nil
        }
    }
    fileprivate weak var coronaView: CoronaView?
    let solar2DRunner: Solar2DRunner
    let coronaSdkFilePath: String
    fileprivate var hasSetup = false
    fileprivate private(set) var isRunning = true
    @Published fileprivate private(set) var containingSize: CGSize? = nil
    func setNewContainingSize(size containingSize: CGSize) {
        self.containingSize = containingSize
        if let configLuaInfo = self.configLuaInfo,
           let original_actualContentWidth = configLuaInfo.original_actualContentWidth,
           let original_actualContentHeight = configLuaInfo.original_actualContentHeight {
            self.sendToCoronaView(message: .containingWindowNewSize(
                containingSize: containingSize,
                originalActualContentSize: .init(width: original_actualContentWidth, height: original_actualContentHeight),
                desiredSize: configLuaInfo.desiredSize,
                screenEdgeInsets: (0, 0, 0, 0),
                statusBarHeight: 0,
                scaleMode: configLuaInfo.scale
            ))
        }
    }
    private var configLuaInfo: ConfigLuaInfo?
    
    init(solar2DRunner: Solar2DRunner, instanceId: UUID) {
        self.instanceId = instanceId
        self.isRunning = !solar2DRunner.isSuspended
        self.solar2DRunner = solar2DRunner
        self.coronaSdkFilePath = solar2DRunner._buildProduct.buildProductPath.path
        super.init()
        func cleanUpOldDelegates() {
            for (i, el) in solar2DRunner.allDelegates.enumerated() {
                if el.value == nil {
                    solar2DRunner.allDelegates.remove(at: i)
                    return cleanUpOldDelegates()
                }
            }
        }
        cleanUpOldDelegates()
        solar2DRunner.allDelegates.append(.init(delegate: self))
    }
    
    
    var view: LiveSolar2DView {
        .init(delegate: self)
    }
    
    struct LiveSolar2DView: View {
        @ObservedObject fileprivate var delegate: Solar2DSwiftUIViewDelegate
        
        var body: some View {
            ZStack {
                Solar2DSwiftUIView(delegate: delegate)
                if !delegate.isRunning {
                    Color.black.opacity(0.5)
                    ProgressView()
                }
            }
            .frame(
                width: delegate.containingSize?.width,
                height: delegate.containingSize?.height
            )
            .animation(nil, value: delegate.containingSize)
        }
    }
    
    private func sendToCoronaView(message: MessagesToCoronaView) {
        var encoded = message.encoded
        encoded["name"] = "appMaker"
        self.sendToCoronaViewRaw(encoded)
    }
    private func sendToCoronaViewRaw(_ dict: [AnyHashable : Any]) {
        if let coronaView = coronaView {
            coronaView.sendEvent(dict)
        }
    }
    
    enum MessagesToCoronaView {
        case containingWindowNewSize(
            containingSize: CGSize,
            originalActualContentSize: CGSize,
            desiredSize: CGSize?,
            screenEdgeInsets: (insetT: CGFloat, insetL: CGFloat, insetB: CGFloat, insetR: CGFloat),
            statusBarHeight: CGFloat,
            scaleMode: ConfigLuaInfo.ScaleMode
        )
        
        var encoded: [AnyHashable : Any] {
            switch self {
            case .containingWindowNewSize(
                let containingSize,
                let originalActualContentSize,
                let desiredSize,
                let screenEdgeInsets,
                let statusBarHeight,
                let scaleMode
            ):
                let actualContentWidth: CGFloat
                let actualContentHeight: CGFloat
                let contentWidth: CGFloat
                let contentHeight: CGFloat
                let contentScaleX: CGFloat
                let contentScaleY: CGFloat
                let pixelWidth: CGFloat
                let pixelHeight: CGFloat
                let topStatusBarContentHeight: CGFloat
                let bottomStatusBarContentHeight: CGFloat
                
                let insetT: CGFloat = screenEdgeInsets.insetT
                let insetL: CGFloat = screenEdgeInsets.insetL
                let insetB: CGFloat = screenEdgeInsets.insetB
                let insetR: CGFloat = screenEdgeInsets.insetR
                
                let _hackOffsetX: CGFloat
                let _hackOffsetY: CGFloat
                let _hackScaleX: CGFloat
                let _hackScaleY: CGFloat
                
                switch scaleMode {
                case .adaptive, .none:
                    actualContentWidth = containingSize.width
                    actualContentHeight = containingSize.height
                    contentWidth = containingSize.width
                    contentHeight = containingSize.height
                    contentScaleX = 1 // todo
                    contentScaleY = 1 // todo
                    topStatusBarContentHeight = statusBarHeight
                    bottomStatusBarContentHeight = 0
                    _hackOffsetX = 0
                    _hackOffsetY = 0
                    _hackScaleX = originalActualContentSize.width / actualContentWidth
                    _hackScaleY = originalActualContentSize.height / actualContentHeight
                case .letterbox, .zoomEven:
                    guard let desiredSize: CGSize = desiredSize else {
                        return [:]
                    }
                    contentWidth = desiredSize.width
                    contentHeight = desiredSize.height
                    contentScaleX = 1 // todo
                    contentScaleY = 1 // todo
                    topStatusBarContentHeight = statusBarHeight
                    bottomStatusBarContentHeight = 0
                    let evenScaleX = containingSize.width / contentWidth
                    let evenScaleY = containingSize.height / contentHeight
                    let diffScaleX: CGFloat
                    let diffScaleY: CGFloat
                    let xShouldBeFlush: Bool
                    if case .zoomEven = scaleMode {
                        xShouldBeFlush = evenScaleX > evenScaleY
                    } else {
                        xShouldBeFlush = evenScaleX < evenScaleY
                    }
                    if xShouldBeFlush {
                        // x will be flush
                        diffScaleX = evenScaleX
                        diffScaleY = evenScaleX
                        actualContentWidth = desiredSize.width
                        actualContentHeight = containingSize.height / evenScaleX
                        _hackOffsetX = 0
                        _hackOffsetY = (actualContentHeight - contentHeight) * 0.5
                    } else {
                        // y will be flush
                        diffScaleX = evenScaleY
                        diffScaleY = evenScaleY
                        actualContentHeight = desiredSize.height
                        actualContentWidth = containingSize.width / evenScaleY
                        _hackOffsetX = (actualContentWidth - contentWidth) * 0.5
                        _hackOffsetY = 0
                    }
                    _hackScaleX = diffScaleX * originalActualContentSize.width / containingSize.width
                    _hackScaleY = diffScaleY * originalActualContentSize.height / containingSize.height
                case .zoomStretch:
                    guard let desiredSize: CGSize = desiredSize else {
                        return [:]
                    }
                    actualContentWidth = desiredSize.width
                    actualContentHeight = desiredSize.height
                    contentWidth = desiredSize.width
                    contentHeight = desiredSize.height
                    contentScaleX = 1 // todo
                    contentScaleY = 1 // todo
                    topStatusBarContentHeight = statusBarHeight
                    bottomStatusBarContentHeight = 0
                    _hackOffsetX = 0
                    _hackOffsetY = 0
                    _hackScaleX = originalActualContentSize.width / actualContentWidth
                    _hackScaleY = originalActualContentSize.height / actualContentHeight
                }
                pixelWidth = containingSize.width
                pixelHeight = containingSize.height
                
                
                return [
                    "eventName": "containingWindowNewSize",
                    "actualContentWidth": actualContentWidth,
                    "actualContentHeight": actualContentHeight,
                    "contentWidth": contentWidth,
                    "contentHeight": contentHeight,
                    "pixelWidth": pixelWidth,
                    "pixelHeight": pixelHeight,
                    "topStatusBarContentHeight": topStatusBarContentHeight,
                    "bottomStatusBarContentHeight": bottomStatusBarContentHeight,
                    "insetT": insetT,
                    "insetL": insetL,
                    "insetB": insetB,
                    "insetR": insetR,
                    "_hackOffsetX": _hackOffsetX,
                    "_hackOffsetY": _hackOffsetY,
                    "_hackScaleX": _hackScaleX,
                    "_hackScaleY": _hackScaleY,
                    "contentScaleX": contentScaleX,
                    "contentScaleY": contentScaleY
                ]
            }
        }
    }
    
    func run() {
        guard !isRunning else { return }
        isRunning = true
        if let coronaView = coronaView {
            if self.hasSetup {
                coronaView.resume()
            } else {
                coronaView.setup(for: self)
                self.hasSetup = true
            }
        }
    }
    
    func suspend() {
        guard isRunning else { return }
        if let coronaView = coronaView {
            coronaView.suspend()
        }
        self.isRunning = false
    }
    
    deinit {
        self.suspend()
    }
}


fileprivate struct Solar2DSwiftUIView: UIViewControllerRepresentable {
    let delegate: Solar2DSwiftUIViewDelegate
    func makeUIViewController(context: Context) -> CoronaViewController {
        let coronaController = CoronaViewController()
        let coronaView = (coronaController.view as! CoronaView)
        coronaView.backgroundColor = .clear
        coronaView.isOpaque = false
        delegate.coronaView = coronaView
        coronaView.coronaViewDelegate = delegate
        if delegate.isRunning {
            coronaView.setup(for: delegate)
            delegate.hasSetup = true
        }
        return coronaController
    }
    
    func updateUIViewController(_ uiViewController: CoronaViewController, context: Context) {}
    
    typealias UIViewControllerType = CoronaViewController
}

extension CoronaView {
    func setup(for delegate: Solar2DSwiftUIViewDelegate) {
        self.run(withPath: delegate.coronaSdkFilePath, parameters: [
            :
    //            "contentWidth":sW,
    //            "contentHeight":sH
        ])
    }
}
