//
//  SettingsSheetView.swift
//  Bondify
//
//  Created by Kuba Milcarz on 5/29/24.
//

import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Label("More settings to come", systemImage: "gear")
                        .disabled(true)
                }
                
                VStack(spacing: 5) {
                    Image(.appIconPreview)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 100*2/9))
                    
                    Text("Bondify")
                        .font(.headline)
                    
                    Text("© Kuba Milcarz 2024")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(ZStack {
                    Image(.appIconPreview)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .blur(radius: 20)
                        .opacity(0.5)
                    
                    Rectangle().fill(.ultraThinMaterial)
                })
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Dismiss", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SettingsSheetView()
}
