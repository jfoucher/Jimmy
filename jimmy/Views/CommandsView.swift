//
//  CommandsView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 23/02/2022.
//

import SwiftUI

struct CommandsView: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        Button("New Tab") { openURL(URL(string: "gemini://about")!) }.keyboardShortcut("t")
        Divider()
        Button("Reload") {
            guard let firstWindow = NSApp.windows.first(where: { win in
                return NSStringFromClass(type(of: win)) == "SwiftUI.SwiftUIWindow"
            }) else { return }

            //firstWindow.makeKeyAndOrderFront(nil)
            var group = firstWindow
            if let g = firstWindow.tabGroup?.selectedWindow {
                group = g
            }
            
        }.keyboardShortcut("r")

    }
}
