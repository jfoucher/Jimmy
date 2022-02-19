//
//  UrlView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI


struct UrlView: View {
    @EnvironmentObject private var tabList: TabList
    @EnvironmentObject private var bookmarks: Bookmarks
    @ObservedObject var tab: Tab
    @State var showPopover = false
    
    var body: some View {
        bar
    }
    
    @ViewBuilder
    private var bar: some View {
        if self.tabList.activeTabId == tab.id {
            HStack {
                Button(action: back) {
                    Image(systemName: "arrow.backward").imageScale(.large).padding(.trailing, 8)
                }
                .disabled(tab.history.count <= 1)
                .buttonStyle(.borderless)
                
                
                Button(action: showBookmarks) {
                    Image(systemName: "bookmark").imageScale(.large).padding(.trailing, 8)
                }
                .buttonStyle(.borderless)
                .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    BookmarksView(tab: tab, close: { showPopover = false }).frame(maxWidth: .infinity)
                }
                
                HStack {
                    Text("gemini://")
                        .fontWeight(.light)
                        .foregroundColor(Color.gray)
                        .padding(.leading, 6)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                        .padding(.trailing, -8)
                    TextField("example.org", text: $tab.url)
                        .textFieldStyle(.plain)
                        .padding(.trailing, 6)
                        .padding(.bottom, 2)
                        .onSubmit {
                            go()
                        }
                }
                .background(Color("urlbackground"))
                .clipShape(RoundedRectangle(cornerRadius:4))
                Button(action: bookmark) {
                    Image(systemName: (bookmarked ? "star.fill" : "star")).imageScale(.large).padding(.leading, 8)
                }
                .buttonStyle(.borderless)
                .disabled(tab.url.isEmpty)
                
                Button(action: go) {
                    Image(systemName: "arrow.clockwise").imageScale(.large).padding(.leading, 8)
                }
                .buttonStyle(.borderless)
                .disabled(tab.url.isEmpty)
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
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
        tab.load()
    }
    
    func back() {
        tab.back()
    }
}

