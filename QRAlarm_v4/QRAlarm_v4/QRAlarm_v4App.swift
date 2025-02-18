//
//  QRAlarm_v4App.swift
//  QRAlarm_v4
//
//  Created by ごんざれす on 2024/07/15.
//

import SwiftUI

@main
struct QRAlarm_v4App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var selectedWeekdays = [Int]()

    var body: some Scene {
        WindowGroup {
            WeekdaysView(weekdays: $selectedWeekdays)
                //.environmentObject(appDelegate)
            print(selectedWeekdays)
        }
    }}
