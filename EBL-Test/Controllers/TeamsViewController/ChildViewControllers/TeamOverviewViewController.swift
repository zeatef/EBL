//
//  TeamOverviewViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/23/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import ChameleonFramework
import Charts
import SkeletonView

class TeamOverviewViewController: UIViewController {
    
    //MARK: - Initialize Outlets
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var leagueRanking: UILabel!
    @IBOutlet weak var teamRecord: UILabel!
    @IBOutlet weak var headCoach: UILabel!
    @IBOutlet weak var hometown: UILabel!
    @IBOutlet weak var teamOverviewView: UIView!
    @IBOutlet weak var teamOverviewBottomBorder: UIView!
    @IBOutlet weak var topPerformersVeiw: UIView!
    @IBOutlet weak var topPerformersCollectionView: UICollectionView!
    @IBOutlet weak var gridLayout: GridTableCustomLayout! {
        didSet {
            gridLayout.stickyRowsCount = 1
            gridLayout.stickyColumnsCount = 1
        }
    }
    @IBOutlet weak var teamAveragesView: UIView!
    @IBOutlet weak var chartView: RadarChartView!
    
    var parentVC : TeamsViewController?

    
    //MARK: - Instance Variables
    let dbManager = DatabaseManager.sharedInstance
    var teamRef = ""
    var team : Team?
    var playerDataArray = [[String]]()
    var teamStats : [Double] = []
    var leagueStats : [Double] = []
    
    
    //MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        registerXibFiles()

        setupView()
    }
    
    func registerXibFiles(){
        topPerformersCollectionView.register(UINib(nibName: "StatsCollectionViewCell1", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell1")
        topPerformersCollectionView.register(UINib(nibName: "StatsCollectionViewCell2", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell2")
        topPerformersCollectionView.register(UINib(nibName: "StatsCollectionViewCell3", bundle: Bundle.main), forCellWithReuseIdentifier: "StatsCell3")
    }
    
    func setupView(){
        let primaryColor = UIColor(hexString: parentVC!.team!.primaryColor)!
        let secondaryColor = UIColor(hexString: parentVC!.team!.secondaryColor)!

        if(parentVC!.team!.teamID == "ASC") {
            teamOverviewBottomBorder.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: teamOverviewBottomBorder.frame, andColors:[primaryColor, secondaryColor])
        } else {
            teamOverviewBottomBorder.backgroundColor = UIColor(gradientStyle: UIGradientStyle.leftToRight, withFrame: teamOverviewBottomBorder.frame, andColors:[primaryColor, primaryColor, secondaryColor, secondaryColor, primaryColor, primaryColor])
        }
        showLoadingViews()
        fetchViewData { (error) in
            if let error = error {
                print(error)
            } else {
                self.updateViewData()
            }
        }
    }
    
    func fetchViewData(completion: @escaping (Error?) -> Void) {
        let start = DispatchTime.now()

        dbManager.getTeamInfo(forTeamRef: teamRef, completion: { (error, team) in
            if let error = error {
                completion(error)
            } else {
                self.team = team!
                self.parentVC?.getPlayersData(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        let end = DispatchTime.now()
                        let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
                        print("Completed in \(Double(difference) / 1_000_000_000) seconds.")
                        completion(nil)
                    }
                })
            }
        })
    }
    
    func showLoadingViews() {
        teamOverviewView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
        topPerformersVeiw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
        teamAveragesView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
    }
    
    func hideLoadingViews() {
        teamOverviewView.hideSkeleton()
        topPerformersVeiw.hideSkeleton()
        teamAveragesView.hideSkeleton()
        
    }
    
    func updateViewData() {
        setupTeamOverviewSubview()
        setupTopPerformersSubview()
        setupTeamAveragesSubview()
        
        hideLoadingViews()
    }
    
    //MARK:- Setup Team Overview Subview
    
    func setupTeamOverviewSubview(){
        //TeamOverview Subview
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        
        teamImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: team!.abb))
        leagueRanking.text = formatter.string(from: team!.leagueStanding as NSNumber)!
        headCoach.text = team!.headCoach
        hometown.text = team!.location
        teamRecord.text = "\(team!.wins)-\(team!.losses)"
        
    }
    
    //MARK:- Setup Top Performers Subview
    
    func setupTopPerformersSubview() {
        setupPlayersDataArray()
    }
    
    func setupPlayersDataArray() {
        let statTitles = ["", "", "PPG", "FG%", "3FG%", "2FG%", "FT%" ,"APG", "RPG", "STPG", "BLKPG", "EFPG"]
        
        parentVC!.players.sort(by: {
            if($0.playerTotalStats.avgEFF == $1.playerTotalStats.avgEFF) {
                return $0.nickname < $1.nickname
            } else {
                return $0.playerTotalStats.avgEFF > $1.playerTotalStats.avgEFF
            }
        })
        
        playerDataArray.append(statTitles)
        
        for i in 0...2 {
            let player = parentVC!.players[i]
            self.playerDataArray.append([player.firstName, player.lastName, "\(player.playerTotalStats.avgPTS)", "\(player.playerTotalStats.avgFGP)","\(player.playerTotalStats.avg3FGP)", "\(player.playerTotalStats.avg2FGP)", "\(player.playerTotalStats.avgFTP)", "\(player.playerTotalStats.avgAST)", "\(player.playerTotalStats.avgTREB)", "\(player.playerTotalStats.avgSTL)", "\(player.playerTotalStats.avgBLK)",  "\(player.playerTotalStats.avgEFF)"])
        }
        
        self.topPerformersCollectionView.reloadData()
    }
    
    //MARK:- Setup Team Averages Subview
    
    func setupTeamAveragesSubview() {
        setupChartView()
        
    }
    
    func setupChartView() {
        setupChartViewSettings()
        setupChartLegend()
        setupChartAxes()
        setupChartData()
        chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeOutQuart)
    }
    
    func setupChartViewSettings() {
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.extraTopOffset = 40.0
        chartView.highlightPerTapEnabled = true
        chartView.rotationEnabled = false
        
        //Marker
        let marker = RadarMarkerView.viewFromXib()!
        marker.chartView = chartView
        chartView.marker = marker
    }
    
    func setupChartLegend() {
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.orientation = .horizontal
        chartView.legend.drawInside = true
        chartView.legend.font = .systemFont(ofSize: 10, weight: .regular)
        chartView.legend.form = .line
        chartView.legend.formLineWidth = 3
        chartView.legend.formSize = 15
        chartView.legend.xEntrySpace = 7
        chartView.legend.yEntrySpace = 0
        chartView.legend.textColor = UIColor(hexString: "E1E1E1")
    }
    
    func setupChartAxes() {
        chartView.yAxis.axisMinimum = 0.0
        chartView.yAxis.enabled = false
        
        chartView.xAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        chartView.xAxis.labelTextColor = UIColor(hexString: "E1E1E1")
        chartView.xAxis.xOffset = 0
        chartView.xAxis.yOffset = 0
        chartView.xAxis.valueFormatter = self
    }
    
    func setupChartData() {
        var datasets : [RadarChartDataSet] = []

        teamStats = [team!.teamTotalStats.avgPTS, team!.teamTotalStats.avgFGP*100, team!.teamTotalStats.avg3FGP*100, team!.teamTotalStats.avg2FGP*100, team!.teamTotalStats.avgFTP*100, team!.teamTotalStats.avgAST, team!.teamTotalStats.avgTREB, team!.teamTotalStats.avgSTL, team!.teamTotalStats.avgTO]
        
        let standardizedTeamStats = standardizeData(stats: teamStats)
        var teamEntries : [RadarChartDataEntry] = []
        for i in 0...standardizedTeamStats.count-1 {
            let entry = RadarChartDataEntry(value: standardizedTeamStats[i])
            entry.data = teamStats[i] as AnyObject
            teamEntries.append(entry)
        }
        let teamDataset = RadarChartDataSet(entries: teamEntries, label: team!.abb)
        setupDatasetOptions(dataset: teamDataset, color: UIColor(hexString: team!.primaryColor))
        datasets.append(teamDataset)
        
        leagueStats = [87.3, 47.4, 42.2, 49.0, 65.5, 18.0, 28.0, 13.0, 19.0]
        let standardizedLeagueStats = standardizeData(stats: leagueStats)
        var leagueEntries : [RadarChartDataEntry] = []
        for i in 0...standardizedLeagueStats.count-1 {
            let entry = RadarChartDataEntry(value: standardizedLeagueStats[i])
            entry.data = leagueStats[i] as AnyObject
            leagueEntries.append(entry)
        }
        let leagueDataset = RadarChartDataSet(entries: leagueEntries, label: "League")
        setupDatasetOptions(dataset: leagueDataset)
        datasets.append(leagueDataset)
        
        let data = RadarChartData(dataSets: datasets)
        chartView.yAxis.axisMaximum = data.yMax
        chartView.data = data
    }
    
    func setupDatasetOptions(dataset: RadarChartDataSet, color: UIColor = UIColor.flatOrange()) {
        if(color == UIColor.flatOrange()) {
            dataset.lineWidth = 1.5
            dataset.drawValuesEnabled = false
            dataset.drawFilledEnabled = false
            dataset.highlightEnabled = true
            dataset.drawHighlightCircleEnabled = true
            dataset.setDrawHighlightIndicators(false)

            if(parentVC!.team!.teamID == "SHA") {
                dataset.setColor(UIColor(complementaryFlatColorOf: color))
            } else {
                dataset.setColor(color)
            }
        } else {
            dataset.lineWidth = 2
            dataset.drawFilledEnabled = true
            dataset.fillColor = color
            dataset.fillAlpha = 0.3
            dataset.highlightEnabled = false
            dataset.setColor(color)
        }
        dataset.valueFont = .systemFont(ofSize: 10, weight: .light)
        dataset.valueTextColor = UIColor.white
        dataset.valueFormatter = self
    }
    
    func standardizeData(stats : [Double]) -> [Double] {
        var result : [Double] = []
        for i in 0...stats.count-1 {
            switch i {
            //PTS
            case 0 :
                if(stats[i] == 0) {
                    result.append(stats[i])
                } else {
                    result.append(((stats[i] - 30.0) * 100) / (120.0 - 30.0))
                }
            //AST
            case 5 :
                if(stats[i] == 0) {
                    result.append(stats[i])
                } else {
                    result.append(((stats[i] - 5.0) * 100) / (40.0 - 5.0))
                }
            //REB
            case 6 :
                if(stats[i] == 0) {
                    result.append(stats[i])
                } else {
                    result.append(((stats[i] - 10.0) * 100) / (60.0 - 10.0))
                }
            //STL
            case 7 :
                if(stats[i] == 0) {
                    result.append(stats[i])
                } else {
                    result.append(((stats[i] - 5.0) * 100) / (30.0 - 5.0))
                }
            //TO
            case 8 :
                if(stats[i] == 0) {
                    result.append(stats[i])
                } else {
                    result.append(((stats[i] - 5.0) * 100) / (40.0 - 5.0))
                }
            default :
                result.append(stats[i])
            }
        }
        return result
    }

}

// MARK: - Collection view data source and delegate methods
extension TeamOverviewViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell1", for: indexPath) as? PlayerNameAndImageCell else {
                    return UICollectionViewCell()
                }
                
                cell.playerImage.image = UIImage(named: "player")
                if(playerDataArray.count > 0) {
                    cell.firstName.text = playerDataArray[indexPath.section][indexPath.row]
                    cell.lastName.text = playerDataArray[indexPath.section][indexPath.row + 1]
                }
                cell.backgroundColor = UIColor(hexString: "484848")

                return cell
            }
        default:
            if(indexPath.section == 0) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                if(playerDataArray.count > 0) {
                    cell.titleLabel.text = playerDataArray[indexPath.section][indexPath.row + 1]
                }
                cell.titleLabel.textColor = UIColor(hexString: "ffffff")
                cell.backgroundColor = UIColor(hexString: "2b2b2b")

                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell3", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                if(playerDataArray.count > 0) {
                    cell.titleLabel.text = playerDataArray[indexPath.section][indexPath.row + 1]
                }
                cell.backgroundColor = UIColor(hexString: "2b2b2b", withAlpha: 0.5)

                return cell
            }
        }
    }
}

extension TeamOverviewViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch indexPath.row {
        case 0:
            if(indexPath.section == 0) {
                return CGSize(width: 130, height: 25)
            } else {
                return CGSize(width: 130, height: 50)
            }
        default:
            if(indexPath.section == 0) {
                return CGSize(width: 55, height: 25)
            } else {
                return CGSize(width: 55, height: 50)

            }
        }
    }
}

extension TeamOverviewViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch value {
        case 0.0:
            return "PPG"
        case 1.0:
            return "FG%"
        case 2.0:
            return "3FG%"
        case 3.0:
            return "2FG%"
        case 4.0:
            return "FT%"
        case 5.0:
            return "APG"
        case 6.0:
            return "RPG"
        case 7.0:
            return "STPG"
        case 8.0:
            return "TOPG"
        default:
            return "\(value)"
        }
    }
}

extension TeamOverviewViewController: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(String(format: "%.1f", entry.data as! Double))"
    }
    
    
}



