//
//  Item.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import Foundation

extension Item {
    
    var itemTitle: String {
        get { title ?? "" }
        set { title = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    
    var itemNotes: String {
        get { notes ?? "" }
        set { notes = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    var itemIcon: String {
        get { icon ?? "" }
        set { icon = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    var itemDateAdded: Date {
        get { dateAdded ?? .distantPast }
        set { dateAdded = newValue }
    }
}
