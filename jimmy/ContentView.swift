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
            UrlView()
            ZStack {
                Color("background").edgesIgnoringSafeArea(.all)
                mainView
            }
            
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
                    Text("+")
                }
            })
        }
        
    }
    func newTab() {
        let nt = Tab(url:"localhost/");
        tabList.tabs.append(nt)
        tabList.activeTab = nt
    }
    
    func btn (){}
    
    @ViewBuilder
    private var mainView: some View {
        if self.tabList.loading {
            ScrollView {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(Color.clear)
            
        } else {
            ScrollView {
                ForEach(tabList.activeTab.content, id: \.self) { view in
                    view.frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(Color.clear)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
