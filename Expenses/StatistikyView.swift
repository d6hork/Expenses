import SwiftUI
import CoreData

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadiusFraction: CGFloat = 0.6

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * innerRadiusFraction

        var path = Path()
        path.move(to: CGPoint(
            x: center.x + cos(CGFloat(startAngle.radians - .pi/2)) * radius,
            y: center.y + sin(CGFloat(startAngle.radians - .pi/2)) * radius)
        )
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle - Angle(degrees: 90),
                    endAngle: endAngle - Angle(degrees: 90),
                    clockwise: false)
        path.addLine(to: CGPoint(
            x: center.x + cos(CGFloat(endAngle.radians - .pi/2)) * innerRadius,
            y: center.y + sin(CGFloat(endAngle.radians - .pi/2)) * innerRadius)
        )
        path.addArc(center: center,
                    radius: innerRadius,
                    startAngle: endAngle - Angle(degrees: 90),
                    endAngle: startAngle - Angle(degrees: 90),
                    clockwise: true)
        path.closeSubpath()

        return path
    }
}

struct PieChart: View {
    var slices: [PieSliceData]

    var body: some View {
        ZStack {
            ForEach(0..<slices.count, id: \.self) { i in
                PieSlice(startAngle: slices[i].startAngle,
                         endAngle: slices[i].endAngle,
                         innerRadiusFraction: 0.8)
                    .fill(slices[i].color)
            }
        }
        .frame(width: 250, height: 250)
        .overlay(
            Circle()
                .stroke(Color.black, lineWidth: 4)
        )
        .overlay(
            Circle()
                .stroke(Color.black, lineWidth: 4)
                .scaleEffect(0.8)
        )
        .shadow(color: Color.purple.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}

struct StatistikyView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Expense.entity(),
        sortDescriptors: []
    ) private var expenses: FetchedResults<Expense>

    private let colors: [String: Color] = [
        "Jídlo": .red,
        "Doprava": .blue,
        "Ostatní": .gray,
        "Zábava": .green
    ]

    private var totalSum: Double {
        expenses.reduce(0) { $0 + $1.castka }
    }

    private var expensesByCategory: [String: [Expense]] {
        Dictionary(grouping: expenses, by: { $0.kategorie ?? "Ostatní" })
    }

    var body: some View {
        let slices = calculatePieData()

        ScrollView {
            VStack(spacing: 30) {
                Text("Statistiky výdajů")
                    .font(.title)
                    .bold()

                if slices.isEmpty {
                    Text("Žádné výdaje k zobrazení")
                        .foregroundColor(.secondary)
                } else {
                    ZStack {
                        PieChart(slices: slices)

                        Text("Kč - \(totalSum, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(slices.indices, id: \.self) { i in
                            HStack {
                                Circle()
                                    .fill(slices[i].color)
                                    .frame(width: 16, height: 16)
                                Text(categoryName(for: slices[i]))
                                Spacer()
                                Text("\(percentage(for: slices[i]), specifier: "%.1f") %")
                            }
                        }
                    }
                    .padding(.horizontal, 40)

                    VStack(spacing: 16) {
                        ForEach(expensesByCategory.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(expensesByCategory[category] ?? []) { expense in
                                    HStack {
                                        Circle()
                                            .fill(colors[expense.kategorie ?? "Ostatní"] ?? .black)
                                            .frame(width: 12, height: 12)
                                        Text(expense.nazev ?? "Neznámý výdaj")
                                        Spacer()
                                        Text("Kč \(expense.castka, specifier: "%.2f")")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func calculatePieData() -> [PieSliceData] {
        let categorySums = Dictionary(grouping: expenses, by: { $0.kategorie ?? "Ostatní" })
            .mapValues { $0.reduce(0) { $0 + $1.castka } }

        let total = categorySums.values.reduce(0, +)
        guard total > 0 else { return [] }

        var slices: [PieSliceData] = []
        var startAngle = Angle(degrees: 0)

        for (category, sum) in categorySums {
            let degrees = 360 * (sum / total)
            let endAngle = startAngle + Angle(degrees: degrees)
            let color = colors[category] ?? .black
            slices.append(PieSliceData(startAngle: startAngle, endAngle: endAngle, color: color))
            startAngle = endAngle
        }
        return slices
    }

    private func categoryName(for slice: PieSliceData) -> String {
        colors.first(where: { $0.value == slice.color })?.key ?? "Jiné"
    }

    private func percentage(for slice: PieSliceData) -> Double {
        let degrees = slice.endAngle.degrees - slice.startAngle.degrees
        return (degrees / 360) * 100
    }
}

#Preview {
    StatistikyView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
