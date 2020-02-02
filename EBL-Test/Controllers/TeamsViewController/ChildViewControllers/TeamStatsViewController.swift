//
//  TeamStatsViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 3/17/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class TeamStatsViewController: UIViewController {
    
    @IBOutlet weak var teamGameStatsCollectionView: UICollectionView!
    @IBOutlet weak var gridTableLayout: GridTableCustomLayout! {
        didSet {
            gridTableLayout.stickyRowsCount = 1
            gridTableLayout.stickyColumnsCount = 1
        }
    }
    
    let dbManager = DatabaseManager.sharedInstance
    var parentVC : TeamsViewController?
    
    let statTitles = ["PTS", "FG", "FG%", "3FG", "3FG%", "2FG", "2FG%", "FT", "FT%", "AST", "ORB", "DRB", "TREB", "STL", "TO", "BLK", "FOL"]

    var dataArray : [[String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXibFiles()
        fetchData()        
    }
        
    func registerXibFiles(){
        teamGameStatsCollectionView.register(UINib(nibName: "GameStatCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "GameStatCell")
        teamGameStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell2", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2")
        teamGameStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell3", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell3")
    }
    
    func fetchData() {
        dbManager.getTeamGameStats(forTeam: parentVC!.team!) { (error) in
            if let error = error {
                print(error)
                self.dataArray = []
            } else {
                self.setupDataArray()
            }
        }
    }
    
    func setupDataArray() {
        if(parentVC!.team!.gameStatistics!.count == 0) {
            teamGameStatsCollectionView.isHidden = true
        } else {
            view.hideSkeleton()
            
            for gameStats in parentVC!.team!.gameStatistics! {
                var tempArray : [String] = []
                tempArray.append("\(gameStats.PTS)")
                tempArray.append("\(gameStats.FG.made)/\(gameStats.FG.attempts)")
                tempArray.append("\(String(format: "%.1f", gameStats.FG.percentage*100.0))%")
                tempArray.append("\(gameStats.FG3.made)/\(gameStats.FG3.attempts)")
                tempArray.append("\(String(format: "%.1f", gameStats.FG3.percentage*100.0))%")
                tempArray.append("\(gameStats.FG2.made)/\(gameStats.FG2.attempts)")
                tempArray.append("\(String(format: "%.1f", gameStats.FG2.percentage*100.0))%")
                tempArray.append("\(gameStats.FT.made)/\(gameStats.FT.attempts)")
                tempArray.append("\(String(format: "%.1f", gameStats.FT.percentage*100.0))%")
                tempArray.append("\(gameStats.AST)")
                tempArray.append("\(gameStats.OREB)")
                tempArray.append("\(gameStats.DREB)")
                tempArray.append("\(gameStats.TREB)")
                tempArray.append("\(gameStats.STL)")
                tempArray.append("\(gameStats.TO)")
                tempArray.append("\(gameStats.BLK)")
                tempArray.append("\(gameStats.FOL)")
                
                self.dataArray.append(tempArray)
            }
            
            self.teamGameStatsCollectionView.reloadData()
        }
    }
}

// MARK: - Collection view data source and delegate methods
extension TeamStatsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(dataArray.count == 0) {
            return 12
        } else {
            return dataArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(dataArray.count == 0) {
            if(section == 0) {
                return statTitles.count + 1
            } else {
                return 1
            }
        } else {
            return statTitles.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLabel.text = ""
                cell.backgroundColor = UIColor(hexString: "595959")
                
                return cell
            } else {
                //Player Name
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameStatCell", for: indexPath) as? GameStatCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true
                
                if (dataArray.count > 0) {
                    cell.opponentImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: parentVC!.team!.gameStatistics![indexPath.section-1].opponentAbb))
                    cell.opponentName.text = parentVC!.team!.gameStatistics![indexPath.section-1].opponentAbb
                    
                    if(parentVC!.team!.gameStatistics![indexPath.section-1].isHome) {
                        cell.isHome.text = "(H)"
                        cell.homeScore.text = "\(parentVC!.team!.gameStatistics![indexPath.section-1].PTS)"
                        cell.awayScore.text = "\(parentVC!.team!.gameStatistics![indexPath.section-1].opponentPTS)"
                        
                        cell.homeScore.textColor = parentVC!.team!.gameStatistics![indexPath.section-1].opponentPTS > parentVC!.team!.gameStatistics![indexPath.section-1].PTS ? UIColor.flatRed() : UIColor.flatGreen()
                    } else {
                        cell.isHome.text = "(A)"
                        cell.homeScore.text = "\(parentVC!.team!.gameStatistics![indexPath.section-1].opponentPTS)"
                        cell.awayScore.text = "\(parentVC!.team!.gameStatistics![indexPath.section-1].PTS)"

                        cell.awayScore.textColor = parentVC!.team!.gameStatistics![indexPath.section-1].opponentPTS > parentVC!.team!.gameStatistics![indexPath.section-1].PTS ? UIColor.flatRed() : UIColor.flatGreen()
                    }
                } else {
                    cell.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
                }
                
                cell.backgroundColor = UIColor(hexString: "484848")
                
                return cell
            }
        default:
            if(indexPath.section == 0) {
                //Stat Titles
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLabel.text = statTitles[indexPath.row - 1]
                cell.titleLabel.textColor = UIColor(hexString: "ffffff")
                cell.backgroundColor = UIColor(hexString: "2b2b2b")
                
                return cell
            } else {
                
                //Stat Value
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell3", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true
                
                if(dataArray.count > 0) {
                    cell.titleLabel.text = dataArray[indexPath.section - 1][indexPath.row - 1]
                } else {
                    cell.titleLabel.text = ""
                }
                
                cell.backgroundColor = UIColor(hexString: "2b2b2b", withAlpha: 0.5)
                
                return cell
            }
        }
    }
}
extension TeamStatsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(dataArray.count == 0) {
            switch indexPath.section {
            case 0:
                if(indexPath.row == 0) {
                    return CGSize(width: 110, height: 30)
                } else {
                    return CGSize(width: 45, height: 30)
                }
            default:
                let width =  UIScreen.main.bounds.width
                return CGSize(width: width, height: 50)
            }
        } else {
            switch indexPath.row {
            case 0:
                if(indexPath.section == 0) {
                    return CGSize(width: 110, height: 30)
                } else {
                    return CGSize(width: 110, height: 50)
                }
            default:
                if(indexPath.section == 0) {
                    return CGSize(width: 45, height: 30)
                } else {
                    return CGSize(width: 45, height: 50)
                    
                }
            }
        }
        
    }
}

extension TeamStatsViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return "StatsCell2"
            } else {
                return "GameStatCell"
            }
        default:
            if(indexPath.section == 0) {
                return "StatsCell2"
            } else {
                return "StatsCell3"
                
            }
        }
    }
}

