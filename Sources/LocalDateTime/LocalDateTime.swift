import Foundation

struct LocalDateTime {
    let components: DateComponents
    
    init(year: Int, month: Int, dayOfMonth: Int, hour: Int, minute: Int, second: Int) {
        components = DateComponents(calendar: Calendar.current, year: year, month: month, day: dayOfMonth, hour: hour, minute: minute, second: second)
    }
    
    init() {
        components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
    }
}
