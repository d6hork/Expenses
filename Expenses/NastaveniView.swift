//
//  NastaveniView.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//
import SwiftUI

struct NastaveniView: View {
    @State private var categories: [String] = []
    @State private var newCategoryName: String = ""
    
    private let userDefaultsKey = "userCategories"
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(categories.indices, id: \.self) { index in
                        TextField("Kategorie", text: $categories[index])
                            .onChange(of: categories[index]) { _ in
                                saveCategories()
                            }
                    }
                    .onDelete(perform: deleteCategory)
                }
                
                HStack {
                    TextField("Nová kategorie", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addCategory) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Kategorie")
            .toolbar {
                EditButton()
            }
            .onAppear(perform: loadCategories)
        }
    }
    
    private func loadCategories() {
        if let saved = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            categories = saved
        } else {
            categories = ["Jídlo", "Doprava", "Ostatní", "Zábava"]
        }
    }
    
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: userDefaultsKey)
    }
    
    private func addCategory() {
        let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        categories.append(trimmed)
        newCategoryName = ""
        saveCategories()
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        saveCategories()
    }
}

#Preview {
    NastaveniView()
}
