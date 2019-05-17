//
//  LineMarkerView1.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 5/14/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import Foundation
import Charts

public class LineMarkerView1: MarkerView {
    
    
    @IBOutlet weak var teamLabel1: UILabel!
    @IBOutlet weak var teamLabel2: UILabel!
    @IBOutlet weak var scoreLabel1: UILabel!
    @IBOutlet weak var scoreLabel2: UILabel!
    
    
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
                
        if(data["home"] as! Bool) {
            scoreLabel1.text = "\(data["teamPTS"] as! Int)"
            scoreLabel1.textColor = data["win"] as! Bool ? UIColor.flatGreen() : UIColor.flatRed()
            scoreLabel2.text = "\(data["opponentPTS"] as! Int)"
        } else {
            scoreLabel1.text = "\(data["opponentPTS"] as! Int)"
            scoreLabel2.text = "\(data["teamPTS"] as! Int)"
            scoreLabel2.textColor = data["win"] as! Bool ? UIColor.flatGreen() : UIColor.flatRed()
        }
        
        layoutIfNeeded()
    }
}
