//
//  HistoryItemView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 02/03/2022.
//

import SwiftUI

struct HistoryItemView: View {
    @State var hovered = false
    @EnvironmentObject var tab: Tab
    var item: HistoryItem
    
    var close: () -> Void
    
    var body: some View {
        Button(action: {
            tab.url = item.url
            tab.load()
            self.close()
        }) {
            HStack {
                Text(tab.emojis.emoji(item.url.host ?? ""))
                    .font(.system(size: 24))
                VStack {
                    Text(item.url.absoluteString.replacingOccurrences(of: "gemini://", with: ""))
                        .font(.system(size: 16, weight: .light, design: .default))
                        .frame(minWidth: 600, maxWidth: .infinity, alignment: .leading)
                        
                    Text(item.snippet)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .frame(minWidth: 600, maxWidth: .infinity, alignment: .leading)
                       
                }
            }
            
            .padding(6)
            .padding(.leading, 8)
            .padding(.trailing, 8)
        }
        
        .buttonStyle(.borderless)
        
        .onHover(perform: { hover in
            hovered = hover
            tab.status = item.url.absoluteString.replacingOccurrences(of: "gemini://", with: "")
        })
        .background(hovered ? Color.accentColor : Color.clear)
    }
}
