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
    
    func a () {
        tabList.activeTab = tab
    }
    
    func close () {
        print(tabList.tabs.endIndex)
        tabList.tabs = tabList.tabs.filter({$0 != self.tab})
        print(tabList.tabs.endIndex)
        if let last = tabList.tabs.last {
            tabList.activeTab = last
        }
    }
    
    @ViewBuilder
    private var activeDependentButton: some View {
        if self.tabList.activeTab == tab {
            tabButton
        } else {
            tabButton.opacity(0.5)
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        if self.tabList.tabs.count > 1 {
            Button(action: close) {
                Image(systemName: "xmark").imageScale(.medium).padding(.trailing, 0)
            }.padding(.trailing, 0)
        }
    }
    
    @ViewBuilder
    private var tabButton: some View {
        HStack {
            closeButton
            Button(action: a) {
                Text(tab.url).font(.system(size: 14)).opacity(0.8).frame(maxWidth: 300)
            }.buttonStyle(PlainButtonStyle()).padding(.bottom, 3).padding(.leading, 0)
        }
    }
}


