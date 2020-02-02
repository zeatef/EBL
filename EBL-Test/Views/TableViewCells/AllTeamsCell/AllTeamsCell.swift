//
//  AllTeamsCell.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/13/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class AllTeamsCell: UITableViewCell {
    
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    var teamID : String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
}
