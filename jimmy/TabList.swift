//
//  TabList.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import Foundation
import SwiftUI

class TabList: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var activeTabId: UUID
    
    init() {
        let tab = Tab(url: "about");
        self.tabs = [tab]
        self.activeTabId = tab.id
        tab.load()
    }
}
