//
//  Tab.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import SwiftUI

extension Tab {
    
    var tabTitle: String {
        get { title ?? "Untitled" }
        set { title = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    var tabIcon: String {
        get { icon ?? "questionmark.folder" }
        set { icon = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    var tabItems: [Item] { Array(items as? Set<Item> ?? []) }
    
    
    var tabColor: Color {
        get {
            switch color {
            case "black": return .black
            case "blue": return .blue
            case "brown": return .brown
            case "clear": return .clear
            case "cyan": return .cyan
            case "gray": return .gray
            case "green": return .green
            case "indigo": return .indigo
            case "mint": return .mint
            case "orange": return .orange
            case "pink": return .pink
            case "purple": return .purple
            case "red": return .red
            case "teal": return .teal
            case "white": return .white
            case "yellow": return .yellow
            case "accent": return .accent
            default: return .accent
            }
        }
        set {
            switch newValue {
            case .black: color = "black"
            case .blue: color = "blue"
            case .brown: color = "brown"
            case .clear: color = "clear"
            case .cyan: color = "cyan"
            case .gray: color = "gray"
            case .green: color = "green"
            case .indigo: color = "indigo"
            case .mint: color = "mint"
            case .orange: color = "orange"
            case .pink: color = "pink"
            case .purple: color = "purple"
            case .red: color = "red"
            case .teal: color = "teal"
            case .white: color = "white"
            case .yellow: color = "yellow"
            default: color = "accent"
            }
        }
    }
}
