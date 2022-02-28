//
//  jimmyApp.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//

import SwiftUI
import Foundation


@main
struct jimmyApp: App {
    let bookmarks = Bookmarks()
    let history = History()
    let certificates = IgnoredCertificates()
    let actions = Actions()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarks)
                .environmentObject(history)
                .environmentObject(certificates)
                .environmentObject(actions)
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                
                
        }
        .handlesExternalEvents(matching: ["*"])
        .windowStyle(.titleBar)
    
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands(content: {
            CommandGroup(replacing: .newItem) {
                CommandsView().environmentObject(actions)
                
            }
        })
    }
}
