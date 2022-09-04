# LocalDateTime

## Description

This package introduces a real local date/time data type to iOS. It is based on DateComponents for easy converting between Date and LocalDateTime. Technically, a LocalDateTime is just wrapping a DateComponents object. However, it asserts that year, month, day, hour, minute and second components are always set.

## Why not just Date()?

In Swift, a Date() is just one 64-bit floating point number counting the number of seconds as a relative offset from the reference date of January 1, 2001 at 00:00:00 UTC. In other languages, such a type would rather be called "timestamp". And such timestamps are not suitable for representing local dates for a number of reasons:

- A timestamp will always have to be interpreted in the context of a time zone in order to extract local date and time information. 
