//
//  RadarMarkerView.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 4/4/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Charts

public class RadarMarkerView: MarkerView {
    
    @IBOutlet weak var label: UILabel!
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height - 7.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label.text = "\(entry.data as! Double)"
        layoutIfNeeded()
    }
}
