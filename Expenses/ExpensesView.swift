//
//  ExpensesView.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//
import SwiftUI
import CoreData

struct ExpensesView: View {
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.datum, ascending: false)]
    ) var expenses: FetchedResults<Expense>

    @State private var showAddExpense = false
    @State private var showEditExpense = false
    @State private var selectedExpense: Expense?

    let barvyKategorie: [String: Color] = [
        "Jídlo": .red,
        "Doprava": .blue,
        "Ostatní": .gray,
        "Zábava": .green
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(expenses) { expense in
                    HStack {
                        Circle()
                            .fill(barvyKategorie[expense.kategorie ?? ""] ?? .black)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text(expense.nazev ?? "Neznámý výdaj")
                                .font(.headline)
                            Text(expense.kategorie ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("- Kč \(expense.castka, specifier: "%.2f")")
                            .foregroundColor(.red)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedExpense = expense
                        showEditExpense = true
                    }
                }
                .onDelete(perform: deleteExpenses)
            }
            .navigationTitle("Historie mých výdajů")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpensesView()
                    .environment(\.managedObjectContext, moc)
            }
            .sheet(isPresented: $showEditExpense) {
                if let expenseToEdit = selectedExpense {
                    EditExpenseView(expense: expenseToEdit)
                        .environment(\.managedObjectContext, moc)
                }
            }
        }
    }

    func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expenseToDelete = expenses[index]
            moc.delete(expenseToDelete)
        }
        do {
            try moc.save()
        } catch {
            print("Chyba při mazání: \(error.localizedDescription)")
        }
    }
}
#Preview {
    ExpensesView()
}
