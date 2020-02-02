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
    
    @IBOutlet weak var statTitle: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var teamStat: UILabel!
    @IBOutlet weak var leagueStat: UILabel!
    
    public override func awakeFromNib() {
        self.offset.x = -self.frame.size.width / 2.0
        self.offset.y = -self.frame.size.height - 7.0
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        var title = ""
        let data = entry.data as! [Any]
        
        switch data[3] as! Int {
        case 0:
            title = "Points Per Game"
        case 1:
            title = "Feild Goals %"
        case 2:
            title = "3 Points %"
        case 3:
            title = "2 Points %"
        case 4:
            title = "Free Throws %"
        case 5:
            title = "Assists Per Game"
        case 6:
            title = "Rebounds Per Game"
        case 7:
            title = "Steals Per Game"
        case 8:
            title = "Turnovers Per Game"
        default:
            title = ""
        }
        
        let teamValue = data[1] as! Double
        let leagueValue = data[2] as! Double
        
        statTitle.text = title
        teamName.text = (data[0] as? String)! + ":"
        
        if((data[3] as! Int) > 0 && (data[3] as! Int) < 5) {
            teamStat.text = "\(String(format: "%.1f", teamValue))%"
            leagueStat.text = "\(String(format: "%.1f", leagueValue))%"
        } else {
            teamStat.text = "\(String(format: "%.1f", teamValue))"
            leagueStat.text = "\(String(format: "%.1f", leagueValue))"
        }
        
        teamStat.sizeToFit()
        leagueStat.sizeToFit()
        
        if(data[3] as! Int != 8) {
            teamStat.textColor = teamValue >= leagueValue ? UIColor.flatGreen() : UIColor.flatRed()
        } else {
            teamStat.textColor = teamValue >= leagueValue ? UIColor.flatRed() : UIColor.flatGreen()
        }
        
        layoutIfNeeded()
    }
}
