//
//  LinkContectMenu.swift
//  jimmy
//
//  Created by Jonathan Foucher on 19/02/2022.
//

import SwiftUI

struct LinkContextMenu: View {
    @EnvironmentObject private var tabList: TabList
    var link: URL
    
    init(link: URL) {
        self.link = link
    }
    var body: some View {
        Button(action: newTab)
        {
            Label("Open in new tab", systemImage: "plus.rectangle")
        }
            .buttonStyle(.plain)
    }
    
    func newTab() {
        let nt = Tab(url: self.link)
        tabList.tabs.append(nt)
        tabList.activeTabId = nt.id
        nt.load()
    }
}
