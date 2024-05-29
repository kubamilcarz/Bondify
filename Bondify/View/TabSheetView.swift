//
//  TabSheetView.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import SwiftUI

enum SheetMode {
    case edit, new
}

struct TabSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    var tab: Tab?
    let mode: SheetMode
    
    
    init(tab: Tab? = nil, mode: SheetMode) {
        self.tab = tab
        self.mode = mode
    }
    
    
    @State private var title = ""
    @State private var selectedIcon = "archivebox"
    @State private var selectedColor = Color.accent
    
    let icons = ["airplane", "ant", "archivebox", "archivebox.circle", "bag", "bag.circle", "bandage", "barcode", "binoculars", "bicycle", "book",
                 "books.vertical", "baseball", "football", "tennis.racket", "trophy", "medal", "sportscourt", "bird", "bed.double", "battery.100",
                 "battery.100.bolt", "battery.75", "bell", "bookmark", "briefcase", "car", "cart", "clock", "hourglass", "cloud",
                 "creditcard", "cup.and.saucer", "deskclock", "envelope", "envelope.circle", "folder", "folder.circle", "gift",
                 "hammer", "headphones", "headphones.circle", "house", "basket", "banknote", "moon", "tree", "carrot", "atom", "pawprint", "dog", "cat", "lizard",
                 "key", "laptopcomputer", "laptopcomputer.and.arrow.down", "lock", "lock.circle", "lock.open", "magnifyingglass", "mic", "mic.circle", "paintbrush",
                 "paperclip", "pencil", "pencil.circle", "phone", "photo", "printer", "scissors", "scissors.circle", "screwdriver", "speaker", "signature", "heart",
                 "syringe", "pills", "brain", "star", "stethoscope", "suitcase", "trash", "trash.circle", "tv", "umbrella", "wrench"]
    let colors: [Color] = [.accent, .blue, .brown, .cyan, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .yellow]

 
    var body: some View {
        NavigationStack {
            List {
                TextField("Title", text: $title, axis: .vertical)
                    .lineLimit(1...3)
                    .font(.system(.title3, design: .serif).bold())
                
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
                
                Section("Color") {
                    ZStack(alignment: .bottom) {
                        ScrollView(.vertical) {
                            LazyVGrid(columns: [.init(.adaptive(minimum: 40, maximum: 50), spacing: 10)], spacing: 10) {
                                ForEach(colors, id: \.self) { color in
                                    Button {
                                        withAnimation {
                                            selectedColor = color
                                        }
                                    } label: {
                                        Circle()
                                            .fill(color)
                                            .aspectRatio(1/1, contentMode: .fill)
                                            .frame(minWidth: 40, minHeight: 30)
                                            .overlay(selectedColor == color ? 
                                                 Image(systemName: "checkmark.circle.fill")
                                                    .symbolRenderingMode(.hierarchical)
                                                    .symbolVariant(.fill)
                                                    .font(.headline)
                                                    .foregroundStyle(.white)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                                            : nil)
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
            .navigationTitle(mode == .new ? "New Tab" : tab?.tabTitle ?? "Untitled")
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
                guard let tab, mode == .edit else { return }
                
                title = tab.tabTitle
                selectedIcon = tab.tabIcon
                selectedColor = tab.tabColor
            }
        }
    }
    
    
    private func save() {
        guard title.isEmpty == false else { return }
        
        if mode == .new {
            let newTab = Tab(context: context)
            newTab.id = UUID()
            newTab.tabTitle = title
            newTab.tabIcon = selectedIcon
            newTab.tabColor = selectedColor
        } else {
            tab?.tabTitle = title
            tab?.tabIcon = selectedIcon
            tab?.tabColor = selectedColor
        }
        
        try? context.save()
        
        dismiss()
    }
}
