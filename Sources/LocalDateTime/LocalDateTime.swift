import Foundation

public struct LocalDateTime: Equatable, Comparable, CustomDebugStringConvertible, Hashable {
    public static func < (lhs: LocalDateTime, rhs: LocalDateTime) -> Bool {
        lhs.linearTimestamp < rhs.linearTimestamp
    }
    
    public var debugDescription: String {
        return components.debugDescription
    }
    
    static let calendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    
    public let components: DateComponents
    
    /// This timestamp has only ordered semanctics
    private var linearTimestamp: Int {
        second + 60 * (minute + 60 * (hour + 24 * (day + 31 * (month + 12 * year))))
    }
    
    /// Initialize a `DateComponents`, optionally specifying values for its fields.
    public init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    public init(hour: Int, minute: Int = 0, second: Int = 0) {
        let current = Calendar.current.dateComponents(in: .current, from: Date())
        components = DateComponents(year: current.year, month: current.month, day: current.day, hour: hour, minute: minute, second: second)
    }
    
    public init(date: Date) {
        components = Calendar.current.dateComponents(Self.calendarComponents, from: date)
    }
    
    public init() {
        components = Calendar.current.dateComponents(Self.calendarComponents, from: Date())
    }
    
    public func dateComponent(component: Calendar.Component) -> Int {
        let components = Calendar.current.dateComponents([component], from: asDate())
        return components.value(for: component)!
    }
    
    public func midnight() -> LocalDateTime {
        return LocalDateTime(year: components.year!, month: components.month!, day: components.day!)
    }
    
    public func endOfDay() -> LocalDateTime {
        return LocalDateTime(year: components.year!, month: components.month!, day: components.day!, hour: 23, minute: 59, second: 59)
    }
    
    public func localDateTime(byAdding component: Calendar.Component, value: Int, wrappingComponents: Bool = false) -> LocalDateTime {
        let newDate = Calendar.current.date(byAdding: component, value: value, to: asDate())!
        return LocalDateTime(date: newDate)
    }
    
    public var hourMinutes: String {
        get {
            if let hour = components.hour, let minute = components.minute {
                return String(format: "%02d:%02d", hour, minute)
            } else {
                return ""
            }
        }
    }
    
    public func asDate() -> Date {
        return asDate(TimeZone.current)
    }
    
    /// expensive computation!
    public func asDate(_ timeZone: TimeZone) -> Date {
        let calendar = Calendar.current
        
        var current = calendar.dateComponents(Self.calendarComponents, from: Date())
        
        for component in Self.calendarComponents {
            if let value = components.value(for: component), value != NSDateComponentUndefined {
                current.setValue(value, for: component)
            }
        }
        
        return calendar.date(from: current)!
    }
    
    public func isSameDay(_ other: LocalDateTime) -> Bool {
        return year == other.year && month == other.month && day == other.day
    }
    
    public var isWeekend: Bool {
        get {
            let weekday = Calendar.current.component(.weekday, from: asDate())
            return weekday == 1 || weekday == 7
        }
    }
    
    public var year: Int {
        get {
            components.year!
        }
    }
    
    public var month: Int {
        get {
            components.month!
        }
    }
    
    public var day: Int {
        get {
            components.day!
        }
    }
    
    public var hour: Int {
        get {
            components.hour!
        }
    }
    
    public var minute: Int {
        get {
            components.minute!
        }
    }
    
    public var second: Int {
        get {
            components.second!
        }
    }

}
