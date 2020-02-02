//
//  LeagueLeadersViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 6/23/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import MKDropdownMenu
import Kingfisher
import SVProgressHUD

class LeagueLeadersViewController: UIViewController {

    //MARK:- IB Outlets
    @IBOutlet weak var statsDropdown: MKDropdownMenu!
    @IBOutlet weak var playerOrTeamStackView: UIStackView!
    @IBOutlet weak var averageOrTotalStackView: UIStackView!
    @IBOutlet weak var leagueLeadersTableView: UITableView!
    
    //MARK:- Instance Variables
    let dbManager = DatabaseManager.sharedInstance
    let statTitles = ["Points", "Rebounds", "Assists", "Field Goals", "Three Points", "Free Throws", "Steals", "Blocks", "Turnovers", "Fouls", "Minutes", "Efficiency"]
    let averageQueries = ["PTS.perGame", "REB.perGame", "AST.perGame", "FG.percentage", "3FG.percentage", "FT.percentage", "STL.perGame", "BLK.perGame", "TO.perGame", "FOL.perGame", "MINS.perGame", "EFF.perGame"]
    let totalQueries = ["PTS.total", "REB.total", "AST.total", "FG.made", "3FG.made", "FT.made", "STL.total", "BLK.total", "TO.total", "FOL.total", "MINS.total", "EFF.total"]
    var selectedStat = 0 {
        didSet{
            if(selectedStat == 10 || selectedStat == 11) {
                selectedPlayerOrTeam = 0
                (playerOrTeamStackView.viewWithTag(1) as! UIButton).backgroundColor = UIColor(hexString: "2B2B2B")
                (playerOrTeamStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor.flatOrange()
                playerOrTeamStackView.viewWithTag(1)?.isHidden = true
            } else {
                playerOrTeamStackView.viewWithTag(1)?.isHidden = false
            }
            SVProgressHUD.show()
            self.setupData { (error) in
                if let error = error {
                    print(error)
                } else {
                    SVProgressHUD.dismiss()
                    self.leagueLeadersTableView.reloadData()
                }
            }
        }
    }
    var selectedPlayerOrTeam = 0 {
        didSet{
            SVProgressHUD.show()
            self.setupData { (error) in
                if let error = error {
                    print(error)
                } else {
                    SVProgressHUD.dismiss()
                    self.leagueLeadersTableView.reloadData()
                }
            }
        }
    }
    var selectedAverageOrTotal = 0 {
        didSet{
            SVProgressHUD.show()
            self.setupData { (error) in
                if let error = error {
                    print(error)
                } else {
                    SVProgressHUD.dismiss()
                    self.leagueLeadersTableView.reloadData()
                }
            }
        }
    }
    var fetchCompleted = false
    
    var players : [Player] = []
    var teams : [Team] = []
    
    //MARK:- Default Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXibFiles()
        setupStatsDropdown()
        SVProgressHUD.show()
        self.setupData { (error) in
            if let error = error {
                print(error)
            } else {
                SVProgressHUD.dismiss()
                self.leagueLeadersTableView.reloadData()
            }
        }
    }
    
    func registerXibFiles() {
        //Register AllTeamsCell custom Cells
        leagueLeadersTableView.register(UINib(nibName: "LeagueLeadersTableViewCell", bundle: nil) , forCellReuseIdentifier: "LeagueLeadersCell")
    }
    
    //MARK:- Setup View Methods
    func setupStatsDropdown() {
        (playerOrTeamStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor.flatOrange()
        (averageOrTotalStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor.flatOrange()

        statsDropdown.delegate = self
        statsDropdown.dataSource = self
        
        statsDropdown.tintColor = UIColor(hexString: "E1E1E1")
        statsDropdown.backgroundColor = UIColor(hexString: "2B2B2B")
        statsDropdown.dropdownBouncesScroll = true
        statsDropdown.dropdownBackgroundColor = UIColor(hexString: "2b2b2b")
        statsDropdown.dropdownShowsBottomRowSeparator = false
        statsDropdown.backgroundDimmingOpacity = 0.2
        statsDropdown.reloadAllComponents()
    }
    
    func setupData(completion: @escaping (Error?) -> Void) {
        fetchCompleted = false
        if(selectedPlayerOrTeam == 0) {
            let statistic = selectedAverageOrTotal == 0 ? averageQueries[selectedStat] : totalQueries[selectedStat]
            dbManager.getPlayerLeagueLeaders(source: .cache, statistic: statistic) { (error, players) in
                if let error = error {
                    completion(error)
                } else {
                    self.players = players!
                    self.fetchCompleted = true
                    completion(nil)
                }
            }
        } else {
            let statistic = selectedAverageOrTotal == 0 ? averageQueries[selectedStat] : totalQueries[selectedStat]
            dbManager.getTeamLeagueLeaders(source: .cache, statistic: statistic) { (error, teams) in
                if let error = error {
                    completion(error)
                } else {
                    self.teams = teams!
                    self.fetchCompleted = true
                    completion(nil)
                }
            }
        }
    }
    
    @IBAction func choosePlayerOrTeamButtonPressed(_ sender: UIButton) {
        if(sender.tag != selectedPlayerOrTeam) {
            if(sender.tag == 0) {
                UIView.animate(withDuration: 0.1) {
                    (self.playerOrTeamStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor.flatOrange()
                    (self.playerOrTeamStackView.viewWithTag(1) as! UIButton).backgroundColor = UIColor(hexString: "2B2B2B")
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    (self.playerOrTeamStackView.viewWithTag(1) as! UIButton).backgroundColor = UIColor.flatOrange()
                    (self.playerOrTeamStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor(hexString: "2B2B2B")
                }
            }
            selectedPlayerOrTeam = sender.tag
        }
    }
    @IBAction func chooseAverageOrTotalButtonPressed(_ sender: UIButton) {
        if(sender.tag != selectedAverageOrTotal) {
            if(sender.tag == 0) {
                UIView.animate(withDuration: 0.1) {
                    (self.averageOrTotalStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor.flatOrange()
                    (self.averageOrTotalStackView.viewWithTag(1) as! UIButton).backgroundColor = UIColor(hexString: "2B2B2B")
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    (self.averageOrTotalStackView.viewWithTag(1) as! UIButton).backgroundColor = UIColor.flatOrange()
                    (self.averageOrTotalStackView.viewWithTag(0) as! UIButton).backgroundColor = UIColor(hexString: "2B2B2B")
                }
            }
            selectedAverageOrTotal = sender.tag
        }
    }
    
}

//MARK:- Table View Delegate and DataSource
extension LeagueLeadersViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension LeagueLeadersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 30.0 : 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(selectedAverageOrTotal == 0) {
            if(selectedStat == 3 || selectedStat == 4 || selectedStat == 5) {
                return "\(statTitles[selectedStat]) Percentage"
            } else {
                return "\(statTitles[selectedStat]) Per Game"
            }
        } else {
            if(selectedStat == 3 || selectedStat == 4 || selectedStat == 5) {
                return "\(statTitles[selectedStat]) Made"
            } else {
                return "Total \(statTitles[selectedStat])"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor(hexString: "595959")
            header.textLabel?.textColor = UIColor.white
            header.textLabel?.textAlignment = .center
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchCompleted {
            return 11
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = leagueLeadersTableView.dequeueReusableCell(withIdentifier: "LeagueLeadersCell", for: indexPath) as? LeagueLeadersTableViewCell else {
            return UITableViewCell()
        }
        
        cell.firstName.isHidden = false
        cell.stat1.isHidden = false
        cell.stat2.isHidden = false
        cell.stat3.isHidden = false
        cell.stat4.isHidden = false
        
        if(indexPath.row == 0) {
            cell.contentView.backgroundColor = UIColor(hexString: "2B2B2B")
            cell.stat1.font = .systemFont(ofSize: 12, weight: .semibold)
            cell.stat2.font = .systemFont(ofSize: 12, weight: .semibold)
            cell.stat3.font = .systemFont(ofSize: 12, weight: .semibold)
            cell.stat4.font = .systemFont(ofSize: 12, weight: .semibold)
            
            cell.separator.isHidden = true
            cell.ranking.text = ""
            cell.cellImage.image = nil
            cell.firstName.text = ""
            cell.lastName.text = ""
        } else {
            cell.contentView.backgroundColor = UIColor(hexString: "4B4B4B")
            cell.stat1.font = .systemFont(ofSize: 11, weight: .regular)
            cell.stat2.font = .systemFont(ofSize: 11, weight: .regular)
            cell.stat3.font = .systemFont(ofSize: 11, weight: .regular)
            cell.stat4.font = .systemFont(ofSize: 11, weight: .regular)
            
            //Ranking
            cell.ranking.text = "\(indexPath.row)"
            
            //Image
            if(selectedPlayerOrTeam == 0) {
                cell.cellImage.image = UIImage(named: "player")
                cell.firstName.text = players[indexPath.row-1].knownAs.first
                cell.lastName.text = players[indexPath.row-1].knownAs.last
                cell.lastName.isHidden = false
            } else {
                cell.cellImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: teams[indexPath.row-1].abb))
                cell.lastName.text = teams[indexPath.row-1].teamName
                cell.firstName.isHidden = true
            }
        }
        
        switch selectedStat {
        case 0:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "PPG" : "PTS"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.PTS : teams[indexPath.row-1].statistics!.PTS

                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 1:
            if(indexPath.row == 0) {
                cell.stat1.text = "OREB"
                cell.stat2.text = "DREB"
                cell.stat3.text = "TREB"
                cell.stat4.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat4.isHidden = selectedPlayerOrTeam == 1
            } else {
                let statistic1 = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.OREB : teams[indexPath.row-1].statistics!.OREB
                let statistic2 = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.DREB : teams[indexPath.row-1].statistics!.DREB
                let statistic3 = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.TREB : teams[indexPath.row-1].statistics!.TREB
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic1.perGame) : "\(Int(statistic1.total))"
                cell.stat2.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic2.perGame) : "\(Int(statistic2.total))"
                cell.stat3.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic3.perGame) : "\(Int(statistic3.total))"
                cell.stat4.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat4.isHidden = selectedPlayerOrTeam == 1
            }
        case 2:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "APG" : "AST"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.AST : teams[indexPath.row-1].statistics!.AST

                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 3:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "FG%" : "FGA"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "FGM"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.FG : teams[indexPath.row-1].statistics!.FG

                cell.stat1.text = selectedAverageOrTotal == 0 ? "\(String(format: "%.1f", statistic.percentage*100))%" : "\(Int(statistic.attempts))"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "\(Int(statistic.made))"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            }
        case 4:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "3FG%" : "3FGA"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "3FGM"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.FG3 : teams[indexPath.row-1].statistics!.FG3
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? "\(String(format: "%.1f", statistic.percentage*100))%" : "\(Int(statistic.attempts))"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "\(Int(statistic.made))"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            }
        case 5:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "FT%" : "FTA"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "FTM"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.FT : teams[indexPath.row-1].statistics!.FT
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? "\(String(format: "%.1f", statistic.percentage*100))%" : "\(Int(statistic.attempts))"
                if(selectedAverageOrTotal == 0) {
                    cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat2.isHidden = selectedPlayerOrTeam == 1
                    cell.stat3.isHidden = true
                } else {
                    cell.stat2.text = "\(Int(statistic.made))"
                    cell.stat3.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                    cell.stat3.isHidden = selectedPlayerOrTeam == 1
                }
                cell.stat4.isHidden = true
            }
        case 6:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "STLPG" : "STL"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.STL : teams[indexPath.row-1].statistics!.STL
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 7:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "BLKPG" : "BLK"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.BLK : teams[indexPath.row-1].statistics!.BLK
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 8:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "TOPG" : "TO"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.TO : teams[indexPath.row-1].statistics!.TO
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 9:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "FOLPG" : "FOL"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? "Team" : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].statistics!.FOL : teams[indexPath.row-1].statistics!.FOL
                
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = selectedPlayerOrTeam == 0 ? players[indexPath.row-1].currentTeam : ""
                cell.stat2.isHidden = selectedPlayerOrTeam == 1
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 10:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "MINPG" : "MINS"
                cell.stat2.text = "Team"
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = players[indexPath.row-1].statistics!.MINS!
                if(selectedAverageOrTotal == 0) {
                    let minutes = Int(floor(statistic.perGame))
                    let seconds = Int(round(statistic.perGame.truncatingRemainder(dividingBy: 1) * 60))
                    let avgMINS = (minutes == 0 && seconds == 0) ? "0:0" : (seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)")
                    cell.stat1.text = avgMINS
                } else {
                    let minutes = Int(floor(statistic.total))
                    let seconds = Int(round(statistic.total.truncatingRemainder(dividingBy: 1) * 60))
                    let avgMINS = (minutes == 0 && seconds == 0) ? "0:0" : (seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)")
                    cell.stat1.text = avgMINS
                }
                cell.stat2.text = players[indexPath.row-1].currentTeam
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        case 11:
            if(indexPath.row == 0) {
                cell.stat1.text = selectedAverageOrTotal == 0 ? "EFFPG" : "EFF"
                cell.stat2.text = "Team"
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            } else {
                let statistic = players[indexPath.row-1].statistics!.EFF!
                cell.stat1.text = selectedAverageOrTotal == 0 ? String(format: "%.1f", statistic.perGame) : "\(Int(statistic.total))"
                cell.stat2.text = players[indexPath.row-1].currentTeam
                cell.stat3.isHidden = true
                cell.stat4.isHidden = true
            }
        default:
            print("")
        }
        return cell
    }
}

//MARK:- Dropdown Delegate and DataSource
extension LeagueLeadersViewController: MKDropdownMenuDataSource {
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        return 12
    }
}

extension LeagueLeadersViewController: MKDropdownMenuDelegate {
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForSelectedComponent component: Int) -> NSAttributedString? {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "E1E1E1"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        return NSAttributedString(string: statTitles[selectedStat], attributes: attributes as [NSAttributedString.Key : Any])
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForComponent component: Int) -> NSAttributedString? {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "E1E1E1"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        return NSAttributedString(string: statTitles[selectedStat], attributes: attributes as [NSAttributedString.Key : Any])
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "E1E1E1"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .regular)]
        
        if(selectedStat == row) {
            attributes[NSAttributedString.Key.foregroundColor] = UIColor.flatOrange()
        }
        return NSAttributedString(string: statTitles[row], attributes: attributes as [NSAttributedString.Key : Any])
    }
    
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        selectedStat = row
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            dropdownMenu.reloadAllComponents()
            dropdownMenu.closeAllComponents(animated: true)
        }
    }
}

