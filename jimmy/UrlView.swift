//
//  UrlView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation

import SwiftUI


struct UrlView: View {
    @EnvironmentObject private var tabList: TabList
    @ObservedObject var tab: Tab
    
    var body: some View {
        bar
    }
    
    @ViewBuilder
    private var bar: some View {
        if self.tabList.activeTabId == tab.id {
            HStack {
                Button(action: back) {
                    Image(systemName: "arrow.backward").imageScale(.large).padding(.trailing, 8)
                }
                .disabled(tab.history.count <= 1)
                .buttonStyle(.borderless)

                HStack {
                    Text("gemini://")
                        .fontWeight(.light)
                        .foregroundColor(Color.gray)
                        .padding(.leading, 6)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                        .padding(.trailing, -8)
                    TextField("example.org", text: $tab.url)
                        .textFieldStyle(.plain)
                        .padding(.trailing, 6)
                        .padding(.bottom, 2)
                        .onSubmit {
                            go()
                        }
                }
                .background(Color(CGColor(red: 128, green: 129, blue: 128, alpha: 0.1)))
                .clipShape(RoundedRectangle(cornerRadius:4))
                
                
                
                Button(action: go) {
                    Image(systemName: "arrow.clockwise").imageScale(.large).padding(.leading, 8)
                }
                .buttonStyle(.borderless)
                .disabled(tab.url.isEmpty)
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
    }
    
    func go() {
        tab.load()
    }
    
    func back() {
        tab.back()
    }
}

