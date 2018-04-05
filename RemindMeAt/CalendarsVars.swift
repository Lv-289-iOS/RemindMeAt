//
//  CalendarsVars.swift
//  RemindMeAt
//
//  Created by Володимир Смульський on 2/22/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation

let date = Date()
let date2 = NSDate()

let calendar = Calendar.current

let day = calendar.component(.day, from: date) 
let weekday = calendar.component(.weekday,from: date ) 
var month = calendar.component(.month, from: date) - 1
var year = calendar.component(.year, from: date)
