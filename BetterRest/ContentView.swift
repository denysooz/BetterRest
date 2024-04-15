//
//  ContentView.swift
//  BetterRest
//
//  Created by Denis Dareuskiy on 24.02.24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var sleepTime = Date()
    let coffeeRange = 1...20



    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(coffeeRange, id: \.self) { cup in
                            Text("\(cup)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle()) // You can use any picker style that suits your needs
                    Text("^[\(coffeeAmount) cup](inflect: true)")
                }
                Section("Recommended bedtime") {
                    Text(sleepTime.formatted(date: .omitted, time: .shortened))
                }
            }.navigationTitle("BetterRest")
        }
        .onChange(of: wakeUp, perform: { _ in
            calculateSleepTime()
        })
        .onChange(of: sleepAmount, perform: { _ in
            calculateSleepTime()
        })
        .onChange(of: coffeeAmount, perform: { _ in
            calculateSleepTime()
        })
    }
    private func calculateSleepTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            sleepTime = wakeUp - prediction.actualSleep
        } catch {
            // Handle the error, e.g., display an alert or update an error state.
            print("Error: \(error)")
        }
    }
}


#Preview {
    ContentView()
}
