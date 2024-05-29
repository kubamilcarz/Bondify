//
//  ContentView.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var model = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            if model.tabs.isEmpty == false {
                ScrollViewReader { value in
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(model.tabs) { tab in
                                TabDetailView(tab: tab)
                                    .environmentObject(model)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                    .tag(tab)
                                    .id(tab)
                            }
                        }
                        .scrollTargetLayout()
                        .onChange(of: model.activeTab) {
                            withAnimation { value.scrollTo(model.activeTab) }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                }
                .ignoresSafeArea()
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    ContentUnavailableView("No Tabs", systemImage: "archivebox", description: Text("Get started by tapping the button below."))
                        
                    Button {
                        model.isShowingNewTabSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus")
                            
                            Text("New Tab")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding()
                .ignoresSafeArea()
            }
                
            if model.tabs.isEmpty == false {
                ZStack(alignment: .trailing) {
                    Button {
                        model.newItemTab = model.activeTab
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .fontWeight(.medium)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .frame(width: 55, height: 55)
                            .background(model.activeTab?.tabColor.gradient ?? Color.accent.gradient)
                            .clipShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .offset(x: -15, y: -85)
                    
                    tabBar
                }
            }
        }
        .onAppear {
            model.loadTabs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                model.activeTab = model.tabs.first
            }
        }
        .confirmationDialog("Are you sure?", isPresented: .constant(model.deleteTab != nil), actions: {
            Button("Delete", role: .destructive) {
                model.delete()
            }
        })
        .confirmationDialog("Are you sure?", isPresented: .constant(model.deleteItem != nil), actions: {
            Button("Delete", role: .destructive) {
                model.delete()
            }
        })
        .sheet(isPresented: $model.isShowingNewTabSheet) {
            model.loadTabs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    model.activeTab = model.tabs.first
                }
            }
        } content: {
            TabSheetView(mode: .new)
        }
        .sheet(item: $model.newItemTab) { tab in
            ItemSheetView(tab: tab, mode: .new)
        }
        .sheet(item: $model.editItem) { item in
            ItemSheetView(item: item, mode: .edit)
        }
        .sheet(item: $model.editTab) {
            model.loadTabs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    model.activeTab = model.tabs.first
                }
            }
        } content: { tab in
            TabSheetView(tab: tab, mode: .edit)
        }
        .sheet(isPresented: $model.isShowingSettings) {
            SettingsSheetView()
        }
    }
    
    
    @ViewBuilder
    private var tabBar: some View {
        if model.tabs.isEmpty == false {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(model.tabs) { tab in
                        Button {
                            model.activeTab = tab
                        } label: {
                            Icon(tab: tab)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 5)
                        .contextMenu {
                            Button(tab.isPinned ? "Unpin" : "Pin", systemImage: tab.isPinned ? "pin.slash.fill" : "pin.fill") {
                                model.togglePin(for: tab)
                            }
                            
                            Button("Edit", systemImage: "pencil") {
                                model.editTab = tab
                            }
                            
                            Divider()
                            
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                model.deleteTab = tab
                            }
                        }
                        .padding(.vertical, -5)
                    }
                    
                    Button {
                        model.isShowingNewTabSheet = true
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: "square.dotted")
                                .resizable()
                                .symbolRenderingMode(.hierarchical)
                                .symbolVariant(.fill)
                                .scaledToFit()
                                .frame(height: 20)
                                .overlay(Image(systemName: "plus").font(.caption).fontWeight(.medium))
                            
                            Text("New")
                                .font(.system(.subheadline, design: .serif))
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxHeight: 44)
                        .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 15, alignment: .center)
                        .background(.background.opacity(0.01), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 5)
                }
                .scrollTargetLayout()
            }
            .padding(.top, 5)
            .frame(maxWidth: .infinity)
            .scrollTargetBehavior(.paging)
            .contentMargins(15, for: .scrollContent)
            .scrollBounceBehavior(.basedOnSize)
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
        } else {
            HStack {
                
            }
            .padding(.top, 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial.shadow(.drop(color: .black.opacity(0.07), radius: 3, y: -3)), ignoresSafeAreaEdges: .all)
        }
    }
    
    
    private func Icon(tab: Tab) -> some View {
        VStack(spacing: 5) {
            Image(systemName: tab.tabIcon)
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .symbolVariant(.fill)
                .scaledToFit()
                .frame(height: 20)
            
            Text(tab.tabTitle)
                .font(.system(.subheadline, design: .serif))
                .minimumScaleFactor(0.9)
        }
        .foregroundStyle(model.activeTab == tab ? .accent : .secondary)
        .frame(maxHeight: 44)
        .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 15, alignment: .center)
        .background(.background.opacity(0.01), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ContentView()
}
