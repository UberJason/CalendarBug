//
//  ViewController.swift
//  CalendarBug
//
//  Created by Ji,Jason on 4/12/17.
//  Copyright © 2017 Capital One Labs. All rights reserved.
//

import UIKit
import JTAppleCalendar
import DateToolsSwift

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.minimumLineSpacing = 0.0
        calendarView.minimumInteritemSpacing = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        calendarView.scrollToDate(Date(year: 2017, month: 4, day: 12))
    }
}

extension ViewController : JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let calendarCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        
        let labelText = date.startOfDay == Date().startOfDay ? "Today" : (date.day == 1 ? dateFormatter.string(from: date) : cellState.text)
        calendarCell.dateLabel.text = labelText
        
        return calendarCell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date(year: 2016, month: 5, day: 1)
        let endDate = Date(year: 2017, month: 4, day: 30)
        let numberOfRows = 6
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, generateInDates: .forFirstMonthOnly, generateOutDates: .tillEndOfRow, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
    }
    
}


extension Date {
    var startOfMonth: Date {
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month, .hour], from: Calendar.current.startOfDay(for: self))
        return Calendar.current.date(from: comp)!
    }

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
}
