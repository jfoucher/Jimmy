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
        
        nsView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: NSColor.controlAccentColor
        ]
        nsView.alllinks = []
        
        nsView.textContainer?.maximumNumberOfLines = context.environment.lineLimit ?? 0
        nsView.textContainer?.lineBreakMode = NSLineBreakMode(
            truncationMode: context.environment.truncationMode
        )
        context.coordinator.openLink = onOpenLink ?? { context.environment.openURL($0) }
        textSizeViewModel.didUpdateTextView(nsView)
        //Find green range and scroll to it
        guard let storage = nsView.textStorage else { return }
        let wholeRange = NSRange(nsView.string.startIndex..., in: nsView.string)
        storage.enumerateAttribute(.backgroundColor, in: wholeRange, options: []) { (value, range, pointee) in
            if let v = value as? NSColor {
                if v == NSColor.green {
                    nsView.scrollRangeToVisible(range)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension AttributedTextImpl {
    
    final class TextView: NSTextView {
        var wasHovered: Bool = false
        var maxLayoutWidth: CGFloat {
            get { textContainer?.containerSize.width ?? 0 }
            set {
                guard textContainer?.containerSize.width != newValue else { return }
                textContainer?.containerSize.width = newValue
                invalidateIntrinsicContentSize()
            }
        }
        
        func hoveringLink(url: URL?, hovered: Bool) {
            if let onlinkHover = onLinkHover {
                onlinkHover(url, hovered)
            }
        }
        
        var onLinkHover: ((URL?, Bool) -> Void)? = nil
        
        var alllinks: [AttributedStringLink] = []
        
        override func mouseMoved(with event: NSEvent) {
            //super.mouseMoved(with: event)
            
            guard let point = event.window?.convertPoint(toScreen: event.locationInWindow) else { return }
            
            let char = self.characterIndex(for: point)
            
            guard let storage = self.textStorage else { return }
            
            
            let wholeRange = NSRange(self.string.startIndex..., in: self.string)
            let attributes = storage.attributes(at: char, effectiveRange: nil)
            
            var hoveredUrl: URL? = nil
            
            if let url = attributes[.link] as? URL  {
                wasHovered = true
                self.addCursorRect(self.bounds, cursor: .pointingHand)
                storage.enumerateAttribute(.link, in: wholeRange, options: []) { (value, range, pointee) in
                    if let u = value as? URL {
                        
                        if url == u && range.contains(char) {
                            // Hovering this link
                            hoveredUrl = url
                            
                            //                            storage.removeAttribute(.link, range: range)
                            self.linkTextAttributes = [
                                NSAttributedString.Key.foregroundColor: NSColor.green.blended(withFraction: 0.5, of: NSColor.controlAccentColor) ?? NSColor.green
                            ]
                            
                            storage.addAttribute(.foregroundColor, value: NSColor.green.blended(withFraction: 0.5, of: NSColor.controlAccentColor) ?? NSColor.green, range: range)
                        } else {
                            
                            // not hovering this link
                            storage.removeAttribute(.link, range: range)
                            storage.addAttribute(.foregroundColor, value: NSColor.controlAccentColor, range: range)
                            alllinks.append(AttributedStringLink(url: u, range: range))
                        }
                    }
                }
            } else {
                // not a link
                
                self.linkTextAttributes = [
                    NSAttributedString.Key.foregroundColor: NSColor.controlAccentColor
                ]
                for oldlink in alllinks {
                    storage.addAttribute(.link, value: oldlink.url, range: oldlink.range)
                }
                hoveredUrl = nil
                if wasHovered {
                    self.addCursorRect(self.bounds, cursor: .iBeam)
                    hoveringLink(url: nil, hovered: false)
                    wasHovered = false
                }
            }
            
            if let hu = hoveredUrl {
                self.hoveringLink(url: hu, hovered: true)
            }
        }
        
        override func menu(for event: NSEvent) -> NSMenu? {
            let menu = super.menu(for: event)
            guard let point = event.window?.convertPoint(toScreen: event.locationInWindow) else { return menu }
            
            let char = self.characterIndex(for: point)
            
            guard let storage = self.textStorage else { return menu }
            
            let attributes = storage.attributes(at: char, effectiveRange: nil)
            
            
            if let url = attributes[.link] as? URL  {
                let item = CustomMenuItem(title: String(localized: "Open Link in New Tab"), action: #selector(self.newTab), keyEquivalent: "")
                
                item.url = url
                
                menu?.insertItem(item, at: 1)
            }
            
            return menu
        }
        @objc func newTab(_ sender: CustomMenuItem) {
            if let url = sender.url {
                self.linkTextAttributes = [
                    NSAttributedString.Key.foregroundColor: NSColor.controlAccentColor
                ]
                self.alllinks = []
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
            guard let openLink = self.openLink,
                  let url = (link as? URL) ?? (link as? String).flatMap(URL.init(string:))
            else {
                return false
            }
            
            if let scheme = url.scheme {
                if scheme == "gemini" {
                    openLink(url)
                } else {
                    NSWorkspace.shared.open(url)
                }
            }
            
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


struct AttributedStringLink {
    var url: URL
    var range: NSRange
}
