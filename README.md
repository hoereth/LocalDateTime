# LocalDateTime

## Description

This package introduces a real local date/time data type to iOS. It is based on [DateComponents](https://developer.apple.com/documentation/foundation/datecomponents) for easy converting between [Date](https://developer.apple.com/documentation/foundation/date) and LocalDateTime. Technically, a LocalDateTime is just wrapping a [DateComponents](https://developer.apple.com/documentation/foundation/datecomponents) object. However, it asserts that year, month, day, hour, minute and second components are always set.

## Why not just use Date()?

In Swift, a [Date](https://developer.apple.com/documentation/foundation/date) is just one 64-bit floating point number counting the number of seconds as a relative offset from the reference date of January 1, 2001 at 00:00:00 UTC. In other programming languages, such a type would rather be called "timestamp". Those timestamps are tied to the UTC timezone. If you need to handle local data, you need to add the local time zone.

| Example                  | point in time?  |  time zone required? |
|--------------------------|----------------------------------|--|
| AFL kickoff broadcast    | ✅ | UTC is fine, it will have to be converted in everybody's local time zone anyway |
| New Year's fireworks     | ❌ | ❌ no, the local time is same for everyone |
| train departure          | ✅ | ✅ train station's time zone |
| last modified data       | ✅ | ❌ no, as it will never be shown to the user |

When you are required to handle local data (point in time + local time zone), there are many ways of implementing, but the choice between a "timestamp" and a more "readable" style seems to be a fundamental one. Let's have a look at some examples...

### Local Date/Time Representations

|                          | Timestamp Style                          | Readable Style          |
|--------------------------|------------------------------------------|-------------------------------|
| Database Representation  | TIMESTAMP + global DB time zone setting  | DATETIME            |
| JSON Representation      | Integer + time zone (server default?)    | String ([ISO 8601](https://en.wikipedia.org/wiki/ISO_8601))             |
| Java Types               | Date() + TimeZone()                      | LocalDateTime() + TimeZone()  |
| Java Types               | Date() + TimeZone()                      | ZonedDateTime()               |
| Swift Types              | [Date](https://developer.apple.com/documentation/foundation/date) + [TimeZone](https://developer.apple.com/documentation/foundation/timezone)                      | String ([ISO 8601](https://en.wikipedia.org/wiki/ISO_8601))             |
| Swift Types              | [Date](https://developer.apple.com/documentation/foundation/date) + [TimeZone](https://developer.apple.com/documentation/foundation/timezone)                      | ❓ + [TimeZone](https://developer.apple.com/documentation/foundation/timezone)  |

### Local Date/Time Aspects

You might ask yourself a few questions:

| Question                 | Timestamp Style                          | Readable Style                |
|--------------------------|------------------------------------------|-------------------------------|
| Will there be much sorting / indexing by date/time?               | ✅  | ⚠️ (expensive computations)                |
| Is it about a technical time which will NEVER be shown to the user? | ✅  | ❌ (not necessary)            |
| Will it be shown to the user?               | ⚠️ (expensive computations)        | ✅ |
| Do you prefer to use just one attribute?   | ❌ (not possible) | ✅ (it's possible) |
| Are you required to use [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)? | ❌ (not possible)  | ✅ |

### Conclusion

We like to have a choice of how to implement local date/time information. Swift lacks a readable option so far. You can combine [LocalDateTime()](Sources/LocalDateTime/LocalDateTime.swift) with the [TimeZone](https://developer.apple.com/documentation/foundation/timezone) data type to become time zone aware.
