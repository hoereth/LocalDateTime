import Foundation

/// Performance considerations: class members which do calendar calculations are marked as "computationally expensive" and should only be called if necesary.
public struct LocalDateTime: LocalDateType, Equatable, Comparable, CustomStringConvertible, CustomDebugStringConvertible, Hashable, Codable, Sendable {
    public static func < (lhs: LocalDateTime, rhs: LocalDateTime) -> Bool {
        lhs.linearTimestamp < rhs.linearTimestamp
    }
    
    public var debugDescription: String {
        asISO()
    }
    
    public var description: String {
        asISO()
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
    
    public init(_ date: Date, timeZone: TimeZone) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
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
                        let hourWithoutZero = hour == 0 ? 12 : hour
                        return String(format: "%02d:%02d ㏂", hourWithoutZero, minute)
                    } else {
                        let h12 = hour - 12
                        let hourWithoutZero = h12 == 0 ? 12 : h12
                        return String(format: "%02d:%02d ㏘", hourWithoutZero, minute)
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
    public func asDate(_ timeZone: TimeZone) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
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
    
    //
    // MARK: Compact ISO-Coding Style, e.g. "2022-12-08T07:15:00"
    //

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        
        self.init(isoString: string)
    }
    
    public init(isoString: String) {
        let dateTime = isoString.components(separatedBy: "T")
        guard dateTime.count == 2 else {
            fatalError("cannot parse isoString")
        }
        
        let year, month, day, hour, minute, second: Int
        
        let dateParts = dateTime[0].split(separator: "-")
        
        guard dateParts.count == 3 else {
            fatalError("cannot parse datePart of isoString")
        }
        
        year = Int(dateParts[0]) ?? 0
        month = Int(dateParts[1]) ?? 0
        day = Int(dateParts[2]) ?? 0
        
        let timeParts = dateTime[1].split(separator: ":")
        
        guard timeParts.count == 3 else {
            fatalError("cannot parse timePart of isoString")
        }

        hour = Int(timeParts[0]) ?? 0
        minute = Int(timeParts[1]) ?? 0
        second = Int(timeParts[2]) ?? 0
        
        self.init(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(asISO())
    }
    
    public func asISO() -> String {
        String(format: "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day, hour, minute, second)
    }
}

public struct LocalDateTimeRange {
    public let from: LocalDateTime
    public let to: LocalDateTime
    
    public init(from: LocalDateTime, to: LocalDateTime) {
        self.from = from
        self.to = to
    }
    
    public func intersectWith(other: LocalDateTimeRange) -> LocalDateTimeRange? {
        guard from <= to else { return nil }
        guard other.from <= other.to else { return nil }
        
        let latestStart = max(from, other.from)
        let earliestEnd = min(to, other.to)
        
        guard latestStart <= earliestEnd else { return nil }
        
        return LocalDateTimeRange(from: latestStart, to: earliestEnd)
    }
}
