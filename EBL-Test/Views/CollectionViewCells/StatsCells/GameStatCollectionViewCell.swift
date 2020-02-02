//
//  GameStatCollectionViewCell.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 6/20/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class GameStatCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var isHome: UILabel!
    @IBOutlet weak var homeScore: UILabel!
    @IBOutlet weak var awayScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
