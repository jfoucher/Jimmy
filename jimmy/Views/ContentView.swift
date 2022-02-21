//
//  ContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 16/02/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var tabList: TabList
    
    var body: some View {
        VStack {
            mainView
        }
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                ForEach(tabList.tabs, id: \.self) { tab in
                  TabView(tab: tab)//.frame(alignment: .leading)
              }
            }
            ToolbarItem(placement: .automatic, content: {
                Spacer()
            })
            ToolbarItem(placement: .confirmationAction, content: {
                Button(action: newTab) {
                    Image(systemName: "plus").imageScale(.large).padding()
                }
            })
        }
    }
    func newTab() {
        let nt = Tab(url: URL(string: "gemini://about")!);
        tabList.tabs.append(nt)
        tabList.activeTabId = nt.id
        nt.load()
    }
    
    func btn (){}
    
    @ViewBuilder
    private var mainView: some View {
        VStack {
            
            ForEach(tabList.tabs) { tab in
                UrlView(tab: tab)
            }
            ZStack {
                Color("background").edgesIgnoringSafeArea(.all)
                ForEach(tabList.tabs) { tab in
                  TabContentView(tab: tab)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
