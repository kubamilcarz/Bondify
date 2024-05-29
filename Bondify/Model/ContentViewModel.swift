//
//  ContentViewModel.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import SwiftUI

final class ContentViewModel: ObservableObject {
    
    let context = PersistenceController.shared.container.viewContext
    
    @Published var isShowingNewTabSheet = false
    @Published var editTab: Tab?
    @Published var deleteTab: Tab?
    
    @Published var isShowingSettings = false
    @Published var activeTab: Tab?
    @Published var tabs: [Tab] = []
    
    @Published var newItemTab: Tab?
    @Published var editItem: Item?
    @Published var deleteItem: Item?
    
    
    func loadTabs() {
        context.perform {
            let request = Tab.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Tab.isPinned, ascending: false),
                NSSortDescriptor(keyPath: \Tab.title, ascending: true)]
            
            let result = (try? self.context.fetch(request)) ?? []
            
            DispatchQueue.main.async {
                self.tabs = result
            }
        }
    }
    
    
    func togglePin(for tab: Tab) {
        tab.isPinned = !tab.isPinned
        
        try? context.save()
        
        loadTabs()
    }
    
    
    func togglePin(for item: Item) {
        item.isPinned = !item.isPinned
        
        try? context.save()
    }
    
    
    func toggleDone(for item: Item) {
        item.isDone = !item.isDone
        
        try? context.save()
    }
    
    
    func delete() {
        if let deleteTab {
            context.delete(deleteTab)
            
            try? context.save()
            
            self.deleteTab = nil
            
            loadTabs()
        }
        
        if let deleteItem {
            context.delete(deleteItem)
            
            try? context.save()
            
            self.deleteItem = nil
        }
    }
}
