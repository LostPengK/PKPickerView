//
//  SwiftTestViewController.swift
//  PKPickView
//
//  Created by pengkang on 2020/8/18.
//  Copyright © 2020 pengkang. All rights reserved.
//

import UIKit

class SwiftTestViewController: UIViewController,PKPickerViewDataSource,PKPickerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        addPicker()
    }
    
    func addPicker() {
        let picker = PKPickerView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 200))
        view.addSubview(picker)
        picker.dalegate = self
        picker.dataSource = self
        picker.leftMargin = 15
        picker.reloadAllComponents()
        for i in 0...9 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 * Double(i) ) {
                picker.selectRow(5 * i, component: i, animated: true)
            }
        }
    }

}

extension SwiftTestViewController {
    
    func rowHeightForPKPickerView(_ pickerView: PKPickerView) -> CGFloat {
        return 40
    }
    
    func numberOfComponents(_ pickerView: PKPickerView) -> NSInteger {
        return 10
    }
    
    func widthForComponent(_ pickerView: PKPickerView, for component: NSInteger) -> CGFloat {
        return  (self.view.frame.size.width - 30 )/10.0
    }
    
    func numberOfRowsInComponent(_ pickerView: PKPickerView, for component: NSInteger) -> NSInteger {
        return 50
    }
    
    func titleForRowInPKPickerView(_ pickerView: PKPickerView, for row: NSInteger, for component: NSInteger) -> String {
        return "\(row)"
    }
    
    func viewSeparatorlineColorForPKPickerView(_ pickerView: PKPickerView) -> UIColor {
        return .red
    }
    
    func didSelectRow(_ pickerView: PKPickerView, row: NSInteger, component: NSInteger) {
        
    }
}
