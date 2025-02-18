import SwiftUI

struct WeekdaysView: View {
    @Binding var weekdays: [Int]

    var body: some View {
        List {
            ForEach(0..<7, id: \.self) { day in
                HStack {
                    Text(WeekdaysView.weekdaysText[day])
                    Spacer()
                    if weekdays.contains(day) {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    if let index = weekdays.firstIndex(of: day) {
                        weekdays.remove(at: index)
                    } else {
                        weekdays.append(day)
                    }
                }
            }
        }
        .navigationBarTitle("繰り返し", displayMode: .inline)
    }

    static let weekdaysText = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]

    static func repeatText(weekdays: [Int]) -> String {
        if weekdays.isEmpty {
            return "しない"
        }
        if weekdays.count == 7 {
            return "毎日"
        }
        let sortedWeekdays = weekdays.sorted()
        return sortedWeekdays.map { weekdaysText[$0] }.joined(separator: " ")
    }
}

struct ParentView: View {
    @State private var selectedWeekdays = [Int]()
    
    var body: some View {
        WeekdaysView(weekdays: $selectedWeekdays)
    }
}

struct WeekdaysView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
