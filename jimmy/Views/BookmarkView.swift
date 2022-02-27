//
//  BookmarkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import SwiftUI

struct BookmarkView: View {
    @Environment(\.openURL) var openURL
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
                    Text(Emojis(bookmark.url.host ?? "").emoji)
                    Text((bookmark.url.absoluteString.decodedURLString ?? bookmark.url.absoluteString).replacingOccurrences(of: "gemini://", with: "")).frame(maxWidth: .infinity, alignment: .leading)
                        
                }

                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4).padding(.leading, 0).padding(.trailing, 8)
                .contextMenu {
                    VStack {
                        Button(action: {
                            newTab(self.bookmark.url)
                        })
                        {
                            Label("Open in new tab", systemImage: "plus.rectangle")
                        }
                            .buttonStyle(.plain)
                        Button(action: copyLink)
                        {
                            Label("Copy link address", systemImage: "link")
                        }
                            .buttonStyle(.plain)
                    }
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
    
    func newTab(_ url: URL) {
        openURL(url)
    }
    
    func copyLink() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self.bookmark.url.absoluteString, forType: .string)
    }
}
