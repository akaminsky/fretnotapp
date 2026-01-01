//
//  NotificationManager.swift
//  GuitarSongbook
//
//  Manages local notifications for practice reminders
//

import Foundation
import UserNotifications

enum ReminderFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case everyOtherDay = "Every Other Day"
    case weekly = "Weekly"
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            print("📱 Notification permission granted: \(granted)")
            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error)")
            return false
        }
    }

    // MARK: - Practice Reminders

    func schedulePracticeReminders(frequency: ReminderFrequency, time: Date) {
        print("📅 Scheduling practice reminders - Frequency: \(frequency.rawValue), Time: \(time)")
        cancelPracticeReminders()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        guard let hour = components.hour, let minute = components.minute else {
            print("❌ Invalid time components")
            return
        }

        print("⏰ Scheduling for \(hour):\(String(format: "%02d", minute))")

        let content = UNMutableNotificationContent()
        content.title = "Time to practice! 🎸"
        content.body = getPracticeMessage()
        content.sound = .default

        scheduleNotification(
            identifier: "practiceReminder",
            content: content,
            frequency: frequency,
            hour: hour,
            minute: minute
        )
    }

    func cancelPracticeReminders() {
        // Cancel single identifier
        var identifiers = ["practiceReminder"]

        // Cancel all every-other-day notifications
        for dayOffset in stride(from: 0, through: 60, by: 2) {
            identifiers.append("practiceReminder_\(dayOffset)")
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 Cancelled practice reminders")
    }

    // MARK: - Add Song Reminders

    func scheduleAddSongReminders(frequency: ReminderFrequency, time: Date) {
        cancelAddSongReminders()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        guard let hour = components.hour, let minute = components.minute else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to update your songbook! 🎸"
        content.body = getAddSongMessage()
        content.sound = .default

        scheduleNotification(
            identifier: "addSongReminder",
            content: content,
            frequency: frequency,
            hour: hour,
            minute: minute
        )
    }

    func cancelAddSongReminders() {
        // Cancel single identifier
        var identifiers = ["addSongReminder"]

        // Cancel all every-other-day notifications
        for dayOffset in stride(from: 0, through: 60, by: 2) {
            identifiers.append("addSongReminder_\(dayOffset)")
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 Cancelled add song reminders")
    }

    // MARK: - General Methods

    func cancelAllReminders() {
        cancelPracticeReminders()
        cancelAddSongReminders()
    }

    func rescheduleIfNeeded() {
        // Practice reminders - default to true if key doesn't exist
        let practiceEnabled = UserDefaults.standard.object(forKey: "practiceRemindersEnabled") as? Bool ?? true
        print("🔄 Reschedule - Practice enabled: \(practiceEnabled)")

        if practiceEnabled {
            let frequencyRaw = UserDefaults.standard.string(forKey: "practiceReminderFrequency") ?? ReminderFrequency.everyOtherDay.rawValue
            let frequency = ReminderFrequency(rawValue: frequencyRaw) ?? .everyOtherDay
            let timeInterval = UserDefaults.standard.object(forKey: "practiceReminderTime") as? TimeInterval
            let time = timeInterval != nil ? Date(timeIntervalSince1970: timeInterval!) : getDefaultReminderTime()
            schedulePracticeReminders(frequency: frequency, time: time)
        } else {
            cancelPracticeReminders()
        }

        // Add song reminders - default to true if key doesn't exist
        let addSongEnabled = UserDefaults.standard.object(forKey: "addSongRemindersEnabled") as? Bool ?? true
        print("🔄 Reschedule - Add song enabled: \(addSongEnabled)")

        if addSongEnabled {
            let frequencyRaw = UserDefaults.standard.string(forKey: "addSongReminderFrequency") ?? ReminderFrequency.weekly.rawValue
            let frequency = ReminderFrequency(rawValue: frequencyRaw) ?? .weekly
            let timeInterval = UserDefaults.standard.object(forKey: "addSongReminderTime") as? TimeInterval
            let time = timeInterval != nil ? Date(timeIntervalSince1970: timeInterval!) : getDefaultReminderTime()
            scheduleAddSongReminders(frequency: frequency, time: time)
        } else {
            cancelAddSongReminders()
        }
    }

    // MARK: - Private Helper Methods

    private func scheduleNotification(
        identifier: String,
        content: UNMutableNotificationContent,
        frequency: ReminderFrequency,
        hour: Int,
        minute: Int
    ) {
        let calendar = Calendar.current

        switch frequency {
        case .daily:
            // Schedule for same time every day
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling \(identifier): \(error)")
                } else {
                    print("✅ Scheduled daily notification \(identifier) for \(hour):\(String(format: "%02d", minute))")
                }
            }

        case .everyOtherDay:
            // Schedule notification for every 2 days at the specified time
            // We need to schedule multiple notifications (iOS limits repeating calendar notifications)
            let calendar = Calendar.current
            let now = Date()

            // Schedule notifications for the next 60 days (30 notifications, every other day)
            for dayOffset in stride(from: 0, through: 60, by: 2) {
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute

                guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now),
                      let nextOccurrence = calendar.nextDate(after: targetDate, matching: dateComponents, matchingPolicy: .nextTime),
                      nextOccurrence > now else {
                    continue
                }

                let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextOccurrence), repeats: false)
                let request = UNNotificationRequest(identifier: "\(identifier)_\(dayOffset)", content: content, trigger: trigger)
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling \(identifier) day \(dayOffset): \(error)")
                    }
                }
            }

        case .weekly:
            // Schedule for same time/day each week
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = calendar.component(.weekday, from: Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling \(identifier): \(error)")
                } else {
                    print("✅ Scheduled weekly notification \(identifier) for weekday \(dateComponents.weekday ?? 0) at \(hour):\(String(format: "%02d", minute))")
                }
            }
        }
    }

    private func getPracticeMessage() -> String {
        let messages = [
            "Your guitar is waiting",
            "Ready to play some songs? 🎶",
            "Pick up your guitar 🎸",
            "Your guitar misses you! 😔",
            "Guitar calling! 📱→🎸"
        ]
        return messages.randomElement() ?? "Time to practice!"
    }

    private func getAddSongMessage() -> String {
        let messages = [
            "Learned something new? Add it to your songbook 📝",
            "What songs are you working on? Don't forget to add them 🎶",
            "Keep growing your collection! Add more songs 🎵",
            "New songs to add? 📝 Update your songbook"
        ]
        return messages.randomElement() ?? "Time to update your songbook!"
    }

    private func getDefaultReminderTime() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 19  // 7:00 PM
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
}
