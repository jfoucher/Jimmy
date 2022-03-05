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

import SwiftUI

/// A view that displays styled attributed text.
public struct AttributedText: View {
    @StateObject var textSizeViewModel = TextSizeViewModel()
    @Binding var scrollPos: Double?
    
    private let attributedText: NSAttributedString
    private let onOpenLink: ((URL) -> Void)?
    private let onHoverLink: ((URL?, Bool) -> Void)?
    
    /// Creates an attributed text view.
    /// - Parameters:
    ///   - attributedText: An attributed string to display.
    ///   - onOpenLink: The action to perform when the user opens a link in the text. When not specified,
    ///                 the  view opens the links using the `OpenURLAction` from the environment.
    public init(_ attributedText: NSAttributedString, onOpenLink: ((URL) -> Void)? = nil, onHoverLink: ((URL?, Bool) -> Void)? = nil, scrollPos: Binding<Double?> = Binding<Double?>(get: {nil }, set: {v in })) {
        self.attributedText = attributedText
        self.onOpenLink = onOpenLink
        self.onHoverLink = onHoverLink
        self._scrollPos = scrollPos
    }
    
    
    public var body: some View {
        GeometryReader { geometry in
            AttributedTextImpl(
                attributedText: attributedText,
                maxLayoutWidth: geometry.maxWidth,
                textSizeViewModel: textSizeViewModel,
                onOpenLink: onOpenLink,
                onHoverLink: onHoverLink,
                scrollPosition: $scrollPos
            )
        }
        .frame(
            idealWidth: textSizeViewModel.textSize?.width,
            idealHeight: textSizeViewModel.textSize?.height
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension GeometryProxy {
    fileprivate var maxWidth: CGFloat {
        size.width - safeAreaInsets.leading - safeAreaInsets.trailing
    }
}
