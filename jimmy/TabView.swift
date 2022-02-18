//
//  TabView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct TabView: View {
    @ObservedObject var tab: Tab
    @EnvironmentObject private var tabList: TabList
    
    var body: some View {
        activeDependentButton
    }
    
    var host: String? {
        if let url = URL(string: "gemini://" + tab.url) {
            return url.host
        }
        
        return nil
    }
    
    func a () {
        tabList.activeTabId = tab.id
    }
    
    func close () {
        tabList.tabs = tabList.tabs.filter({$0 != self.tab})

        if let last = tabList.tabs.last {
            tabList.activeTabId = last.id
        }
    }
    
    @ViewBuilder
    private var activeDependentButton: some View {
        if self.tabList.activeTabId == tab.id {
            tabButton
        } else {
            tabButton.opacity(0.5)
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        if self.tabList.tabs.count > 1 {
            Button(action: close) {
                Image(systemName: "xmark").imageScale(.medium).padding(.leading, 4)
            }
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    private var tabButton: some View {
        HStack {
            closeButton
            Button(action: a) {
                Text(self.host ?? tab.url).font(.system(size: 14)).opacity(0.8).frame(maxWidth: 300)
            }.buttonStyle(PlainButtonStyle()).padding(.trailing, 8)
        }
    }
}


