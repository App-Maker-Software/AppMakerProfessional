//
//  Solar2DSwiftUIView.swift
//

import Foundation
import SwiftUI


struct SafeSolar2DSwiftUIView: View {
    let coronaSdkFilePath: String
    init(coronaSdkFilePath: String) {
        self.coronaSdkFilePath = coronaSdkFilePath
    }
    
    var body: some View {
        Solar2DSwiftUIViewBody(delegate: Solar2DSwiftUIViewDelegate(
            coronaSdkFilePath: coronaSdkFilePath
        ))
    }
}

fileprivate struct Solar2DSwiftUIViewBody: View {
    @ObservedObject var delegate: Solar2DSwiftUIViewDelegate
    
    init(delegate: Solar2DSwiftUIViewDelegate) {
        self._delegate = .init(wrappedValue: delegate)
    }
    
    var body: some View {
        GeometryReader { geo in
            delegate.view.onChange(of: geo.size) { (newSize: CGSize) in
                delegate.width = newSize.width
                delegate.height = newSize.height
            }.onAppear {
                delegate.width = geo.size.width
                delegate.height = geo.size.height
            }
        }
    }
}
fileprivate final class Solar2DSwiftUIViewDelegate: NSObject, ObservableObject, CoronaViewDelegate {
    let id = UUID().uuidString
    func coronaViewDidResume(_ view: CoronaView!) {}
    func coronaViewWillSuspend(_ view: CoronaView!) {}
    func coronaView(_ view: CoronaView!, receiveEvent event: [AnyHashable : Any]!) -> Any! {
        return true
    }
    
    let coronaSdkFilePath: String
    @Published private var isRunning = true
    @Published var width: CGFloat = 200
    @Published var height: CGFloat = 200
    
    init(coronaSdkFilePath: String) {
        self.coronaSdkFilePath = coronaSdkFilePath
    }
    
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
    }
    func kill() {
        guard isRunning else { return }
        isRunning = false
    }
    
    var view: LiveSolar2DView {
        .init(delegate: self)
    }
    
    struct LiveSolar2DView: View {
        @ObservedObject fileprivate var delegate: Solar2DSwiftUIViewDelegate
        
        var body: some View {
            if delegate.isRunning {
                Solar2DSwiftUIView(delegate: delegate)
                    .frame(width: delegate.width, height: delegate.height)
                    .animation(nil, value: delegate.width)
                    .animation(nil, value: delegate.height)
            }
        }
    }
}


fileprivate struct Solar2DSwiftUIView: UIViewControllerRepresentable {
    let delegate: Solar2DSwiftUIViewDelegate
    func makeUIViewController(context: Context) -> CoronaViewController {
        let coronaController = CoronaViewController()
        let coronaView = (coronaController.view as! CoronaView)
        coronaView.backgroundColor = .clear
        coronaView.isOpaque = false
//        coronaView.frame = .init(x: 0, y: 0, width: sW, height: sH)
        coronaView.coronaViewDelegate = delegate
        coronaView.run(withPath: delegate.coronaSdkFilePath, parameters: [
            :
//            "contentWidth":sW,
//            "contentHeight":sH
        ])
        
        return coronaController
    }
    
    func updateUIViewController(_ uiViewController: CoronaViewController, context: Context) {}
    
    typealias UIViewControllerType = CoronaViewController
}
