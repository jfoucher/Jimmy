//
//  ContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var tab: Tab = Tab(url: URL(string: "gemini://about")!)
    @EnvironmentObject var bookmarks: Bookmarks
    @EnvironmentObject var actions: Actions
    @EnvironmentObject var history: History
    @State var showPopover = false
    @State private var old = 0
    @State private var rotation = 0.0


    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                TabContentWrapperView(tab: tab)
            }
            .onReceive(Just(actions.reload)) { val in
                //tab.load()
                if old != val {
                    old = val
                    DispatchQueue.main.async{
                        tab.load()
                    }
                }
                
            }
            .navigationTitle(tab.emojis.emoji(tab.url.host ?? "") + " " + (tab.url.host?.idnaDecoded ?? ""))
            
            .frame(maxWidth: .infinity, minHeight: 200)
            .toolbar{
                urlToolBarContent(geometry)
            }
            
            .onOpenURL(perform: { url in
                tab.url = url
                tab.load()
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
                    
                    if w.count == 1 && (w.first!.tabGroup == nil || w.first!.tabGroup?.isTabBarVisible == false) {
                        
                        w.first!.toggleTabBar(self)
                    } else if w.count > 1 && NSApp.keyWindow?.tabGroup?.isTabBarVisible == true {
                        NSApp.keyWindow?.toggleTabBar(self)
                    }

                    let lastWindow = NSApp.windows.first(where: {win in
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
                    tab.load()
                }
            })
        }
    }
    
    @ToolbarContentBuilder
    func urlToolBarContent(_ geometry: GeometryProxy) -> some ToolbarContent {
        let url = Binding<String>(
            get: { tab.url.absoluteString.decodedURLString! },
          set: { s in
              tab.url = URL(unicodeString: s) ?? URL(string: "gemini://about")!
              self.urlChanged(s)
          }
        )
        
        ToolbarItem(placement: .navigation) { // (1) we can specify location for each ToolbarItem

            Button(action: back) {
                Image(systemName: "arrow.backward").imageScale(.large).padding(.trailing, 8)
            }
            .disabled(tab.history.count <= 1)
            .buttonStyle(.borderless)
        }
        
        ToolbarItemGroup(placement: .principal) {
            
            ZStack(alignment: .trailing) {
                
                TextField("example.org", text: url)
                    .onSubmit {
                        go()
                    }
                    .frame(minWidth: 600, maxWidth: .infinity)
                    
                    .background(Color("urlbackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if (tab.loading) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Color.gray)
                    .rotationEffect(Angle(degrees: rotation))
                        .onReceive(timer) { time in
                            $rotation.wrappedValue += 1.0
                        }
                        .padding(.trailing, 8)
                        
                }
                
                Button(action: toggleValidateCert) {
                    Image(systemName: (tab.ignoredCertValidation ? "lock.open" : "lock"))
                        .foregroundColor((tab.ignoredCertValidation ? Color.red : Color.green))
                        .imageScale(.large).padding(.leading, 0)
                        .opacity(0.7)
                }.disabled(!tab.ignoredCertValidation)
                    .padding(.trailing, tab.loading ? 20 : 0)
            }
//            .background(Color.red)

            Button(action: go) {
                Image(systemName: (tab.loading ? "xmark" : "arrow.clockwise"))
                    .imageScale(.large).padding(.leading, 0)
            }
            .buttonStyle(.borderless)
            .disabled(url.wrappedValue.isEmpty)
            
            Spacer(minLength: 50)
        }
        
        ToolbarItemGroup(placement: .primaryAction, content: {
            Button(action: bookmark) {
                Image(systemName: (bookmarked ? "star.fill" : "star")).imageScale(.large)
            }
            .buttonStyle(.borderless)
            .disabled(url.wrappedValue.isEmpty)
            Button(action: showBookmarks) {
                Image(systemName: "bookmark").imageScale(.large)
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                BookmarksView(tab: tab, close: { showPopover = false }).frame(maxWidth: .infinity)
            }
        })
        
    }
    
    func urlChanged(_ url: String) {
        guard let url = URL(string: url) else { return }
        if history.items.contains(url) {
            print(url)
        }
    }
    
    func showBookmarks() {
        self.showPopover = !self.showPopover
    }
    
    var bookmarked: Bool {
        return bookmarks.items.contains(where: { $0.url == tab.url })
    }
    
    func bookmark() {
        if (bookmarked) {
            bookmarks.items = bookmarks.items.filter( { $0.url != tab.url } )
        } else {
            bookmarks.items.append(Bookmark(url: tab.url))
        }
        
        bookmarks.save()
    }
    
    func go() {
        if (tab.loading) {
            tab.stop()
        } else {
            if !tab.url.absoluteString.starts(with: "gemini://") {
                let u = tab.url.absoluteString
                tab.url = URL(string: "gemini://" + u) ?? URL(string: "gemini://about/")!
            }
            tab.load()
        }
    }
    
    func back() {
        tab.back()
    }
    
    func getCurrentWindows() -> [NSWindow] {
        return NSApp.windows.filter{ NSStringFromClass(type(of: $0)) == "SwiftUI.SwiftUIWindow" }
    }
    
    func toggleValidateCert() {
        print("ignored cert validation", tab.certs.items.contains(tab.url.host ?? ""))
        if tab.certs.items.contains(tab.url.host ?? "") {
            tab.certs.items.removeAll(where: {$0 == tab.url.host})
            tab.load()
        } else {
            tab.certs.items.append(tab.url.host ?? "")
        }
    }
}
