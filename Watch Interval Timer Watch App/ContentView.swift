//
//  ContentView.swift
//  Watch Interval Timer Watch App
//
//  Created by Edward Banner on 3/31/23.
//

import SwiftUI
import WatchKit
import HealthKit

struct ContentView: View {
    @State var scrollAmount = 0.0
    @State private var clock = 0.0
    @State private var timer: Timer?
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: scrollAmount, repeats: true) { _ in
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    
    var body: some View {
        Text("Timer: \(scrollAmount+5) Clock: \(clock)")
            .focusable(true)
            .digitalCrownRotation(
                $scrollAmount,
                from: -5,
                through: 50,
                by: 1,
                sensitivity: .low,
                isHapticFeedbackEnabled: true
            )
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    clock += 1
                    
                    let limit = scrollAmount + 5
                    
                    if clock >= limit {
                        WKInterfaceDevice.current().play(.success)
                        clock = 0
                    }
                }
                
                if HKHealthStore.isHealthDataAvailable() {
                    let healthStore = HKHealthStore()
                    let configuration = HKWorkoutConfiguration()
                    configuration.activityType = .running
                    configuration.locationType = .outdoor
                    
                    do {
                        
                        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
                        let builder = session.associatedWorkoutBuilder()
                        builder.dataSource = HKLiveWorkoutDataSource(
                            healthStore: healthStore,
                            workoutConfiguration: configuration
                        )
                        
                        session.startActivity(with: Date())
                        builder.beginCollection(withStart: Date()) { (success, error) in
                            
                            guard success else {
                                return // Handle errors.
                            }
                            
                            // Indicate that the session has started.
                        }
                    } catch {
                        return // Handle failure here.
                    }
                } 
            }
        
    }
}

