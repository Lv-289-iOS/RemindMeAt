//
//  RMACalendarVC.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/7/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit

class RMACalendarVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var Calendar: UICollectionView!
    
    @IBOutlet weak var MonthLable: UILabel!
    
    let Month = ["January","February","March","April","May","June","July","August","September","October","November","December"]

    let DayInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    let curentWeek = (second : 7, third : 14, fourth : 21, fifth : 28)
    let chosenMonth = (current : 0, next : 1, previous : -1)
    
    
    var currentMonth = String()
    
    var NumberOfEmphtyBox = Int()
    var NextNumberOfEmphtyBox = Int()
    var PreviousNumberOfEmphtyBox = Int()
    
    var DirectionOfMonth = 1 // position of mounth
    var PositionIndex = 0 // emthy boxes
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMonth = Month[month]
        MonthLable.text = "\(currentMonth)\(year)"
    }
    
    
    
    @IBAction func BackButton(_ sender: Any) {
        switch currentMonth {
        case "January":
            month = 11
            year -= 1
            DirectionOfMonth = -1
            
            GetStartDayPositon()
            
            currentMonth = Month[month]
            MonthLable.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        default:
            month -= 1
            DirectionOfMonth = -1
            
            GetStartDayPositon()
            
            currentMonth = Month[month]
            MonthLable.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        }
    }
    
    @IBAction func NextButton(_ sender: Any) {
        switch currentMonth {
        case "December":
            month = 0
            year += 1
            DirectionOfMonth = 1
            currentMonth = Month[month]
            
            GetStartDayPositon()
            
            MonthLable.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        default:
            
            DirectionOfMonth = 1
            
            GetStartDayPositon()
            month += 1
            currentMonth = Month[month]
            MonthLable.text = "\(currentMonth)\(year)"
            Calendar.reloadData()
        }

    }
    
    func GetStartDayPositon(){ // give number of emphty boxes
        switch DirectionOfMonth {
        case chosenMonth.current:
            switch day {
            case 1...7:
                NumberOfEmphtyBox = weekday - day
            case 8...14:
                NumberOfEmphtyBox = weekday - day - curentWeek.second
            case 15...21:
                NumberOfEmphtyBox = weekday - day - curentWeek.third
            case 22...28:
                NumberOfEmphtyBox = weekday - day - curentWeek.fourth
            case 29...31:
                NumberOfEmphtyBox = weekday - day - curentWeek.fifth
            default:
                break
            }
            PositionIndex = NumberOfEmphtyBox
        case chosenMonth.next:  // next month
            
            NextNumberOfEmphtyBox = (PositionIndex + DayInMonth[month] % 7)
            PositionIndex = NextNumberOfEmphtyBox
            
        case chosenMonth.previous:  // previos month
            PreviousNumberOfEmphtyBox = (7 - (DayInMonth[month] - PositionIndex) % 7)
            if PreviousNumberOfEmphtyBox == 7 {
                PreviousNumberOfEmphtyBox = 0
            }
            PositionIndex = PreviousNumberOfEmphtyBox
            
        default:
            fatalError("It is error in GetStartDayPositon function")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch DirectionOfMonth { // number of days + emphty boxes
        case chosenMonth.current:
            return DayInMonth[month] + NumberOfEmphtyBox
        case chosenMonth.next:
            return DayInMonth[month] + NextNumberOfEmphtyBox
        case chosenMonth.previous:
            return DayInMonth[month] + PreviousNumberOfEmphtyBox
        default:
            fatalError()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if currentMonth == Month[calendar.component(.month, from:date ) - 1] && year == calendar.component(.year, from: date) && indexPath.row + 1 == day {
            cell.backgroundColor = UIColor.red
        }  else if RMARealmManager.isTasksAvailableByDate(date as NSDate) {
            cell.backgroundColor = .yellow } else {

            cell.backgroundColor = .gray
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! CalendarDataCollectionViewCell
        
        cell.DateLable.textColor = UIColor.black
        
        if cell.isHidden == true {
            cell.isHidden = false
        }
        
        
        // draw in cell
        switch DirectionOfMonth {
        case 0:
            cell.DateLable.text = "\(indexPath.row + 1 - NumberOfEmphtyBox)"
        case 1:
            cell.DateLable.text = "\(indexPath.row + 1 - NextNumberOfEmphtyBox)"
        case -1:
            cell.DateLable.text = "\(indexPath.row + 1 - PreviousNumberOfEmphtyBox)"
        default:
            fatalError("Error in cell drawing.")
        }

        
        if Int(cell.DateLable.text!)! < 1 {
            cell.isHidden = true
        }
        
        
//        if component == chosenDrum.Levels.rawValue {
//            pickerView.reloadComponent(chosenDrum.Cards.rawValue)
//        }

        switch indexPath.row {
        case 5,6,12,13,19,20,26,27,33,34:
            if Int(cell.DateLable.text!)! > 0 {
                cell.DateLable.textColor = UIColor.blue
            }
        default:
            break
        }
        return cell
    }
}
