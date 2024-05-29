//
//  TabDetailView.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/21/24.
//

import SwiftUI

struct TabDetailView: View {
    
    let context = PersistenceController.shared.container.viewContext
    @EnvironmentObject var model: ContentViewModel
    
    var tab: Tab
    
    @State private var items: [Item] = []
    
    init(tab: Tab) {
        self.tab = tab
        
        loadItems()
    }
    
    private func loadItems() {
        context.perform {
            let request = Item.fetchRequest()
            request.predicate = NSPredicate(format: "tab == %@", tab)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Item.isDone, ascending: true),
                NSSortDescriptor(keyPath: \Item.dueDate, ascending: false),
                NSSortDescriptor(keyPath: \Item.title, ascending: true)
            ]
            
            let result = (try? context.fetch(request)) ?? []
            
            DispatchQueue.main.async {
                items = result
            }
        }
    }
    
    
    var pinnedItems: [Item] {
        items.filter { !$0.isDone && $0.isPinned }
    }
    
    var unpinnedItems: [Item] {
        items.filter { !$0.isDone && !$0.isPinned }
    }
    
    var doneItems: [Item] {
        items.filter { $0.isDone }
    }
    
    @State private var isShowingDone = false
    @State private var refresh = false
    
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 50) {
                    if items.isEmpty {
                        ContentUnavailableView("No Items", systemImage: "archivebox", description: Text("Add your first items in the bottom right."))
                            .foregroundStyle(tab.tabColor.gradient)
                            .padding(10)
                    } else {
                        if pinnedItems.isEmpty && unpinnedItems.isEmpty {
                            ContentUnavailableView("You're all caught up!", systemImage: "party.popper", description: Text("You checked off everything. Add new items."))
                                .foregroundStyle(tab.tabColor.gradient)
                                .padding(10)
                        } else {
                            if pinnedItems.isEmpty == false {
                                VStack(spacing: 15) {
                                    Label("Pinned", systemImage: "pin.fill")
                                        .foregroundStyle(tab.tabColor.gradient)
                                        .font(.system(.title3, design: .serif).bold())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(pinnedItems) { item in
                                            Cell(item: item)
                                            
                                            if item != pinnedItems.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            VStack(spacing: 15) {
                                if unpinnedItems.isEmpty == false && pinnedItems.isEmpty == false {
                                    Label("All", systemImage: "circle.dotted")
                                        .foregroundStyle(.secondary)
                                        .font(.system(.title3, design: .serif).bold())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                VStack(spacing: 0) {
                                    ForEach(unpinnedItems) { item in
                                        Cell(item: item)
                                        
                                        if item != unpinnedItems.last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        
                        if doneItems.isEmpty == false {
                            VStack(spacing: 15) {
                                Button {
                                    withAnimation {
                                        isShowingDone.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Label("Show completed", systemImage: "checkmark.circle.fill")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                        Image(systemName: isShowingDone ? "chevron.up" : "chevron.down")
                                    }
                                    .font(.subheadline)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 5)
                                    .background(.background.opacity(0.01))
                                }
                                .buttonStyle(.plain)
                                
                                if isShowingDone {
                                    
                                    Divider()
                                    
                                    VStack(spacing: 0) {
                                        ForEach(doneItems) { item in
                                            Cell(item: item)
                                            
                                            if item != doneItems.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.top, 140)
            }
            .onAppear { loadItems() }
            .onChange(of: refresh) { loadItems() }
            .refreshable { loadItems() }
            
            HStack {
                Text(tab.tabTitle)
                    .font(.system(.largeTitle, design: .serif).weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    model.isShowingSettings = true
                } label: {
                    Image(systemName: "gear")
                        .font(.title3)
                        .foregroundStyle(.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 70)
            .padding(.bottom, 5)
            .padding(.horizontal)
            .background(.ultraThinMaterial)
        }
        .background(.linearGradient(colors: [tab.tabColor.opacity(0.3), .clear, .clear], startPoint: .top, endPoint: .bottom), ignoresSafeAreaEdges: .all)
    }
    
    
    private func Cell(item: Item) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.itemTitle)
                        .font(.system(.headline, design: .serif))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Image(systemName: "note.text")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        
                        Text(item.itemNotes.isEmpty ? "No Note" : item.itemNotes)
                            .font(.subheadline)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Menu {
                    Button(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash.fill" : "pin.fill") {
                        model.togglePin(for: item)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                refresh.toggle()
                            }
                        }
                    }
                    
                    Button("Edit", systemImage: "pencil") {
                        model.editItem = item
                    }
                    
                    Button("Delete", systemImage: "trash.fill", role: .destructive) {
                        model.deleteItem = item
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                
                Button {
                    model.toggleDone(for: item)
                    
                    withAnimation {
                        refresh.toggle()
                    }
                } label: {
                    Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(item.isDone ? tab.tabColor.gradient : Color.secondary.gradient)
                }
                .buttonStyle(.plain)
            }
            
            if let due = item.dueDate {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                    Text("Due \(due.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 10)
        .transition(.scale(0.7).combined(with: .opacity))
    }
}
