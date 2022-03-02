//
//  HistoryView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 02/03/2022.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: History
    @EnvironmentObject var tab: Tab
    @State var hoverClearHistoryButton = false
    
    var close: () -> Void
    
    var body: some View {
        let histItems = history.items.filter({ hist in
            hist.url.absoluteString.replacingOccurrences(of: "gemini://", with: "").contains(tab.url.absoluteString.replacingOccurrences(of: "gemini://", with: ""))
        })
        ZStack(alignment: .topTrailing){
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(histItems, id: \.self) { item in
                    HistoryItemView(item: item, close: {
                        close()
                    }).environmentObject(tab)
                }
            }
            Button(action: {
                clearHistory()
            }) {
                HStack {
                    Image(systemName: "xmark.app.fill")
                    if hoverClearHistoryButton {
                        Text("Clear history")
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
                .padding(.leading, 8)
                .padding(.bottom, 4)
                .animation(.default, value: hoverClearHistoryButton)
                .background(Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .onHover(perform: { hover in
                hoverClearHistoryButton = hover
            })
            .padding(.trailing, -12)
            .padding(.top, -12)
            
        }
        
    }
    
    func clearHistory() {
        history.clear()
        close()
    }
}
