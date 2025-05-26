//
//  AddExpensesView.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//




import SwiftUI

struct AddExpensesView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @State private var nazev: String = ""
    @State private var castka: String = ""
    @State private var vybranaKategorie: String = "Jídlo"
    @State private var showCategorySheet = false
    
    let kategorie = ["Jídlo", "Doprava", "Zábava", "Ostatní"]
    let barvyKategorie: [String: Color] = [
        "Jídlo": .red,
        "Doprava": .blue,
        "Zábava": .green,
        "Ostatní": .gray
    ]
    
    @State private var datum: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detaily výdaje")) {
                    TextField("Název", text: $nazev)
                    TextField("Částka", text: $castka)
                        .keyboardType(.decimalPad)
                    Picker("Kategorie", selection: $vybranaKategorie) {
                        ForEach(kategorie, id: \.self) { kat in
                            Text(kat).tag(kat)
                        }
                    }
                    DatePicker("Datum", selection: $datum, displayedComponents: .date)
                }

                Section {
                    Button(action: {
                        let newExpense = Expense(context: moc)
                        newExpense.id = UUID()
                        newExpense.nazev = nazev
                        newExpense.castka = Double(castka) ?? 0.0
                        newExpense.kategorie = vybranaKategorie
                        newExpense.datum = datum

                        do {
                            try moc.save()
                            dismiss()
                        } catch {
                            print("Chyba při ukládání: \(error.localizedDescription)")
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Přidat výdaj")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Nový výdaj")
        }
    }
}

#Preview {
    AddExpensesView()
}


#Preview {
    AddExpensesView()
}
