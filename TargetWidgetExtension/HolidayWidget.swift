//
//  HolidayEntry.swift
//  TransparentWidgetsDemo
//
//  Created by Selin Türkoglu on 19.06.25.
//

import WidgetKit
import SwiftUI

// 1. TimelineEntry holds today’s date and optional Feiertags‐name
struct HolidayEntry: TimelineEntry {
    let date: Date
    let holidayName: String?
}

// 2. Provider computes all Feiertage for Bayern, then makes one entry per day
struct HolidayProvider: TimelineProvider {
    func placeholder(in context: Context) -> HolidayEntry {
        HolidayEntry(date: .now, holidayName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (HolidayEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HolidayEntry>) -> Void) {
        let today = Date()
        let entry = makeEntry(for: today)

        // schedule next refresh at next midnight
        var cal = Calendar.current
        cal.timeZone = .current
        let startOfTomorrow = cal.date(byAdding: .day, value: 1,
                                       to: cal.startOfDay(for: today))!

        let timeline = Timeline(entries: [entry],
                                policy: .after(startOfTomorrow))
        completion(timeline)
    }

    // builds the entry: finds today’s holiday name (if any), treats Sundays as holidays
    private func makeEntry(for date: Date) -> HolidayEntry {
        let year = Calendar.current.component(.year, from: date)
        let holidays = bayernHolidays(year: year)
        // check statutory holidays
        var todayName = holidays.first {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }?.name
        // include Sundays as holidays
        let weekday = Calendar.current.component(.weekday, from: date)
        // In Gregorian calendar, weekday == 1 means Sunday
        if todayName == nil && weekday == 1 {
            todayName = "Sonntag"
        }
        return HolidayEntry(date: date, holidayName: todayName)
    }

    // list of all statutory holidays in Bayern
    private func bayernHolidays(year: Int) -> [(date: Date, name: String)] {
        var result: [(Date,String)] = []
        let cal = Calendar.current

        func date(month: Int, day: Int) -> Date? {
            cal.date(from: DateComponents(year: year, month: month, day: day))
        }

        // fixed‐date holidays
        let fixed: [(Int,Int,String)] = [
            (1, 1, "Neujahr"),
            (1, 6, "Heilige Drei Könige"),
            (5, 1, "Tag der Arbeit"),
            (10, 3, "Tag der Deutschen Einheit"),
            (11, 1, "Allerheiligen"),
            (12,25, "1. Weihnachtstag"),
            (12,26, "2. Weihnachtstag")
        ]
        for (m,d,name) in fixed {
            if let d = date(month: m, day: d) {
                result.append((d,name))
            }
        }

        // movable Easter‐based
        guard let easter = Self.easterDate(year: year) else {
            return result
        }
        let offsets: [(Int,String)] = [
            (-2, "Karfreitag"),
            (+1, "Ostermontag"),
            (+39, "Christi Himmelfahrt"),
            (+50, "Pfingstmontag"),
            (+60, "Fronleichnam")
        ]
        for (offset,name) in offsets {
            if let d = cal.date(byAdding: .day, value: offset, to: easter) {
                result.append((d,name))
            }
        }

        return result
    }

    // Meeus/Jones/Butcher algorithm for Western Easter
    private static func easterDate(year: Int) -> Date? {
        var cal = Calendar.current
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19*a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2*e + 2*i - h - k) % 7
        let m = (a + 11*h + 22*l) / 451
        let month = (h + l - 7*m + 114) / 31      // 3=March, 4=April
        let day   = ((h + l - 7*m + 114) % 31) + 1
        let comps = DateComponents(year: year, month: month, day: day)
        return cal.date(from: comps)
    }
}

// 3. SwiftUI view: green if no holiday, red + name otherwise
struct HolidayWidgetEntryView: View {
    let entry: HolidayEntry

    // 1️⃣ Decide which image to show
    private var backgroundImageName: String {
        entry.holidayName != nil
            ? "NormalBackground"
            : "HolidayBackground"
    }
    
    var body: some View {
        ZStack {
            // 2️⃣ Show the chosen image
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .clipped()
                .opacity(0.5)
            
            // 3️⃣ Overlay your text as before
            Text(entry.holidayName.map {
                "Die Läden haben \ngeschlossen, da heute \n\($0) ist."
            } ?? "Die Läden sind heute geöffnet")
            .font(.system(size: 13, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding(8)
        }
    }
}

// 4. Declare the widget and add it to your bundle
struct HolidayWidget: Widget {
    let kind: String = "BayernHolidayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: HolidayProvider()) { entry in
            HolidayWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Bayern: Läden geöffnet?")
        .description("Zeigt an, ob heute ein gesetzlicher Feiertag in Bayern ist.")
        // ← genau hier dranhängen:
        .contentMarginsDisabled()          // entfernt das automatische Padding
        .containerBackgroundRemovable(true) // erlaubt dir volle Transparenz
    }
}
