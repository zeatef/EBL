//
//  StandingsHeaderView.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 6/7/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class StandingsHeaderView: UIView {

    var viewController : StandingsViewController!
    var tableView : UITableView!
    var section : Int!
    var numberOfRows : Int!
    
    @IBOutlet weak var label: UILabel!
   
    @IBAction func expandButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05, animations: ({
            sender.transform = sender.transform.rotated(by: self.viewController.sectionsCollapsed[self.section] ? .pi/2 : -.pi/2)
        }))
        viewController.sectionsCollapsed[section] = !viewController.sectionsCollapsed[section]

        var indices : [IndexPath] = []
        for row in 0..<numberOfRows {
            indices.append(IndexPath(row: row, section: section))
        }
        if(viewController.sectionsCollapsed[section]) {
            tableView.deleteRows(at: indices, with: .fade)
        } else {
            tableView.insertRows(at: indices, with: .fade)
        }
    }
    

}
