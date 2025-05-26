//
//  EditExpenseView.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//

import SwiftUI
import CoreData



struct EditExpenseView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var expense: Expense

    @State private var nazev: String = ""
    @State private var castka: String = ""
    @State private var vybranaKategorie: String = "Jídlo"
    @State private var datum: Date = Date()

    let kategorie = ["Jídlo", "Doprava", "Ostatní", "Zábava"]

    var barvyKategorie: [String: Color] = [
        "Jídlo": .red,
        "Doprava": .blue,
        "Ostatní": .gray,
        "Zábava": .green
    ]

    var body: some View {
        Form {
            Section(header: Text("Detaily výdaje")) {
                Text("Editace: \(expense.nazev ?? "nil")")

                TextField("Název", text: $nazev)
                TextField("Částka", text: $castka)
                    .keyboardType(.decimalPad)

                Picker("Kategorie", selection: $vybranaKategorie) {
                    ForEach(kategorie, id: \.self) { kat in
                        HStack {
                            Circle()
                                .fill(barvyKategorie[kat] ?? .black)
                                .frame(width: 12, height: 12)
                            Text(kat)
                        }
                        .tag(kat)
                    }
                }
                DatePicker("Datum", selection: $datum, displayedComponents: .date)
            }

            Section {
                Button("Uložit změny") {
                    expense.nazev = nazev
                    expense.castka = Double(castka) ?? 0.0
                    expense.kategorie = vybranaKategorie
                    expense.datum = datum

                    do {
                        try moc.save()
                        dismiss()
                    } catch {
                        print("Chyba ukládání: \(error.localizedDescription)")
                    }
                }
                .disabled(nazev.isEmpty || Double(castka) == nil)
            }
        }
        .onAppear {
            print("Editace: ", expense.nazev ?? "nil")
            nazev = expense.nazev ?? ""
            castka = String(format: "%.2f", expense.castka)
            vybranaKategorie = expense.kategorie ?? "Jídlo"
            datum = expense.datum ?? Date()
        }
        .navigationTitle("Upravit výdaj")
        .navigationBarTitleDisplayMode(.inline)
    }
}
