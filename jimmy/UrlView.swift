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
    
    var body: some View {
        HStack {
            Button(action: back) {
                Image(systemName: "arrow.backward")
            }.disabled(tabList.activeTab.history.count <= 1)
            Text("gemini://")
            TextField("example.org", text: $tabList.activeTab.url)
            Button(action: go) {
                Text(tabList.loading ? "..." : "Go")
            }
        }.padding()
    }
    
    func go() {
        tabList.load()
    }
    
    func back() {
        tabList.back()
    }
}

