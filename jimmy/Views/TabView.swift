//
//  TabView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI
import CryptoKit

struct TabView: View {
    @ObservedObject var tab: Tab
    @EnvironmentObject private var tabList: TabList
    @State private var rotation = 0.0

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        tabButton.opacity(tabList.activeTabId == tab.id ? 1 : 0.5)
    }
    
    var host: String? {
        return tab.url.host
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
    private var closeButton: some View {
        if self.tabList.tabs.count > 1 {
            Button(action: close) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .padding(.leading, 4)
            }
            .help("Close " + (tab.url.host ?? ""))
            .buttonStyle(.borderless)
            .padding(.trailing, -4)
            .padding(.bottom, -2)
        }
    }
    
    @ViewBuilder
    private var loading: some View {
        if tab.loading {
            Image(systemName: "arrow.triangle.2.circlepath")
                .resizable()
                .aspectRatio(1.2, contentMode: .fit)
                .frame(width: 12, alignment: .leading)
                .rotationEffect(Angle(degrees: rotation))
                .foregroundColor(Color.gray)
                .padding(.leading, 0)
                .padding(.bottom, -2)
                .onReceive(timer) { time in
                    $rotation.wrappedValue += 1.0
                    //print("The time is now \(time.)")
                }
        }
    }
    
    @ViewBuilder
    private var tabButton: some View {
        HStack {
            closeButton
            Button(action: a) {
                icon
                Text(self.host ?? tab.url.absoluteString).font(.system(size: 14)).opacity(0.8).frame(maxWidth: 300)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, tab.loading ? -6 : 14)
            loading
        }
    }
    
    @ViewBuilder
    private var icon: some View {
        if !tab.icon.isEmpty {
            Text(tab.icon)
        }
    }
}


