//
//  StandingsViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 5/29/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Kingfisher

class StandingsViewController: UIViewController {

    let dbManager = DatabaseManager.sharedInstance
    var tableData : [String:[TeamDisplayData]] = [:]
    var tableKeys : [String] = []
    var sectionsCollapsed : [Bool] = []
    
    @IBOutlet weak var standingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerXibFiles()
        setupTableData()
    }
    
    func setupTableData() {
//        dbManager.getStandings { (error, data) in
//            if let error = error {
//                print(error)
//            } else {
//                self.tableKeys = data!.keys.sorted(by: <)
//                for key in self.tableKeys {
//                    self.tableData[key] = data![key]!.sorted(by: { $0.currentStanding! < $1.currentStanding! })
//                    self.sectionsCollapsed.append(false)
//                }
//                self.standingsTableView.reloadData()
//            }
//        }
    }
    
    func registerXibFiles(){
//        standingsTableView.register(UINib(nibName: "StandingsHeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "StandingsHeaderView")
        standingsTableView.register(UINib(nibName: "StandingsNormalCell", bundle: Bundle.main), forCellReuseIdentifier: "StandingsNormalCell")
    }
}

extension StandingsViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
}

extension StandingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(sectionsCollapsed[section]) {
            return 0
        } else {
            return tableData[tableKeys[section]]!.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = standingsTableView.dequeueReusableCell(withIdentifier: "StandingsNormalCell", for: indexPath) as? StandingsNormalCell else {
            return UITableViewCell()
        }

        if(indexPath.row == 0) {
            cell.arrowImage.image = nil
            cell.standingLabel.text = ""
            cell.teamImage.image = nil
            cell.teamLabel.text = ""
            cell.gamesPlayed.text = "GP"
            cell.winsLabel.text = "W"
            cell.LossesLabel.text = "L"
            cell.scoreDifference.text = "+/-"
        } else {
            let team = tableData[tableKeys[indexPath.section]]![indexPath.row-1]
            
            if(team.currentStanding! < team.previousStanding!) {
                cell.arrowImage.image = UIImage(named: "arrow-up")
            } else if(team.currentStanding! > team.previousStanding!) {
                cell.arrowImage.image = UIImage(named: "arrow-down")
            } else {
                cell.arrowImage.image = UIImage(named: "dash")
            }
            
            cell.standingLabel.text = "\(team.currentStanding!)"
            cell.teamImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: team.teamID))
            cell.teamLabel.text = team.teamName
            cell.gamesPlayed.text = "\(team.wins! + team.losses!)"
            cell.winsLabel.text = "\(team.wins!)"
            cell.LossesLabel.text = "\(team.losses!)"
            cell.scoreDifference.text = "\(team.scoreDifference!)"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UINib(nibName: "StandingsHeaderView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! StandingsHeaderView
        
        headerView.label.text = tableKeys[section]
        headerView.tableView = tableView
        headerView.section = section
        headerView.numberOfRows = tableData[tableKeys[section]]!.count + 1
        headerView.viewController = self
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(sectionsCollapsed[section]) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0) {
            return 30.0
        } else {
            return 45.0
        }
    }
    
}
