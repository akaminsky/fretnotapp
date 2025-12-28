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
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    // MARK: - Practice Reminders

    func schedulePracticeReminders(frequency: ReminderFrequency, time: Date) {
        cancelPracticeReminders()

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        guard let hour = components.hour, let minute = components.minute else {
            return
        }

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
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "practiceReminder",
            "practiceReminder_first",
            "practiceReminder_repeat"
        ])
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
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "addSongReminder",
            "addSongReminder_first",
            "addSongReminder_repeat"
        ])
    }

    // MARK: - General Methods

    func cancelAllReminders() {
        cancelPracticeReminders()
        cancelAddSongReminders()
    }

    func rescheduleIfNeeded() {
        // Practice reminders
        let practiceEnabled = UserDefaults.standard.bool(forKey: "practiceRemindersEnabled")
        if practiceEnabled {
            let frequencyRaw = UserDefaults.standard.string(forKey: "practiceReminderFrequency") ?? ReminderFrequency.everyOtherDay.rawValue
            let frequency = ReminderFrequency(rawValue: frequencyRaw) ?? .everyOtherDay
            let time = UserDefaults.standard.object(forKey: "practiceReminderTime") as? Date ?? getDefaultReminderTime()
            schedulePracticeReminders(frequency: frequency, time: time)
        } else {
            cancelPracticeReminders()
        }

        // Add song reminders
        let addSongEnabled = UserDefaults.standard.bool(forKey: "addSongRemindersEnabled")
        if addSongEnabled {
            let frequencyRaw = UserDefaults.standard.string(forKey: "addSongReminderFrequency") ?? ReminderFrequency.weekly.rawValue
            let frequency = ReminderFrequency(rawValue: frequencyRaw) ?? .weekly
            let time = UserDefaults.standard.object(forKey: "addSongReminderTime") as? Date ?? getDefaultReminderTime()
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
                    print("Error scheduling \(identifier): \(error)")
                }
            }

        case .everyOtherDay:
            // Schedule first notification at the specified time
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            // Get next occurrence of this time
            let now = Date()
            guard let nextOccurrence = calendar.nextDate(after: now, matching: dateComponents, matchingPolicy: .nextTime) else {
                return
            }

            let firstTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let firstRequest = UNNotificationRequest(identifier: "\(identifier)_first", content: content, trigger: firstTrigger)
            notificationCenter.add(firstRequest) { error in
                if let error = error {
                    print("Error scheduling first \(identifier): \(error)")
                }
            }

            // Schedule repeating every 48 hours
            let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 48 * 60 * 60, repeats: true)
            let repeatRequest = UNNotificationRequest(identifier: "\(identifier)_repeat", content: content, trigger: intervalTrigger)
            notificationCenter.add(repeatRequest) { error in
                if let error = error {
                    print("Error scheduling repeat \(identifier): \(error)")
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
                    print("Error scheduling \(identifier): \(error)")
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
            "What songs are you working on? Add them here 🎶",
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
