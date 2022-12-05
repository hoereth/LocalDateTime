import Foundation

/// Performance considerations: class members which do calendar calculations are marked as "computationally expensive" and should only be called if necesary.
public struct LocalDateTime: Equatable, Comparable, CustomDebugStringConvertible, Hashable, Codable {
    public static func < (lhs: LocalDateTime, rhs: LocalDateTime) -> Bool {
        lhs.linearTimestamp < rhs.linearTimestamp
    }
    
    public var debugDescription: String {
        return components.debugDescription
    }
    
    static let calendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    
    public let components: DateComponents
    
    /// This timestamp has only "ordered" semantics
    public var linearTimestamp: Double {
        Double(second) + 60.0 * (Double(minute) + 60.0 * (Double(hour) + 24.0 * (Double(day) + 31.0 * (Double(month) + 12.0 * Double(year)))))
    }
    
    /// Initializes LocalDateTime with given date and time components.
    public init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    /// Initializes LocalDateTime with current date.
    public init(hour: Int, minute: Int = 0, second: Int = 0) {
        let current = Calendar.current.dateComponents(in: .current, from: Date())
        components = DateComponents(year: current.year, month: current.month, day: current.day, hour: hour, minute: minute, second: second)
    }
    
    public init(_ date: Date, calendar: Calendar) {
        components = calendar.dateComponents(Self.calendarComponents, from: date)
    }
    
    /// Initializes LocalDateTime with current date and current time.
    public init(_ date: Date) {
        components = Calendar.current.dateComponents(Self.calendarComponents, from: date)
    }
    
    public init() {
        components = Calendar.current.dateComponents(Self.calendarComponents, from: Date())
    }
    
    /// calls "asDate" => expensive computation!
    /// - Parameters:
    ///   - calendar: Might affect the result. (e.g. calendar week number)
    public func dateComponent(calendar: Calendar = Calendar.current, component: Calendar.Component) -> Int {
        let components = calendar.dateComponents([component], from: asDate())
        return components.value(for: component)!
    }
    
    /// aka "startOfDay"
    public func midnight() -> LocalDateTime {
        return LocalDateTime(year: components.year!, month: components.month!, day: components.day!)
    }
    
    public func endOfDay() -> LocalDateTime {
        return LocalDateTime(year: components.year!, month: components.month!, day: components.day!, hour: 23, minute: 59, second: 59)
    }
    
    /// calls "asDate" => expensive computation!
    public func localDateTime(calendar: Calendar = Calendar.current, byAdding component: Calendar.Component, value: Int, wrappingComponents: Bool = false) -> LocalDateTime {
        let newDate = calendar.date(byAdding: component, value: value, to: asDate())!
        return LocalDateTime(newDate)
    }
    
    /// just caches the is24h-value
    private static var is24hCached: Bool?
    /// caches the locale the is24h-value is based on
    private static var is24hCachedLocale: Locale?

    /// Detects if the current locale is set to 1..24 hour cycle.
    private static func is24h() -> Bool {
        let locale = Locale.current
        
        if let cached = is24hCached, locale == is24hCachedLocale {
            return cached
        } else {
            let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)
            let newCacheValue: Bool
            if let containsA = formatStringForHours?.range(of: "a") {
                newCacheValue = containsA.isEmpty
            } else {
                newCacheValue = true
            }
            is24hCached = newCacheValue
            is24hCachedLocale = locale
            return newCacheValue
        }
    }
    
    /// Locale-aware representation of time with minute precision. E.g.: "07:00" or "10:15 AM"
    public var hourMinutes: String {
        get {
            if let hour = components.hour, let minute = components.minute {
                if Self.is24h() {
                    return String(format: "%02d:%02d", hour, minute)
                } else {
                    if hour < 12 {
                        return String(format: "%02d:%02d %@", hour, minute, Calendar.current.amSymbol)
                    } else {
                        return String(format: "%02d:%02d %@", hour - 12, minute, Calendar.current.pmSymbol)
                    }
                }
            } else {
                return ""
            }
        }
    }
    
    /// calls "asDate" => expensive computation!
    public func asDate() -> Date {
        return asDate(TimeZone.current)
    }
    
    /// expensive computation!
    public func asDate(_ timeZone: TimeZone, calendar: Calendar = Calendar.current) -> Date {
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
    
    /// calls "asDate" => expensive computation!
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
