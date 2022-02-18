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
            
            Text("")
                .background(Color.gray)
        }
    }
    
    @ViewBuilder
    private var tabView: some View {
        if tab.id == tabList.activeTabId {
            if tab.loading {
                ScrollView {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
                .background(Color.clear)
                
            } else {
                ScrollView {
                    HStack {
                        
                        Spacer()
                        VStack {
                            ForEach(tab.content, id: \.self) { view in
                                view.frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 48)
                            .padding(.trailing, 48)
                            .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                        }.padding(.top, 48).frame(minWidth: 200, maxWidth: 800, alignment: .center)
                        Spacer()
                    }
                }
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, alignment: .center)
                .background(Color.clear)
            }
        }
    }
}

