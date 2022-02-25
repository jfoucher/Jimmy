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
    @State var text = ""
    
    var body: some View {
        tabView
    }
    
    @ViewBuilder
    private var tabView: some View {
//        if tab.id == tabList.activeTabId {
            ZStack(alignment: .bottomLeading) {
                HStack {
                    ScrollView {
                        if (tab.content.count > 0) {
                            ForEach(tab.content, id: \.self) { view in
                                view
                                    .textSelection(.enabled)
                                    .frame(minWidth: 200, maxWidth: 800, alignment: .leading)
                                    .id(view.id)
                            }
                            .padding(48)
                            .frame(minWidth: 200, maxWidth: .infinity, alignment: .center)
                        } else {
                            HStack {
                                AttributedText(
                                    tab.textContent,
                                    onOpenLink: { url in
                                        print("open url", url)
                                        tab.url = url
                                        tab.load()
                                    }
                            )
                                    
                                .textSelection(.enabled)
                                .searchable(text: $text)
                                .onSubmit(of: .search) {
                                    print("searching for", text)
                                }
                                .frame(minWidth: 200, maxWidth: 800, alignment: .leading)
                                .padding(.top, 24)
                                .padding(.bottom, 24)
                                
                                
                            }

                            
                            .frame(minWidth: 200, maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                    .background(Color("background"))
                }
                status
            }
            .onTapGesture(count: 1, perform: {
                print("click")
            })
//        }
    }
    
    @ViewBuilder
    private var status: some View {
        if !tab.status.isEmpty {
            HStack {
                Text(tab.status)
                    .font(.system(size: 12, weight: .light))
                    .padding(.leading, 24)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                    .padding(.top, 2)
                    .opacity(0.7)
                    .background(Color("background").opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1).background(.clear).foregroundColor(Color("urlbackground")))
                    
            }
            .padding(.leading, -12)
            .padding(.bottom, -4)
        }
    }
}

