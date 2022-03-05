//
//  TabHistoryItem.swift
//  jimmy
//
//  Created by Jonathan Foucher on 04/03/2022.
//

import Foundation
import Network

struct TabHistoryItem {
    var url: URL
    var scrollposition: Double
    var error: NWError?
    var message: Data?
}
