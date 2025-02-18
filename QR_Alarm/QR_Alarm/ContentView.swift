import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var alarms: [CustomAlarm] = CustomAlarm.allAlarms.sorted(by: { $0.time < $1.time })
    @State private var showAddEditView = false
    @State private var selectedAlarm: CustomAlarm?
    @State private var tappedAlarm: CustomAlarm?
    @State private var showInformationView = false
    @State private var showStartupInformation = true

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(alarms.indices, id: \.self) { index in
                        let alarm = alarms[index]
                        ZStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(alarm.time, style: .time)
                                        .font(.largeTitle)
                                        .bold()
                                    Text(alarm.label.isEmpty ? "アラーム" : alarm.label)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Toggle("", isOn: $alarms[index].isOn)
                                    .labelsHidden()
                                    .onChange(of: alarms[index].isOn) { newValue in
                                        /*
                                        if newValue {
                                            print("アラームがオンになりました: \(alarm.id.uuidString)")
                                            scheduleAlarm(for: alarm)
                                        } else {
                                            print("アラームがオフになりました: \(alarm.id.uuidString)")
                                            cancelAlarm(for: alarm)
                                        }
                                         CustomAlarm.saveAlarms(alarms)
                                        */
                                        print("トグルでの変更が適用されているか:\(alarm.isOn)")
                                        updateAlarm(alarm)
                                    }
                            }
                            .padding()
                            .background(tappedAlarm == alarm ? Color(UIColor.systemGray5) : Color(UIColor.systemBackground))
                            .cornerRadius(10)

                            HStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if tappedAlarm != alarm {
                                            tappedAlarm = alarm
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                tappedAlarm = nil
                                                selectedAlarm = alarm
                                                showAddEditView = true
                                            }
                                        }
                                    }
                                Spacer(minLength: 44) // ON/OFFボタンの部分を除外
                            }
                        }
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            indexSet.forEach { index in
                                if index < alarms.count {
                                    cancelAlarm(for: alarms[index])
                                    alarms.remove(atOffsets: indexSet)
                                }
                            }
                            CustomAlarm.saveAlarms(alarms)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("アラーム")
                .navigationBarItems(trailing: HStack {
                    if !appDelegate.showWakeUpView {
                        Button(action: {
                            showInformationView = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .sheet(isPresented: $showInformationView) {
                            InformationView()
                        }
                        Button(action: {
                            selectedAlarm = CustomAlarm(time: Date(), isOn: true, barcode: nil, label: "", isActive: true)
                            showAddEditView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                })
                .fullScreenCover(isPresented: $showAddEditView) {
                    NavigationView {
                        AddEditAlarmView(alarm: Binding(
                            get: { selectedAlarm ?? CustomAlarm(time: Date(), isOn: true, barcode: nil, label: "", isActive: true) },
                            set: { selectedAlarm = $0 }
                        ), onSave: {updatedAlarm in
                            updateAlarm(updatedAlarm)
                            print("更新アラームがisOnか:\(updatedAlarm.isOn)")
                            
                            /*
                            updatedAlarm in
                            if let index = alarms.firstIndex(where: { $0.id == updatedAlarm.id }) {
                                alarms[index] = updatedAlarm
                                print("アラームが更新されました: \(updatedAlarm.id.uuidString)")
                                cancelAlarm(for: updatedAlarm)
                                scheduleAlarm(for: updatedAlarm)
                            } else {
                                alarms.append(updatedAlarm)
                                print("アラームが追加されました: \(updatedAlarm.id.uuidString)")
                                scheduleAlarm(for: updatedAlarm)
                            }
                            alarms.sort(by: { $0.time < $1.time }) // Sort alarms by time
                            CustomAlarm.saveAlarms(alarms)*/
                            showAddEditView = false
                        })
                    }
                }

                if appDelegate.showWakeUpView {
                    WakeUpView(stopAlarm: {
                        appDelegate.stopAlarm()
                    })
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onAppear {
            alarms = CustomAlarm.allAlarms.sorted(by: { $0.time < $1.time }) // Sort alarms by time
            print("Loaded alarms: \(alarms.map { $0.id.uuidString })")
            if showStartupInformation {
                showInformationView = true
                showStartupInformation = false
            }
        }
    }

    private func scheduleAlarm(for alarm: CustomAlarm) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = alarm.label.isEmpty ? "アラームが鳴っています" : alarm.label
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: alarm.soundName ?? "alarm_sound.mp3"))
        content.userInfo = ["id": alarm.id.uuidString]
        
        let now = Date()
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alarm.time)
        let currentCalendar = Calendar.current
        var alarmTime = currentCalendar.date(from: triggerDate) ?? Date()
        triggerDate.second = 0;

        // 現在の時刻よりも過去の場合、翌日に設定
        if alarmTime < now {
            triggerDate.day = (triggerDate.day ?? 0) + 1
            alarmTime = currentCalendar.date(from: triggerDate) ?? alarmTime
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            } else {
                print("Notification scheduled: \(alarm.id.uuidString) at \(triggerDate)")
            }
        }

        let interval = alarmTime.timeIntervalSince(now)
        if interval > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                triggerAlarm(alarm: alarm)
            }
            print("アラームがスケジュールされました: \(alarm.id.uuidString) at \(alarmTime)")
        } else {
            print("アラーム時刻が現在時刻より過去のためスケジュールされませんでした: \(alarm.id.uuidString)")
        }
    }


    private func cancelAlarm(for alarm: CustomAlarm) {
        print("アラームがキャンセルされました: \(alarm.id.uuidString)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }

    private func triggerAlarm(alarm: CustomAlarm) {
        print("アラームがトリガーされました: \(alarm.id.uuidString)")
        appDelegate.currentAlarm = alarm
        appDelegate.showWakeUpView = true
        appDelegate.startAlarm(for: alarm)
    }
    
    func updateAlarm(_ alarm: CustomAlarm) {
        //同じidのアラームがあるか確認
            if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                //アラームの時間に変更が加えられているかチェック
                if alarms[index].time != alarm.time {
                    //加えられてたら更新し、アラームのisOnをtrueに
                    alarms[index] = alarm
                    alarms[index].isOn = true
                    //アラームを変更通りにスケジューリングする
                    scheduleAlarm(for: alarms[index])
                } else if alarms[index].isOn != alarm.isOn {
                    //加えられていないがアラームのisOnステータスに変更があった場合
                    alarms[index] = alarm
                    //アラームがONになった場合
                    if alarm.isOn {
                        scheduleAlarm(for: alarms[index])
                    } else {
                        cancelAlarm(for: alarms[index])
                    }
                }
            } else {
                alarms.append(alarm)
                scheduleAlarm(for: alarm)
            }
        alarms.sort(by: { $0.time < $1.time }) // Sort alarms by time
        CustomAlarm.saveAlarms(alarms)
        }
}
