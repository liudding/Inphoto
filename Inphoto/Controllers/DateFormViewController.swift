//
//  DateFormViewController.swift
//  Inphoto
//
//  Created by liuding on 2018/11/25.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Eureka

protocol DateFormViewControllerDelegate: NSObjectProtocol {
    func dateFormVC(didSelectDate selectedDate: Date?)
}


class DateFormViewController: FormViewController {

    var originDatetime = Date()
    private var newDate: Date?
    
    weak var delegate: DateFormViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let formatter = DateFormatter()
//        formatter.dateStyle = .full
//        formatter.timeStyle = .long
        
        let strDate = DateFormatter.localizedString(from: originDatetime, dateStyle: .full, timeStyle: .medium)


        form +++ Section() {
            $0.header = HeaderFooterView(stringLiteral: "原始时间：\(strDate)")
            $0.footer = HeaderFooterView(stringLiteral: "")
            }
            
            <<< DateInlineRow { row in
                row.title = "日期"
                row.tag = "date"
                row.maximumDate = Date()
                row.value = originDatetime
                row.dateFormatter?.dateStyle = .full
                }.onChange({ [weak self] (row) in
                    self?.datetimeChanged()
                })
            
            <<< TimeInlineRow { row in
                row.title = "时间"
                row.tag = "time"
                row.value = originDatetime
                }.onChange({ [weak self] (row) in
                    self?.datetimeChanged()
                })
    }
    
    private func datetimeChanged() {
        let dateRow = form.rowBy(tag: "date") as! DateInlineRow
        let timeRow = form.rowBy(tag: "time") as! TimeInlineRow
        
        let date = dateRow.value
        let time = timeRow.value
        
        guard let _ = date, let _ = time else {
            return
        }
        
        newDate = Date.datetime(date: date!, time: time!)
        
        updateFooterText(of: timeRow.section!)
    }
    
    private func updateFooterText(of section: Section) {

        let interval = newDate!.timeIntervalSinceReferenceDate - originDatetime.timeIntervalSinceReferenceDate

        let formatter = DateComponentsFormatter()
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 6
        formatter.unitsStyle = .abbreviated
        formatter.calendar = Calendar.autoupdatingCurrent

        let formatedInterval = formatter.string(from: interval) ?? ""
        
        section.footer?.title = "原始照片将调整：\(formatedInterval)"
        section.reload()
    }

    @IBAction func onTapDone(_ sender: Any) {
        
        delegate?.dateFormVC(didSelectDate: newDate)
        
        dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        newDate = nil
        dismiss(animated: true) {
            
        }
    }
}
