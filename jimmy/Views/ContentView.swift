//
//  ContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var tab: Tab = Tab(url: URL(string: "gemini://about")!)
    @EnvironmentObject var bookmarks: Bookmarks
    @State var showPopover = false
    @State var searchText = ""

    
    var body: some View {

        VStack {
            Text(tab.id.uuidString)
//            ZStack {
//                Color("background").edgesIgnoringSafeArea(.all)
//                ForEach(tabList.tabs) { tab in
                  TabContentView(tab: tab)
//                }
//            }
        }
        
        .navigationTitle(Emojis(tab.url.host ?? "").emoji + " " + (tab.url.host ?? ""))
        
        
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
        .toolbar{
            urlToolBarContent()
        }
        .onOpenURL(perform: { url in
            tab.url = url
            tab.load()
        })
        .onAppear(perform: {
            tab.load()
        })
    }
    
    @ToolbarContentBuilder
    func urlToolBarContent() -> some ToolbarContent {
        let url = Binding<String>(
          get: { tab.url.absoluteString },
          set: {
              tab.url = URL(string: $0) ?? URL(string: "gemini://about")!
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

            Text(Emojis(tab.url.host ?? "").emoji)
            TextField("example.org", text: url)
                .onSubmit {
                    go()
                }

                .padding(.trailing, 6)
                .padding(.bottom, 2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(idealWidth: 600, maxWidth: .infinity)
            
            Button(action: go) {
                Image(systemName: (tab.loading ? "xmark" : "arrow.clockwise"))
                    .imageScale(.large).padding(.leading, 8)
            }
            .buttonStyle(.borderless)
            .disabled(url.wrappedValue.isEmpty)
            Spacer()
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
            tab.load()
        }
    }
    
    func back() {
        tab.back()
    }
}

