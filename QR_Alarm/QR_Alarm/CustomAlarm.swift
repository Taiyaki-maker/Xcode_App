/*
import Foundation

struct CustomAlarm: Identifiable, Codable, Equatable {
    var id: UUID
    var time: Date
    var isOn: Bool
    var barcode: String?
    var label: String
    var isActive: Bool
    var soundName: String?

    init(id: UUID = UUID(), time: Date, isOn: Bool, barcode: String?, label: String, isActive: Bool) {
        self.id = id
        self.time = time
        self.isOn = isOn
        self.barcode = barcode
        self.label = label
        self.isActive = isActive
    }

    static var allAlarms: [CustomAlarm] {
        get {
            if let data = UserDefaults.standard.data(forKey: "alarms"),
               let alarms = try? JSONDecoder().decode([CustomAlarm].self, from: data) {
                return alarms
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "alarms")
            }
        }
    }

    static func saveAlarms(_ alarms: [CustomAlarm]) {
        allAlarms = alarms
    }
}
*/

import Foundation

struct CustomAlarm: Identifiable, Codable, Equatable {
    var id: UUID
    var time: Date
    var isOn: Bool
    var barcode: String?
    var label: String
    var isActive: Bool
    var soundName: String?

    init(id: UUID = UUID(), time: Date, isOn: Bool, barcode: String?, label: String, isActive: Bool, soundName: String? = "alarm_sound.mp3") {
        self.id = id
        self.time = time
        self.isOn = isOn
        self.barcode = barcode
        self.label = label
        self.isActive = isActive
        self.soundName = soundName
    }

    static var allAlarms: [CustomAlarm] {
        get {
            if let data = UserDefaults.standard.data(forKey: "alarms"),
               let alarms = try? JSONDecoder().decode([CustomAlarm].self, from: data) {
                return alarms
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "alarms")
            }
        }
    }

    static func saveAlarms(_ alarms: [CustomAlarm]) {
        allAlarms = alarms
    }
}
