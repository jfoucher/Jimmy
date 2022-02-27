//
//  TabContentView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 27/02/2022.
//

import SwiftUI

struct TabTextView: View {
    @ObservedObject var tab: Tab
    @State var text = ""
    
    
    var body: some View {
        HStack {
            AttributedText(
                tab.textContent,
                onOpenLink: { url in
                    tab.url = url
                    tab.load()
                },
                onHoverLink: { url, hovered in
                    let loadingStatus = tab.loading ? "Loading " + tab.url.absoluteString : ""
                    if let u = url {
                        let newStatus = hovered ? (u.absoluteString.decodedURLString ?? u.absoluteString).replacingOccurrences(of: "gemini://", with: "") : loadingStatus
                        if tab.status != newStatus {
                            tab.status = newStatus
                        }
                    }
                    if hovered == false {
                        tab.status = loadingStatus
                    }
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
