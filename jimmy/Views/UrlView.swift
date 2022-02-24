//
//  UrlView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI


struct UrlView: View {
    @EnvironmentObject private var bookmarks: Bookmarks
    @EnvironmentObject private var tab: Tab
    @State var showPopover = false
    


    
    
    var body: some View {
        bar
    }
    
    @ViewBuilder
    private var bar: some View {
        
            let url = Binding<String>(
                get: { self.tab.url.absoluteString.replacingOccurrences(of: "gemini://", with: "") },
                set: {
                    self.tab.url = URL(string: "gemini://" + $0) ?? URL(string: "gemini://about")!
                }
           )
            HStack {
                Button(action: back) {
                    Image(systemName: "arrow.backward").imageScale(.large).padding(.trailing, 8)
                }
                .disabled(tab.history.count <= 1)
                .buttonStyle(.borderless)
                HStack {
                    Text("gemini://")
                        .fontWeight(.light)
                        .foregroundColor(Color.gray)
                        .padding(.leading, 6)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                        .padding(.trailing, -8)

                    TextField("example.org", text: url)
                        .onSubmit {
                            go()
                        }
                        .textFieldStyle(.plain)
                        .padding(.trailing, 6)
                        .padding(.bottom, 2)
                        .frame(minWidth: 0, idealWidth: 500,maxWidth: .infinity, alignment: .leading)


                }.frame(maxWidth: .infinity)
                .background(Color("urlbackground"))
                .clipShape(RoundedRectangle(cornerRadius:4))
                Button(action: go) {
                    Image(systemName: (tab.loading ? "xmark" : "arrow.clockwise"))
                        .imageScale(.large).padding(.leading, 8)
                }
                .buttonStyle(.borderless)
                .disabled(url.wrappedValue.isEmpty)
                
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
            }.frame(maxWidth: .infinity)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
        
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

