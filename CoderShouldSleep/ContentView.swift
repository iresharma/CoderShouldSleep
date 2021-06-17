//
//  ContentView.swift
//  CoderShouldSleep
//
//  Created by iresh sharma on 17/06/21.
//

import SwiftUI
import EventKit

struct ContentView: View {
    
    @State private var wakeDate = Date()
    @State private var amountSleep = 8.0
    @State private var nCoffee = 2
    @State private var err = false
    @State private var calcDone = false
    
    @State private var sleepDate = DateComponents()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        DatePicker("When do you wanna wake up ?", selection: $wakeDate, in: Date()...Date().addingTimeInterval(86400), displayedComponents: .hourAndMinute)
                        Stepper(value: $amountSleep, in: 4...12, step: 0.25) {
                            Text("Sleep for \(amountSleep, specifier: "%g") hours")
                        }
                    }
                    Section(header: Text("No. of coffee cups per day")) {
                        Stepper(value: $nCoffee, in: 1...20) {
                            Text(nCoffee > 1 ? "\(nCoffee) cups" : "1 cup").fontWeight(.black)
                        }
                    }
                }
                if calcDone {
                    Text("You should sleep at:")
                        .font(.title3)
                        .padding(.bottom)
                    Text("\(sleepDate.hour ?? 00) : \(sleepDate.minute ?? 00)")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.green)
                        .padding(.bottom)
                    Button(action: alarm, label: {
                        HStack {
                            Image(systemName: "hourglass.badge.plus")
                            Text("Add Alarm")
                        }
                    })
                }
            }
            .navigationTitle("BetterSleep")
            .navigationBarItems(trailing: Button(action: self.calc, label: {
                Text("Calc")
            }))
        }.alert(isPresented: $err) {
            Alert(title: Text("Error"), message: Text("Some error occured"), dismissButton: .default(Text("ok")))
        }
    }
    
    func calc() {
        let model = BetterSleep()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeDate)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        let seconds = hour + minute
        do {
            let prediction = try model.prediction(input: BetterSleepInput(wake: Double(seconds), estimatedSleep: amountSleep, coffee: Double(nCoffee)))
            
            let sleepTime = wakeDate - prediction.actualSleep
            
            sleepDate = Calendar.current.dateComponents([.hour, .minute], from: sleepTime)
            calcDone = true
        } catch {
            err = true
        }
    }
    
    func alarm() {
        
//        Cerating notification
        let notification = UNMutableNotificationContent()
        notification.title = "TIme to sleep"
        notification.body = "To get a sleep of \(amountSleep) hours, you need to sleep now"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: sleepDate, repeats: false)
        
        let uuidString = UUID().uuidString
        let noti = UNNotificationRequest(identifier: uuidString, content: notification, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            if (error != nil) {
                err = true
            }
            center.add(noti) {
                print("\(String(describing: $0))")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
