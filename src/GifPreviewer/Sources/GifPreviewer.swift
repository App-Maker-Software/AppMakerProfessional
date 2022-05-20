//
//  GifPreviewer.swift
//

import Foundation
import AppMakerCore
import SwiftyGif
import Foundation
#if canImport(UIKit)
import UIKit
#else
@preconcurrency import AppKit
#endif
import SwiftUI

func gifpreviewer_main() {
    // install gif project content
    ProjectGifContent.install()
    
    // A basic markdown file previewer
    let gifPreviewer: ContentPreviewer = ContentPreviewer(
        named: "GIF Previewer",
        shortName: "GIF",
        basePriority: 1,
        shouldMakePreview: { validContent, projectContentId in
            if let validFileInfo = validContent as? ProjectFileInfoContent.ValidContent {
                return validFileInfo.fileType.isImage ? .shouldMakePreview : .shouldNotMakePreview
            } else if validContent is ProjectDirectoryContent.ValidContent {
                return .shouldNotMakePreview
            }
            return .notSure
        },
        makePreview: { (liveProjectContent: LiveReadableProjectContent<ProjectGifContent>) in
            switch liveProjectContent.state {
            case .invalid:
                return .cantRenderAPreview
            case .valid(let validImageContent):
                func getPlatImage() -> PlatformImageView {
                    let platImage = SwiftyGif.PlatformImageView(gifImage: validImageContent.gif)
                    platImage.sizeThatFits(.init(width: 300, height: 300))
                    #if os(macOS)
                    platImage.imageScaling = .scaleProportionallyUpOrDown
                    #else
                    platImage.contentMode = .scaleAspectFit
                    #endif
                    return platImage
                }
                return .renderPreview {
                    #if os(macOS)
                    NSImageViewSwiftUI(view: getPlatImage()).padding()
                    #else
                    UIImageViewSwiftUI(view: getPlatImage()).padding()
                    #endif
                }
            @unknown default:
                return .cantRenderAPreview
            }
        }
    )
    try! gifPreviewer.install()
}

public final actor ProjectGifContent: ProjectContent {
    
    public typealias FullStateAction = ProjectGifContentFullStateAction
    
    public static func supportedActions(supportedActions: inout ActionsSupport<ProjectGifContent>) {
        supportedActions.add(handleOnFullStateChange)
    }
    
    func handleOnFullStateChange(
        fullStateChange: ActionWithMetadata<ProjectGifContentFullStateAction>
    ) async throws -> ActionResult {
        switch fullStateChange.action.fullState {
        case .invalid:
            self.state = .invalid
        case .valid(let image):
            self.state = .valid(image as ProjectGif)
        @unknown default:
            self.state = .invalid
        }
        return .propagateToBasisElementsAndAllSuperStructures(
            actionRunnerActionPairs: [.init(
                basis: self.basis.basis,
                action: {
                    fatalError() as! ProjectFileDataContentFullStateAction
                }
            )]
        )
    }
    
    
    public static func supportedActionTransformations(supportedActionTransformation: inout ActionTransformationsSupport<ProjectGifContent>) {
        supportedActionTransformation.add(self.handleBasisChange)
    }
    
    func handleBasisChange(projectDataContent: ProjectFileDataContent, fullState: ActionWithMetadata<ProjectFileDataContentFullStateAction>) async -> ProjectGifContentFullStateAction {
        switch fullState.action.fullState {
        case .invalid:
            return ProjectGifContentFullStateAction(fullState: .invalid)
        case .valid(let fileData):
            if let gif = try? PlatformImage(gifData: fileData.rawData) {
                return ProjectGifContentFullStateAction(
                    fullState: .valid(ProjectGif(gif: gif))
                )
            } else {
                return ProjectGifContentFullStateAction(fullState: .invalid)
            }
        @unknown default:
            return ProjectGifContentFullStateAction(fullState: .invalid)
        }
    }
    
    
    public nonisolated let _projectInfo: _ProjectInfo = .autoAssign()
    
    public typealias ContentID = ProjectGifContentID
    public typealias Basis = SimpleBasis<ProjectFileDataContent>
    public typealias ValidContent = ProjectGif
    
    public nonisolated let projectContentId: ProjectGifContentID
    public nonisolated let basis: SimpleBasis<ProjectFileDataContent>
    public nonisolated let context: ActionRunnerContext
    
    public nonisolated let _stateStorage: StateStorage<ProjectGif>
    
    public init(for id: ProjectGifContentID, from basis: SimpleBasis<ProjectFileDataContent>, context: ActionRunnerContext) async {
        self.projectContentId = id
        self.basis = basis
        self.context = context
        self._stateStorage = .init()
    }
    
    
    
    public var isDestroyed: Bool = false
    public func destroy() async {
        precondition(!self.isDestroyed)
        self.isDestroyed = true
        await self._projectInfo.destroy()
        await self.context.destroy()
    }
    deinit {
        precondition(self.isDestroyed)
    }
}


public struct ProjectGifContentID: ProjectContentID {
    
    public typealias InstantiatedType = ProjectGifContent

    public var basisId: SimpleBasisID<ProjectFileDataContentID>

    public init(path: RawProjectFilePath) {
        self.basisId = .init(id: .init(path: path))
    }
    
    public init?(from anyProjectContentID: AnyProjectContentID) {
        if let rawProjectContentId = anyProjectContentID as? AnyRawProjectContentID {
            self = .init(path: rawProjectContentId.path)
        } else {
            return nil
        }
    }

    public func deterministicHash(into hasher: inout DeterministicHasher) {
        hasher.combine(basisId)
    }

    public init(from decoder: BinaryDecoder) throws {
        self.basisId = try .init(from: decoder)
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try self.basisId.encode(to: encoder)
    }
}

public struct ProjectGifContentFullStateAction: ProjectContentFullStateSyncAction {
    public typealias ValidStateContent = ProjectGif
    
    public init(from decoder: BinaryDecoder) throws {
        fatalError()
    }
    
    public func encode(to encoder: BinaryEncoder) throws {
        fatalError()
    }
    
    public static var actionTypeId: ActionTypeID = .autoAssignId(for: Self.self)
    public typealias AssociatedRunner = ProjectGifContent
    
    public let fullState: ProjectContentFullState<ProjectGif>
    
    internal init(fullState: ProjectContentFullState<ProjectGif>) {
        self.fullState = fullState
    }
    
    public init(from projectContent: ProjectGifContent) async {
        switch projectContent.state {
        case .invalid:
            self.fullState = .invalid
        case .valid(let image):
            self.fullState = .valid(image)
        @unknown default:
            self.fullState = .invalid
        }
    }
}

public struct ProjectGif: ProjectContentFullValidState, DeterministicHashable {
    public typealias AssociatedProjectContent = ProjectGifContent
    
    public func deterministicHash(into hasher: inout DeterministicHasher) {
        preconditionFailure()
    }
    
    #if canImport(UIKit)
    public let gif: UIImage
    #else
    public let gif: NSImage
    #endif
}

#if os(macOS)
fileprivate struct NSImageViewSwiftUI: NSViewRepresentable {
    let view: NSImageView
    func makeNSView(context: Context) -> NSImageView {
        return view
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
    }
    
    typealias NSViewType = NSImageView
    
    
}
#elseif os(iOS)
fileprivate struct UIImageViewSwiftUI: UIViewRepresentable {
    let view: UIImageView
    func makeUIView(context: Context) -> UIImageView {
        return view
    }
    
    func updateUIView(_ nsView: UIImageView, context: Context) {
    }
    
    typealias UIViewType = UIImageView
}
#endif



