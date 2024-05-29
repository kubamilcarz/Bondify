//
//  ItemSheetView.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import SwiftUI

struct ItemSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    var tab: Tab?
    var item: Item?
    let mode: SheetMode
    
    
    init(tab: Tab? = nil, item: Item? = nil, mode: SheetMode) {
        self.tab = tab
        self.item = item
        self.mode = mode
    }
    
    
    @State private var title = ""
    @State private var withDue = false
    @State private var due = Date().addingTimeInterval(500000)
    @State private var notes = ""
    @State private var selectedIcon = "archivebox"
    
    let icons = ["airplane", "ant", "archivebox", "archivebox.circle", "bag", "bag.circle", "bandage", "barcode", "binoculars", "bicycle", "book",
                 "books.vertical", "baseball", "football", "tennis.racket", "trophy", "medal", "sportscourt", "bird", "bed.double", "battery.100",
                 "battery.100.bolt", "battery.75", "bell", "bookmark", "briefcase", "car", "cart", "clock", "hourglass", "cloud",
                 "creditcard", "cup.and.saucer", "deskclock", "envelope", "envelope.circle", "folder", "folder.circle", "gift",
                 "hammer", "headphones", "headphones.circle", "house", "basket", "banknote", "moon", "tree", "carrot", "atom", "pawprint", "dog", "cat", "lizard",
                 "key", "laptopcomputer", "laptopcomputer.and.arrow.down", "lock", "lock.circle", "lock.open", "magnifyingglass", "mic", "mic.circle", "paintbrush",
                 "paperclip", "pencil", "pencil.circle", "phone", "photo", "printer", "scissors", "scissors.circle", "screwdriver", "speaker", "signature", "heart",
                 "syringe", "pills", "brain", "star", "stethoscope", "suitcase", "trash", "trash.circle", "tv", "umbrella", "wrench"]

 
    var body: some View {
        NavigationStack {
            List {
                Section("Item") {
                    TextField("Title", text: $title, axis: .vertical)
                        .lineLimit(1...3)
                        .font(.system(.title3, design: .serif).bold())
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...7)
                        .font(.system(.body, design: .serif))
                    
                    Toggle(isOn: $withDue) {
                        Label("Due Date", systemImage: "switch.2")
                    }
                    if withDue {
                        DatePicker(selection: $due, in: .now..., displayedComponents: .date) {
                            Label("Due Date", systemImage: "calendar")
                        }
                    }
                }
                
                Section("Icon") {
                    ZStack(alignment: .bottom) {
                        ScrollView(.vertical) {
                            LazyVGrid(columns: [.init(.adaptive(minimum: 40, maximum: 50), spacing: 10)], spacing: 10) {
                                ForEach(icons, id: \.self) { icon in
                                    Button {
                                        withAnimation {
                                            selectedIcon = icon
                                        }
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.headline)
                                            .symbolVariant(.fill)
                                            .aspectRatio(1/1, contentMode: .fill)
                                            .frame(minWidth: 40, minHeight: 30)
                                            .background(.ultraThinMaterial, in: .circle)
                                            .foregroundStyle(selectedIcon == icon ? Color.accentColor : .secondary)
                                            .overlay(selectedIcon == icon ? Circle().stroke(Color.accentColor.gradient, lineWidth: 2) : nil)
                                    }
                                    .buttonStyle(.plain)
                                    .buttonBorderShape(.circle)
                                }
                            }
                            .padding()
                            .padding(.vertical, 10)
                            
                            LinearGradient(colors: [.clear, .secondary.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                                .frame(height: 50)
                                .allowsHitTesting(false)
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .frame(maxWidth: .infinity, maxHeight: 300)
                }
            }
            .navigationTitle(mode == .edit ? (item?.itemTitle ?? "Untitled") : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        save()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                guard let item, mode == .edit else { return }
                
                title = item.itemTitle
                notes = item.itemNotes
                selectedIcon = item.itemIcon
                due = item.dueDate ?? .now
                withDue = item.dueDate != nil
            }
        }
    }
    
    
    private func save() {
        guard title.isEmpty == false else { return }
        
        if mode == .new {
            let newItem = Item(context: context)
            newItem.id = UUID()
            newItem.itemTitle = title
            newItem.itemNotes = notes
            newItem.itemDateAdded = .now
            newItem.dueDate = withDue ? due : nil
            newItem.tab = tab
        } else {
            if let item {
                item.itemTitle = title
                item.itemNotes = notes
                item.itemIcon = selectedIcon
                item.dueDate = withDue ? due : nil
                
                if tab != nil {
                    item.tab = tab
                }
            }
        }
        
        try? context.save()
        
        dismiss()
    }
}
