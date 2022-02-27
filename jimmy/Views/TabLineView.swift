//
//  TabLineView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 27/02/2022.
//

import SwiftUI

struct TabLineView: View {
    @ObservedObject var tab: Tab
    
    var body: some View {
        ForEach(tab.content, id: \.self) { view in
            view
                .textSelection(.enabled)
                .frame(minWidth: 200, maxWidth: 800, alignment: .leading)
                .id(view.id)
        }
        .padding(48)
        .frame(minWidth: 200, maxWidth: .infinity, alignment: .center)
    }
}
