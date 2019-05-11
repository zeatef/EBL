//
//  PlayerNameAndImageCell.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/21/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class PlayerNameAndImageCell: UICollectionViewCell {

    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
