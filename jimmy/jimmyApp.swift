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
    let history = History()
    let certificates = IgnoredCertificates()
    let store = UserDefaults()


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookmarks)
                .environmentObject(history)
                .environmentObject(certificates)
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                .onOpenURL(perform: {url in
                    print(url)
                })
                .onDisappear(perform: {
                    print("disappearing", getCurrentWindows().count)
                    DispatchQueue.main.async {
                        let w = getCurrentWindows()
                        if w.count == 1 && (w.first!.tabGroup == nil || w.first!.tabGroup?.isTabBarVisible == false) {
                            w.first!.toggleTabBar(self)
                        }
                            
                        
                    }
                })
                .onAppear(perform: {
                    print("appearing")
                    DispatchQueue.main.async {
                        guard let firstWindow = NSApp.windows.first(where: { win in
                            return NSStringFromClass(type(of: win)) == "SwiftUI.SwiftUIWindow"
                        }) else { return }

                        //firstWindow.makeKeyAndOrderFront(nil)
                        var group = firstWindow
                        if let g = firstWindow.tabGroup?.selectedWindow {
                            group = g
                        }
                        let w = getCurrentWindows()
                        print(w.count)
                        print(w.first?.tabGroup?.isTabBarVisible)
                        if w.count == 1 && (w.first!.tabGroup == nil || w.first!.tabGroup?.isTabBarVisible == false) {
                            
                            w.first!.toggleTabBar(self)
                        } else if w.count > 1 && NSApp.keyWindow?.tabGroup?.isTabBarVisible == true {
                            NSApp.keyWindow?.toggleTabBar(self)
                        }

                        var lastWindow = NSApp.windows.first(where: {win in
                            return win.tabbedWindows?.count == nil && NSStringFromClass(type(of: win)) == "SwiftUI.SwiftUIWindow" && win != group
                        })

                        NSApp.windows.forEach({win in
                            let className = NSStringFromClass(type(of: win))
                            if win != firstWindow && className == "SwiftUI.SwiftUIWindow" && win.tabbedWindows?.count == nil {
                                print("adding window", win)

                                group.addTabbedWindow(win, ordered: .above)
                            }
                        })

                        if let last = lastWindow {
                            last.makeKeyAndOrderFront(nil)
                        }

                    }
                })
                
        }
        .handlesExternalEvents(matching: ["*"])
        .windowStyle(.titleBar)
    
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands(content: {
            CommandGroup(replacing: .newItem) {
                CommandsView()
                
            }
        })
        .defaultAppStorage(Store())
            
    }
    

    func getCurrentWindows() -> [NSWindow] {
        return NSApp.windows.filter{ NSStringFromClass(type(of: $0)) == "SwiftUI.SwiftUIWindow" }
    }

}

class Store: UserDefaults {
    override func set(_ value: Int, forKey defaultName: String) {
    }
}
