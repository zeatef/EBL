//
//  LineMarkerView3.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 5/17/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Charts

public class LineMarkerView3: MarkerView {
    
    @IBOutlet weak var teamLabel1: UILabel!
    @IBOutlet weak var teamLabel2: UILabel!
    
    @IBOutlet weak var statLabel1: UILabel!
    @IBOutlet weak var statLabel2: UILabel!
    @IBOutlet weak var statLabel3: UILabel!
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height - 7.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let data = entry.data as! [String:Any]
        
        teamLabel1.text = (data["home"] as! Bool) ? (data["team"] as! String) : (data["opponent"] as! String)
        teamLabel1.textColor = (data["home"] as! Bool) ? (data["win"] as! Bool ? UIColor.flatGreen() : UIColor.flatRed()) : UIColor(hexString: "E1E1E1")
        
        teamLabel2.text = (data["home"] as! Bool) ? (data["opponent"] as! String) : (data["team"] as! String)
        teamLabel2.textColor = !(data["home"] as! Bool) ? (data["win"] as! Bool ? UIColor.flatGreen() : UIColor.flatRed()) : UIColor(hexString: "E1E1E1")

        statLabel1.text = (data["stat1"] as! String)
        statLabel1.textColor = highlight.dataSetIndex == 0 ? UIColor.flatOrange() : UIColor(hexString: "E1E1E1")
        statLabel1.sizeToFit()
        
        statLabel2.text = (data["stat2"] as! String)
        statLabel2.textColor = highlight.dataSetIndex == 1 ? UIColor.flatOrange() : UIColor(hexString: "E1E1E1")
        statLabel2.sizeToFit()
        
        statLabel3.text = (data["stat3"] as! String)
        statLabel3.textColor = highlight.dataSetIndex == 2 ? UIColor.flatOrange() : UIColor(hexString: "E1E1E1")
        statLabel3.sizeToFit()

        layoutIfNeeded()
    }
}
