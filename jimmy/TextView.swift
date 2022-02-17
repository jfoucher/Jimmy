//
//  TextView.swift
//  jimmy
//
//  Created by Jonathan Foucher on 17/02/2022.
//

import SwiftUI

struct TextView: View {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(self.text)
    }
}

