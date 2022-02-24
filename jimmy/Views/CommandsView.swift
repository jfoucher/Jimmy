//
//  CommandsView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 23/02/2022.
//

import SwiftUI

struct CommandsView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var actions: Actions
    var body: some View {
        Button("New Tab") { openURL(URL(string: "gemini://about")!) }.keyboardShortcut("t")
        Divider()
        Button("Reload") {
            actions.reload += 1
        }.keyboardShortcut("r")

    }
}
