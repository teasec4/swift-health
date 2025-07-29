//
//  ReminderMode.swift
//  HealthV3
//
//  Created by Максим Ковалев on 7/29/25.
//

import Foundation

enum ReminderMode: String, CaseIterable, Identifiable, Equatable {
    case rare
    case frequent
    
    var id: String { rawValue }
}
