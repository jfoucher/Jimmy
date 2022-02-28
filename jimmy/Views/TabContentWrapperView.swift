//
//  TabContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 18/02/2022.
//

import SwiftUI

struct TabContentWrapperView: View {
    @ObservedObject var tab: Tab
    @State var text = ""
    
    var body: some View {
        tabView
    }
    
    @ViewBuilder
    private var tabView: some View {
        ZStack(alignment: .bottomLeading) {
            HStack {
                ScrollView {
                    if (tab.content.count > 0) {
                        TabLineView(tab: tab)
                    } else {
                        TabTextView(tab: tab)
                    }
                }
                
                .frame(minWidth: 200, maxWidth: .infinity, alignment: .leading)
                .background(Color("background"))
            }
            status
        }
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

