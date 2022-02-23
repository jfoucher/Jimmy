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
    
    let tabs = TabList()
    let bookmarks = Bookmarks()
    let store = UserDefaults()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarks)
                
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                .onOpenURL { (url) in
                    print("opening", url)
                    //newTab(url)
                    
                }
                .handlesExternalEvents(preferring: ["main"], allowing: ["*"])
                
        }
        
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands(content: {
            CommandGroup(replacing: .newItem) {
                //Button("New Tab") { newTab(URL(string: "gemini://about")!) }.keyboardShortcut("t")
                Divider()
            }
        })
        .defaultAppStorage(Store())
        
        
        
        
//        Settings {
//            VStack {
//                Text("My Settingsview")
//                Text("My Settingsview")
//                Text("My Settingsview")
//                Text("My Settingsview")
//            }.padding()
//        }
            
    }

}

class Store: UserDefaults {
    override func set(_ value: Int, forKey defaultName: String) {
    }
}
