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
    /* Digital crown */
    @State var scrollAmount = 0.0
    @State private var prevScrollAmount = 0.0
    
    @State private var clock = 0
    @State private var interval = 5
    
    private func createAndStartWorkout() {
        let healthStore = HKHealthStore()
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        do {
            let session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
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
    
    var body: some View {
        /* Have a single text object show the interval */
        Text(String(interval))
            .focusable(true)
            .digitalCrownRotation(
                $scrollAmount,
                from: -5,
                through: 50,
                by: 1,
                sensitivity: .medium,
                isHapticFeedbackEnabled: true
            )
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if scrollAmount == prevScrollAmount {
                        /* Increment the clock */
                        clock += 1
                        
                        /* Set interval from scrollAmount */
                        interval = Int(scrollAmount) + 5
                        
                        if clock >= interval {
                            /* Do a buzz */
                            WKInterfaceDevice.current().play(.success)
                            
                            /* Reset the clock */
                            clock = 0
                        }
                    } else {
                        /* We scrolled so reset the clock */
                        clock = 0
                        prevScrollAmount = scrollAmount
                    }
                }
                
                /* Create and start the workout so we can run in the background */
                if HKHealthStore.isHealthDataAvailable() {
                    createAndStartWorkout()
                }
            }
        
    }
}

