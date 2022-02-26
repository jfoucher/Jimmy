//
//MIT License
//
//Copyright (c) 2020 Guille Gonzalez
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Foundation

import SwiftUI
import Cocoa

final class TextSizeViewModel: ObservableObject {
  @Published var textSize: CGSize?

  func didUpdateTextView(_ textView: AttributedTextImpl.TextView) {
    textSize = textView.intrinsicContentSize
  }
    

}

struct AttributedTextImpl {
    var attributedText: NSAttributedString
    var maxLayoutWidth: CGFloat
    var textSizeViewModel: TextSizeViewModel
    var onOpenLink: ((URL) -> Void)?
    var onHoverLink: ((URL?, Bool) -> Void)?
    

}

extension AttributedTextImpl: NSViewRepresentable {
    func makeNSView(context: Context) -> TextView {
        let nsView = TextView(frame: .zero)

        nsView.onLinkHover = self.onHoverLink
        nsView.drawsBackground = false
        nsView.textContainerInset = .zero
        nsView.isEditable = false
        nsView.isRichText = false
        nsView.textContainer?.lineFragmentPadding = 0
        // we are setting the container's width manually
        nsView.textContainer?.widthTracksTextView = false
        nsView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: NSColor.controlAccentColor
        ]

        nsView.displaysLinkToolTips = false
        nsView.delegate = context.coordinator
        
        return nsView
    }
    
    func updateNSView(_ nsView: TextView, context: Context) {
        nsView.textStorage?.setAttributedString(attributedText)
        nsView.maxLayoutWidth = maxLayoutWidth
        nsView.onLinkHover = self.onHoverLink
        
        nsView.textContainer?.maximumNumberOfLines = context.environment.lineLimit ?? 0
        nsView.textContainer?.lineBreakMode = NSLineBreakMode(
            truncationMode: context.environment.truncationMode
        )
        context.coordinator.openLink = onOpenLink ?? { context.environment.openURL($0) }
        textSizeViewModel.didUpdateTextView(nsView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension AttributedTextImpl {

    final class TextView: NSTextView {
        var maxLayoutWidth: CGFloat {
            get { textContainer?.containerSize.width ?? 0 }
            set {
                guard textContainer?.containerSize.width != newValue else { return }
                textContainer?.containerSize.width = newValue
                invalidateIntrinsicContentSize()
            }
        }
        
//        override func clicked(onLink link: Any, at charIndex: Int) {
//            print("link clicked")
//        }
        
        var onLinkHover: ((URL?, Bool) -> Void)? = nil


        override func mouseMoved(with event: NSEvent) {
            //super.mouseMoved(with: event)
            
            guard let point = event.window?.convertPoint(toScreen: event.locationInWindow) else { return }
            
            let char = self.characterIndex(for: point)

            guard let storage = self.textStorage else { return }

            
            let wholeRange = NSRange(self.string.startIndex..., in: self.string)
            let attributes = storage.attributes(at: char, effectiveRange: nil)
            
            

            if let url = attributes[.link] as? URL  {
                self.addCursorRect(self.bounds, cursor: .pointingHand)
                storage.enumerateAttribute(.link, in: wholeRange, options: []) { (value, range, pointee) in
                    if let u = value as? URL {
                        
                        if url == u {
                            storage.addAttributes([
                                .underlineStyle: 0x1,
                                .underlineColor: NSColor.controlAccentColor
                            ], range: range)

                            if let onlinkHover = onLinkHover {
                                onlinkHover(u, true)
                            }
                        } else {
                            storage.removeAttribute(.underlineStyle, range: range)
                            storage.removeAttribute(.underlineColor, range: range)
                        }
                    }
                }
                
            } else {
                // not a link
                self.addCursorRect(self.bounds, cursor: .iBeam)
                storage.enumerateAttribute(.link, in: wholeRange, options: []) { (value, range, pointee) in
                        storage.removeAttribute(.underlineStyle, range: range)
                        storage.removeAttribute(.underlineColor, range: range)
                    if let onlinkHover = onLinkHover {
//                        print("unhover")
                        onlinkHover(nil, false)
                    }
                }
            }
        }
        
//        func hoveredLink() -> URL {
//            
//        }

        override func menu(for event: NSEvent) -> NSMenu? {
            print("event", event)
            let menu = super.menu(for: event)
            guard let point = event.window?.convertPoint(toScreen: event.locationInWindow) else { return menu }
            
            let char = self.characterIndex(for: point)

            guard let storage = self.textStorage else { return menu }
            
            let attributes = storage.attributes(at: char, effectiveRange: nil)
            

            if let url = attributes[.link] as? URL  {
                let item = CustomMenuItem(title: "Open Link in New Tab", action: #selector(self.newTab), keyEquivalent: "k")
                
                item.url = url
                
                menu?.insertItem(item, at: 1)
            }
                
            return menu
        }
        @objc func newTab(_ sender: CustomMenuItem) {
            print("nestab yesssss", sender.target, sender.url)
            if let url = sender.url {
                NSWorkspace.shared.open(url)
            }
        }
        override var intrinsicContentSize: NSSize {
            guard maxLayoutWidth > 0,
                  let textContainer = self.textContainer,
                  let layoutManager = self.layoutManager
            else {
                return super.intrinsicContentSize
            }
            
            layoutManager.ensureLayout(for: textContainer)
            return layoutManager.usedRect(for: textContainer).size
        }
        
        
        
    }
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        var openLink: ((URL) -> Void)?
        
        func textView(_: NSTextView, clickedOnLink link: Any, at _: Int) -> Bool {
            print("something in the view")
            guard let openLink = self.openLink,
                  let url = (link as? URL) ?? (link as? String).flatMap(URL.init(string:))
            else {
                return false
            }
            
            openLink(url)
            return true
        }
    
    }
    

}

class CustomMenuItem: NSMenuItem {
  var url: URL?
}

extension NSLineBreakMode {
  init(truncationMode: Text.TruncationMode) {
    switch truncationMode {
    case .head:
      self = .byTruncatingHead
    case .tail:
      self = .byTruncatingTail
    case .middle:
      self = .byTruncatingMiddle
    @unknown default:
      self = .byWordWrapping
    }
  }
}
