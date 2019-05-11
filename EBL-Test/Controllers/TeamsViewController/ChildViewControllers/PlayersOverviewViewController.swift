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
    
    let statTitles = ["", "", "POS", "AGE", "PPG", "APG", "FG%", "RPG", "BLKPG", "STPG", "MINPG", "EFPG"]
    var players : [Player] = [Player]()
    var check : Bool = false {
        didSet {
            setupPlayersDataArray()
        }
    }
    var dataArray : [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register playerStatsCollectionView's custom Cells
        registerXibFiles()
        
    }
    
    func registerXibFiles(){
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell1", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell1")
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell2", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2")
        playerStatsCollectionView.register(UINib(nibName: "StatsCollectionViewCell3", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell3")
    }
    
    func setupPlayersDataArray() {
        if (players.count > 0) {
            view.hideSkeleton()
            players.sort(by: {
                if($0.primaryPosition == $1.primaryPosition) {
                    if($0.secondaryPosition == $1.secondaryPosition) {
                        return $0.nickname < $1.nickname
                    } else {
                        return $0.secondaryPosition < $1.secondaryPosition
                    }
                } else {
                    return $0.primaryPosition < $1.primaryPosition
                }
            })
            
            
            for player in players {
                self.dataArray.append([player.firstName, player.lastName, player.positionName, "\(player.age)", "\(player.playerTotalStats.avgPTS)", "\(player.playerTotalStats.avgAST)", "\(player.playerTotalStats.avgFGP)", "\(player.playerTotalStats.avgTREB)", "\(player.playerTotalStats.avgBLK)", "\(player.playerTotalStats.avgSTL)", "\(player.playerTotalStats.avgMINS)", "\(player.playerTotalStats.avgEFF)"])
            }
            
            self.playerStatsCollectionView.reloadData()
        }
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
        return 11
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
                    cell.playerImage.image = UIImage(named: "lebronJames")
                    cell.firstName.text = dataArray[indexPath.section - 1][indexPath.row]
                    cell.lastName.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
                }
                cell.firstName.font = .systemFont(ofSize: 11)
                cell.lastName.font = .systemFont(ofSize: 11)

                cell.backgroundColor = UIColor(hexString: "484848")

                return cell
            }
        default:
            if(indexPath.section == 0) {
                //Stat Titles
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLabel.text = statTitles[indexPath.row + 1]
                
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
                    cell.titleLabel.text = dataArray[indexPath.section - 1][indexPath.row + 1]
                } else {
                    cell.titleLabel.text = ""
                }

                cell.backgroundColor = UIColor(hexString: "2b2b2b", withAlpha: 0.5)

                return cell
            }
        }
    }
}

extension PlayersOverviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return CGSize(width: 130, height: 40)
            } else {
                return CGSize(width: 130, height: 50)
            }
        default:
            if(indexPath.section == 0) {
                return CGSize(width: 55, height: 40)
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

