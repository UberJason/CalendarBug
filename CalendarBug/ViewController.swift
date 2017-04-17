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

public enum CalendarState {
    case compressed, expanded
    
    var calendarHeight: CGFloat {
        switch self {
        case .compressed: return 80
        case .expanded: return 240
        }
    }
    
    var visibleRowCount: Int {
        switch self {
        case .compressed: return 2
        case .expanded: return 6
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    var calendarState: CalendarState = .compressed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.minimumLineSpacing = 0.0
        calendarView.minimumInteritemSpacing = 0.0
        
        calendarView.scrollToDate(Date(year: 2017, month: 4, day: 12))
        calendarView.selectDates([Date(year: 2017, month: 4, day: 12)])
    }

    @IBAction func toggleTapped(_ sender: Any) {
        toggleCalendarAnimated()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("at start, selected dates: \(calendarView.selectedDates)")
    }
    
    func toggleCalendarAnimated() {
        switch calendarState {
        case .compressed: calendarState = .expanded
        case .expanded: calendarState = .compressed
        }
        
        let animationDuration = 0.25
        let completionDuration = 0.2
        
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                self.calendarView.alpha = 0.0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                self.calendarHeightConstraint.constant = self.calendarState.calendarHeight
                self.view.layoutIfNeeded()
            }
        }, completion: { (finished) in
            
            let selectedDate = self.calendarView.selectedDates.first
            self.calendarView.reloadData(with: self.calendarView.selectedDates.first) {
                print("in completion handler, selected dates: \(self.calendarView.selectedDates)")
                if let selectedDate = selectedDate {
                    self.calendarView.scrollToDate(selectedDate, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: .bottom, completionHandler: nil)
                }
            }
            
            UIView.animate(withDuration: completionDuration) {
                self.calendarView.alpha = 1.0
            }
        })
    }

}

extension ViewController : JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let calendarCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        
        let labelText = date.startOfDay == Date().startOfDay ? "Today" : (date.day == 1 ? dateFormatter.string(from: date) : cellState.text)
        calendarCell.dateLabel.text = labelText
        calendarCell.backgroundColor = cellState.isSelected ? .red : nil
        
        return calendarCell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date(year: 2016, month: 5, day: 1)
        let endDate = Date(year: 2017, month: 4, day: 30)
        let numberOfRows = calendarState.visibleRowCount
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
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
