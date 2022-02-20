//
//  BookmarkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject private var bookmarks: Bookmarks
    
    private var tab: Tab
    private var bookmark: Bookmark
    @State private var isHover = false
    
    var close: () -> Void
    
    init(bookmark: Bookmark, tab: Tab, close: @escaping () -> Void) {
        self.tab = tab
        self.bookmark = bookmark
        self.close = close
    }
    
    var body: some View {
        HStack {
            Button(action: {
                bookmarks.remove(bookmark: bookmark)
            }) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .padding(4).padding(.leading, 8).padding(.trailing, 0)
            
            ZStack {
                Button(action: {
                    tab.url = bookmark.url
                    tab.load()
                    close()
                }) {
                    Text(bookmark.url.absoluteString.replacingOccurrences(of: "gemini://", with: "")).frame(maxWidth: .infinity, alignment: .leading)
                        
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4).padding(.leading, 0).padding(.trailing, 8)
                .contextMenu {
                    LinkContextMenu(link: bookmark.url)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHover ? Color("urlbackground") : Color.clear)
            .animation(.spring(), value: isHover)
            .onHover { hover in
               isHover = hover
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }

    }
}
