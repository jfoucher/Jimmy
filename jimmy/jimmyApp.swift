//
//  jimmyApp.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//

import SwiftUI
import Network

@main
struct jimmyApp: App {
    let tabs = TabList()
    
    init() {

    }
    

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(tabs)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "{path of URL?}"), allowing: Set(arrayLiteral: "*")) // activate existing window if exists
                .onOpenURL { (url) in
                    let tab = Tab(url: url.absoluteString.replacingOccurrences(of: "gemini://", with: ""));
                    tabs.tabs.append(tab)
                    tabs.activeTab = tab
                    tabs.load()
                } // create new window if doesn't exist
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        
            
    }
    

}
