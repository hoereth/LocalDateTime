import Foundation

public protocol LocalDateType {
    var year: Int { get }
    var month: Int { get }
    var day: Int { get }
    
    var linearTimestamp: Double { get }
}

/// Performance considerations: class members which do calendar calculations are marked as "computationally expensive" and should only be called if necesary.
public struct LocalDate: LocalDateType, Equatable, Comparable, CustomStringConvertible, CustomDebugStringConvertible, Hashable, Encodable, Decodable, Sendable {
    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        lhs.linearTimestamp < rhs.linearTimestamp
    }
    
    public var debugDescription: String {
        formatted()
    }
    
    public var description: String {
        formatted()
    }
    
    static let calendarComponents: Set<Calendar.Component> = [.year, .month, .day]
    
    public let components: DateComponents
    
    /// This timestamp has only "ordered" semantics
    public var linearTimestamp: Double {
        Double(day) + 31.0 * (Double(month) + 12.0 * Double(year))
    }
    
    /// Initializes LocalDate with given date and time components.
    public init(year: Int, month: Int, day: Int) {
        components = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
    }
    
    public init(_ date: Date = Date(), timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        components = calendar.dateComponents(Self.calendarComponents, from: date)
    }
    
    /// calls "asDate" => expensive computation!
    /// - Parameters:
    ///   - calendar: Might affect the result. (e.g. calendar week number)
    public func dateComponent(calendar: Calendar = Calendar.current, component: Calendar.Component) -> Int {
        let components = calendar.dateComponents([component], from: asDate())
        return components.value(for: component)!
    }
    
    public func startOfYear() -> LocalDate {
        return LocalDate(year: components.year!, month: 1, day: 1)
    }
    
    public func endOfYear() -> LocalDate {
        return LocalDate(year: components.year!, month: 12, day: 31)
    }
    
    /// calls "asDate" => expensive computation!
    public func localDate(calendar: Calendar = Calendar.current, byAdding component: Calendar.Component, value: Int, wrappingComponents: Bool = false) -> LocalDate {
        let newDate = calendar.date(byAdding: component, value: value, to: asDate())!
        return LocalDate(newDate)
    }
    
    /// expensive computation!
    public func asDate(_ timeZone: TimeZone = TimeZone(secondsFromGMT:0)!) -> Date {
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
    
    public func isSameDay(_ other: LocalDate) -> Bool {
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
    
    //
    // MARK: Compact ISO-Coding Style, e.g. "2022-12-08T07:15:00"
    //

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        
        self.init(isoString: string)
    }
    
    public init(isoString: String) {
        let year, month, day: Int
        
        let dateParts = isoString.split(separator: "-")
        
        guard dateParts.count == 3 else {
            fatalError("cannot parse datePart of isoString")
        }
        
        year = Int(dateParts[0]) ?? 0
        month = Int(dateParts[1]) ?? 0
        day = Int(dateParts[2]) ?? 0
        
        self.init(year: year, month: month, day: day)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(asISO())
    }
    
    public func asISO() -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    public func formatted(_ locale: Locale = .current, style: DateFormatter.Style = .short) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self.asDate())
    }
}

public struct LocalDateRange {
    public let from: LocalDate
    public let to: LocalDate
    
    public init(from: LocalDate, to: LocalDate) {
        self.from = from
        self.to = to
    }
    
    public func intersectWith(other: LocalDateRange) -> LocalDateRange? {
        guard from <= to else { return nil }
        guard other.from <= other.to else { return nil }
        
        let latestStart = max(from, other.from)
        let earliestEnd = min(to, other.to)
        
        guard latestStart <= earliestEnd else { return nil }
        
        return LocalDateRange(from: latestStart, to: earliestEnd)
    }
}
