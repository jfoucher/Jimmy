//
//  BookmarkView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject private var bookmarks: Bookmarks
    
    var tab: Tab
    
    var close: () -> Void
    
    init(tab: Tab, close: @escaping () -> Void) {
        self.tab = tab
        self.close = close
    }
    
    var body: some View {
        VStack {
            Text("Bookmarks").frame(maxWidth: .infinity)
            Divider()
            ForEach(bookmarks.items) { bookmark in
                BookmarkView(bookmark: bookmark, tab: tab, close: close)
            }
        }.padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
