//
//  TabContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 18/02/2022.
//

import SwiftUI

struct TabContentView: View {
    @EnvironmentObject private var tabList: TabList
    @ObservedObject var tab: Tab
    
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            tabView
            
            //TODO status bar
            Text("")
                .background(Color.gray)
        }
    }
    
    @ViewBuilder
    private var tabView: some View {
        if tab.id == tabList.activeTabId {
            HStack {
            Spacer()
                ScrollView {
                    ForEach(tab.content, id: \.self) { view in
                        view.frame(maxWidth: .infinity, alignment: .leading)
                            .id(view.id)
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                    .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, alignment: .center)
            .background(Color.clear)
        }
    }
}

