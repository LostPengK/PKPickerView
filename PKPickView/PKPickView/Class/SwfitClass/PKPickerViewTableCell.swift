//
//  PKPickerViewTableCell.swift
//  PKPickView
//
//  Created by pengkang on 2020/8/17.
//  Copyright © 2020 pengkang. All rights reserved.
//

import UIKit

class PKPickerViewTableCell: UITableViewCell {

    public lazy var label: UILabel = {
        let textlabel = UILabel()
        textlabel.textAlignment = .center
        return textlabel
    }()
    
    public var cellView:UIView? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refresh()
        label.frame = bounds
    }
    
    private func refresh(){
        if let cview = cellView {
            contentView.addSubview(cview)
            cview.center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
            label.removeFromSuperview()
        }
        contentView.addSubview(label)
    }
    

}
