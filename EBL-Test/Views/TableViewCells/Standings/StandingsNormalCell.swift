//
//  StandingsNormalCell.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 5/29/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class StandingsNormalCell: UITableViewCell {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var standingLabel: UILabel!
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var gamesPlayed: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var LossesLabel: UILabel!
    @IBOutlet weak var scoreDifference: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
