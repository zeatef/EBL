//
//  LeagueLeadersTableViewCell.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 6/24/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class LeagueLeadersTableViewCell: UITableViewCell {

    @IBOutlet weak var ranking: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var stat1: UILabel!
    @IBOutlet weak var stat2: UILabel!
    @IBOutlet weak var stat3: UILabel!
    @IBOutlet weak var stat4: UILabel!
    
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
