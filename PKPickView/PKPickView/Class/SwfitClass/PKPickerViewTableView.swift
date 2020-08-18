//
//  PKPickerViewTableView.swift
//  PKPickView
//
//  Created by pengkang on 2020/8/17.
//  Copyright © 2020 pengkang. All rights reserved.
//

import UIKit

class PKPickerViewTableView: UITableView {

    public var data: NSMutableArray = []
    public var isScrollDown: Bool = false
    public var lastContentOffsetY: CGFloat = 0
    public var selectRow: NSInteger = 0
    public var index: NSInteger = 0

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initSubviews()
    }

    private func  initSubviews(){
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
