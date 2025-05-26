//
//  ContentView.swift
//  Expenses
//
//  Created by Dominik Horký on 22.01.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExpensesView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Výdaje")
                }
            
            StatistikyView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistiky")
                }
            
            NastaveniView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Nastavení")
                }
        }
    }
}


#Preview {
    ContentView()
}
