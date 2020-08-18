//
//  PKPickerView.swift
//  PKPickView
//
//  Created by pengkang on 2020/8/17.
//  Copyright © 2020 pengkang. All rights reserved.
//

import UIKit

class PKPickerView: UIView, UITableViewDelegate, UITableViewDataSource {

    weak var dalegate: PKPickerViewDelegate?
    weak var dataSource: PKPickerViewDataSource?
    
    public var leftMargin: CGFloat? = 0
    
    private let tableArrs: NSMutableArray = []

    private lazy var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    
    private lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        return line
    }()
    
    private var cellHeight: CGFloat = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews(){
        self.clipsToBounds = true
        self.addSubview(topLine)
        self.addSubview(bottomLine)
    }
    
}
extension PKPickerView{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let row = self.dataSource?.numberOfRowsInComponent(self, for: (tableView as! PKPickerViewTableView).index){
            return row
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let table = tableView as! PKPickerViewTableView
        let cell:PKPickerViewTableCell = tableView.dequeueReusableCell(withIdentifier: "PKPickerViewTableCell", for: indexPath) as! PKPickerViewTableCell
        
        if let view = self.dataSource?.viewForRowInPKPickerView?(self, for: indexPath.row, for: table.index){
            cell.cellView = view
            return cell
        }
        
        cell.cellView = nil;
        
        if let attributeStr = self.dataSource?.attributedTitleForRowInPKPickerView?(self, for: indexPath.row, for: table.index){
            cell.label.attributedText = attributeStr
            return cell
        }
        
        cell.label.attributedText = nil;
        
        if let str = self.dataSource?.titleForRowInPKPickerView?(self, for: indexPath.row, for: table.index){
            cell.label.text = str
            return cell
        }
        
       
        cell.label.text = nil;
        return cell;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  let height = dataSource?.rowHeightForPKPickerView(self) {
            return height
        }
        return cellHeight
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let originOffset = -self.frame.size.height/2.0
        let index = (scrollView.contentOffset.y - originOffset)/self.cellHeight;
        let row = Int(index)
        let tableView = scrollView as! PKPickerViewTableView
        tableView.selectRow = row
        self.dalegate?.didSelectRow(self, row: row, component: tableView.index)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let tableView = scrollView as! PKPickerViewTableView
        adjustCenter(tableView,animated: true)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let tableView = scrollView as! PKPickerViewTableView
        let originOffset = -self.frame.size.height/2.0
        let index = (targetContentOffset.pointee.y - originOffset)/self.cellHeight;
        let row = Int(index)
        var targetIndex = row

        if (Float(index) - floorf(Float(index)) >= 0.5) {
            targetIndex = row + 1
        }

        if let num = self.dataSource?.numberOfRowsInComponent(self, for: tableView.index) {
            if targetIndex > num - 1 {
                targetIndex -= 1
            }
            var offset: CGFloat = self.cellHeight/2.0

            if tableView.isScrollDown {
                offset = -self.cellHeight/2.0
            }
            let y = CGFloat(targetIndex) * cellHeight + originOffset +  offset
            targetContentOffset.pointee.y = y
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! PKPickerViewTableView
        tableView.isScrollDown = tableView.contentOffset.y - tableView.lastContentOffsetY < 0
        tableView.lastContentOffsetY = tableView.contentOffset.y
    }
    
    func adjustCenter(_ tableView: PKPickerViewTableView, animated: Bool) {
        let y = cellHeight * CGFloat(tableView.selectRow) - tableView.contentInset.top
        tableView.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }
}

extension PKPickerView{
    
    public func reloadAllComponents(){
        if let height = self.dataSource?.rowHeightForPKPickerView(self){
            cellHeight = height
        }
        
        let scale: CGFloat = UIScreen.main.scale
        
        topLine.frame = CGRect(x: 0, y: self.frame.size.height/2.0 - self.cellHeight/2.0, width: self.frame.size.width, height: 1/scale)
        bottomLine.frame = CGRect(x:0, y:self.frame.size.height/2.0 + self.cellHeight/2.0, width:self.frame.size.width, height: 1/scale)
        
        if let color = self.dataSource?.viewSeparatorlineColorForPKPickerView?(self) {
            topLine.backgroundColor = color
            bottomLine.backgroundColor = color
        }
        
        for view in tableArrs {
            let table = view as! PKPickerViewTableView
            table.removeFromSuperview()
        }
        self.tableArrs.removeAllObjects()
        
        if let component = self.dataSource?.numberOfComponents(self){
            if component == 0{
                return
            }
            
            if component > tableArrs.count{
                for i in tableArrs.count...component-1 {
                    let table = PKPickerViewTableView(frame: .zero, style: .plain)
                    table.index = i
                    table.delegate = self
                    table.dataSource = self
                    table.contentInset = UIEdgeInsets(top: self.frame.height/2.0 - self.cellHeight/2.0, left: 0, bottom: self.frame.size.height/2.0 - self.cellHeight/2.0, right: 0)
                    table.separatorStyle = .none
                    table.showsVerticalScrollIndicator = false
                    table.showsHorizontalScrollIndicator = false
                    let cell = "PKPickerViewTableCell"
                    table.register(PKPickerViewTableCell.self , forCellReuseIdentifier: cell)
                    table.clipsToBounds = true
                    addSubview(table)
                    tableArrs.add(table)
                }
            }
        }
        
        bringSubviewToFront(topLine)
        bringSubviewToFront(bottomLine)
        
        var leftSpace = self.leftMargin ?? 0
        let width = frame.size.width/CGFloat(tableArrs.count)
        for view in tableArrs {
            let tableView = view as! PKPickerViewTableView
            var tableWidth = width
            if let ww = self.dataSource?.widthForComponent(self, for: tableView.index){
                tableWidth = ww
            }
            let height = frame.height
            let frame = CGRect(x: leftSpace, y: 0, width: tableWidth, height: height)
            tableView.frame = frame
            leftSpace += tableWidth
        }
        
        for table in tableArrs {
            (table as! PKPickerViewTableView).reloadData()
        }
    }
    
    public func reloadComponent(_ component: NSInteger) {
        if (component >= self.tableArrs.count || component < 0) {
            return
        }
        let tableView = self.tableArrs[component] as! PKPickerViewTableView
        tableView.reloadData()
    }
    
    public func selectRow(_ row: NSInteger, component:NSInteger, animated:Bool ) {
        if (component >= self.tableArrs.count || component < 0) {
            return
        }
        var rowNumber = row
        
        let tableView = self.tableArrs[component] as! PKPickerViewTableView
        if let number = self.dataSource?.numberOfRowsInComponent(self, for: component) {
            
            let warning = "selected row can be large than max rows number \(number)"
            assert(row >= 0, "selected row can be < 0")
            assert(row < number , warning);
            
            if rowNumber < 0 {
                rowNumber = 0
            }else if(row > number - 1){
                rowNumber = number
            }
            tableView.selectRow = row
            self.adjustCenter(tableView,animated: animated)
        }
    }
    
    public func selectedRowInComponent(_ component:NSInteger) -> NSInteger{
        
        if (component >= self.tableArrs.count || component < 0) {
            return 0
        }
        let tableView = self.tableArrs[component] as! PKPickerViewTableView
        return tableView.selectRow
    }
}

@objc protocol PKPickerViewDelegate {
    @objc func didSelectRow(_ pickerView: PKPickerView,row: NSInteger, component: NSInteger)
}

@objc protocol PKPickerViewDataSource {
    
    @objc func numberOfComponents(_ pickerView: PKPickerView) -> NSInteger
    
    @objc func numberOfRowsInComponent(_ pickerView: PKPickerView,for component: NSInteger) -> NSInteger
    
    @objc func rowHeightForPKPickerView(_ pickerView: PKPickerView) -> CGFloat
    
    @objc func widthForComponent(_ pickerView: PKPickerView,for component: NSInteger) -> CGFloat
    
    @objc optional func titleForRowInPKPickerView(_ pickerView: PKPickerView,for row: NSInteger, for component: NSInteger) -> String
    
    @objc optional func attributedTitleForRowInPKPickerView(_ pickerView: PKPickerView,for row: NSInteger, for component: NSInteger) -> NSAttributedString
    
    @objc optional func viewForRowInPKPickerView(_ pickerView: PKPickerView,for row: NSInteger, for component: NSInteger) -> UIView
    
    @objc optional func viewSeparatorlineColorForPKPickerView(_ pickerView: PKPickerView) -> UIColor
}
