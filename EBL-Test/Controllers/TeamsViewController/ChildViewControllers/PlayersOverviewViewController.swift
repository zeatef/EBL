//
//  PlayersOverviewViewController
//  EBL-Test
//
//  Created by Zeyad Atef on 2/13/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import Segmentio
import SkeletonView

class PlayersOverviewViewController: UIViewController {
    
    @IBOutlet weak var playerStatsCollectionView: UICollectionView!
    @IBOutlet weak var customGridTableLayout: GridTableCustomLayout! {
        didSet {
            customGridTableLayout.stickyRowsCount = 1
            customGridTableLayout.stickyColumnsCount = 1
        }
    }
    
    let statTitles = ["", "", "POS", "AGE", "PPG", "APG", "FG%", "3FG%", "2FG%", "FT%", "RPG", "STPG", "TOPG", "BLKPG", "MINPG", "EFPG"]
    
    var selectedStatTitle : [Bool] = Array(repeating: false, count: 15)
    var dataArray : [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //Register playerStatsCollectionView's custom Cells
        registerXibFiles()
        selectedStatTitle[1] = true
        setupPlayersDataArray()
    }

    
    func registerXibFiles(){
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell1", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell1")
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell2", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2")
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell2WithArrow", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2WithArrow")
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell3", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell3")
    }
    
    func setupPlayersDataArray() {
        if ((parent as! TeamsViewController).team!.allPlayers!.count > 0) {
            view.hideSkeleton()
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.primaryPosition == $1.primaryPosition) {
                    if($0.secondaryPosition == $1.secondaryPosition) {
                        return $0.knownAs.first < $1.knownAs.last
                    } else {
                        return $0.secondaryPosition < $1.secondaryPosition
                    }
                } else {
                    return $0.primaryPosition < $1.primaryPosition
                }
            })
            
            
            for player in (parent as! TeamsViewController).team!.allPlayers! {
                let minutes = Int(floor(player.statistics!.MINS!.perGame))
                let seconds = Int(round(player.statistics!.MINS!.perGame.truncatingRemainder(dividingBy: 1) * 60))
                let avgMINS = (minutes == 0 && seconds == 0) ? "0:0" : (seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)")
                
                self.dataArray.append([
                    player.knownAs.first,
                    player.knownAs.last,
                    player.positionName,
                    "\(player.age)",
                    "\(player.statistics!.PTS.perGame)",
                    "\(player.statistics!.AST.perGame)",
                    "\(String(format: "%.1f", player.statistics!.FG.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FG3.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FG2.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FT.percentage*100.0))%",
                    "\(player.statistics!.TREB.perGame)",
                    "\(player.statistics!.STL.perGame)",
                    "\(player.statistics!.TO.perGame)" ,
                    "\(player.statistics!.BLK.perGame)",
                    "\(avgMINS)",
                    "\(player.statistics!.EFF!.perGame)"
                    ]
                )
            }
            
            self.playerStatsCollectionView.reloadData()
        }
    }
    
    func sortPlayersBy(option: Int) {
        switch option {
        case 1:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.primaryPosition == $1.primaryPosition) {
                    if($0.secondaryPosition == $1.secondaryPosition) {
                        return $0.knownAs.first < $1.knownAs.last
                    } else {
                        return $0.secondaryPosition < $1.secondaryPosition
                    }
                } else {
                    return $0.primaryPosition < $1.primaryPosition
                }
            })
        case 2:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.age == $1.age) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.age < $1.age
                }
            })
        case 3:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.PTS.perGame == $1.statistics!.PTS.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.PTS.perGame > $1.statistics!.PTS.perGame
                }
            })
        case 4:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.AST.perGame == $1.statistics!.AST.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.AST.perGame > $1.statistics!.AST.perGame
                }
            })
        case 5:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.FG.percentage == $1.statistics!.FG.percentage) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.FG.percentage > $1.statistics!.FG.percentage
                }
            })
        case 6:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.FG3.percentage == $1.statistics!.FG3.percentage) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.FG3.percentage > $1.statistics!.FG3.percentage
                }
            })
        case 7:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.FG2.percentage == $1.statistics!.FG2.percentage) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.FG2.percentage > $1.statistics!.FG2.percentage
                }
            })
        case 8:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.FT.percentage == $1.statistics!.FT.percentage) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.FT.percentage > $1.statistics!.FT.percentage
                }
            })
        case 9:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.TREB.perGame == $1.statistics!.TREB.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.TREB.perGame > $1.statistics!.TREB.perGame
                }
            })
        case 10:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.STL.perGame == $1.statistics!.STL.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.STL.perGame > $1.statistics!.STL.perGame
                }
            })
        case 11:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.TO.perGame == $1.statistics!.TO.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.TO.perGame > $1.statistics!.TO.perGame
                }
            })
        case 12:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.BLK.perGame == $1.statistics!.BLK.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.BLK.perGame > $1.statistics!.BLK.perGame
                }
            })
        case 13:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.MINS!.perGame == $1.statistics!.MINS!.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.MINS!.perGame > $1.statistics!.MINS!.perGame
                }
            })
        case 14:
            (parent as! TeamsViewController).team!.allPlayers!.sort(by: {
                if($0.statistics!.EFF!.perGame == $1.statistics!.EFF!.perGame) {
                    return $0.knownAs.first < $1.knownAs.first
                } else {
                    return $0.statistics!.EFF!.perGame > $1.statistics!.EFF!.perGame
                }
            })
        default:
            print("Add Sort Option For Row: \(statTitles[option+1])")
        }
        
        dataArray = []
        for player in (parent as! TeamsViewController).team!.allPlayers! {
            let minutes = Int(floor(player.statistics!.MINS!.perGame))
            let seconds = Int(round(player.statistics!.MINS!.perGame.truncatingRemainder(dividingBy: 1) * 60))
            let avgMINS = (minutes == 0 && seconds == 0) ? "0:0" : (seconds < 10 ? "\(minutes):0\(seconds)" : "\(minutes):\(seconds)")
            
            self.dataArray.append([
                player.knownAs.first,
                player.knownAs.last,
                player.positionName,
                "\(player.age)",
                "\(player.statistics!.PTS.perGame)",
                "\(player.statistics!.AST.perGame)",
                "\(String(format: "%.1f", player.statistics!.FG.percentage*100.0))%",
                "\(String(format: "%.1f", player.statistics!.FG3.percentage*100.0))%",
                "\(String(format: "%.1f", player.statistics!.FG2.percentage*100.0))%",
                "\(String(format: "%.1f", player.statistics!.FT.percentage*100.0))%",
                "\(player.statistics!.TREB.perGame)",
                "\(player.statistics!.STL.perGame)",
                "\(player.statistics!.TO.perGame)" ,
                "\(player.statistics!.BLK.perGame)",
                "\(avgMINS)",
                "\(player.statistics!.EFF!.perGame)"
                ]
            )
        }
        
        playerStatsCollectionView.reloadData()
    }
}

// MARK: - Collection view data source and delegate methods
extension PlayersOverviewViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if dataArray.count > 0 {
            return dataArray.count + 1
        } else {
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell1", for: indexPath) as? PlayerNameAndImageCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true

                if (dataArray.count > 0) {
                    cell.playerImage.image = UIImage(named: "player")
                    cell.firstName.text = dataArray[indexPath.section - 1][indexPath.row]
                    cell.lastName.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
                }

                cell.backgroundColor = UIColor(hexString: "484848")

                return cell
            }
        default:
            if(indexPath.section == 0) {
                //Stat Titles
                if(selectedStatTitle[indexPath.row]) {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2WithArrow", for: indexPath) as? StatsCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    
                    cell.titleLabel.text = statTitles[indexPath.row + 1]
                    cell.titleLabel.textColor = UIColor.flatOrange()
                    
                    cell.backgroundColor = UIColor(hexString: "2b2b2b")
                    
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    
                    cell.titleLabel.text = statTitles[indexPath.row + 1]
                    cell.titleLabel.textColor = UIColor(hexString: "ffffff")
                    
                    cell.backgroundColor = UIColor(hexString: "2b2b2b")
                    
                    return cell
                }
            } else {
                
                //Stat Value
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell3", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.isSkeletonable = true
                
                if(dataArray.count > 0) {
                    cell.titleLabel.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.titleLabel.text = ""
                }
                
                if(selectedStatTitle[indexPath.row]) {
                    cell.backgroundColor = UIColor(hexString: "c46323", withAlpha: 0.5)
                } else {
                    cell.backgroundColor = UIColor(hexString: "2b2b2b", withAlpha: 0.5)
                }

                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0) {
            selectedStatTitle = Array(repeating: false, count: 15)
            selectedStatTitle[indexPath.row] = true
            sortPlayersBy(option: indexPath.row)
        }
    }
}

extension PlayersOverviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return CGSize(width: 130, height: 30)
            } else {
                return CGSize(width: 130, height: 50)
            }
        default:
            if(indexPath.section == 0) {
                return CGSize(width: 55, height: 30)
            } else {
                return CGSize(width: 55, height: 50)
                
            }
        }
    }
}

extension PlayersOverviewViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return "StatsCell2"
            } else {
                return "StatsCell1"
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

