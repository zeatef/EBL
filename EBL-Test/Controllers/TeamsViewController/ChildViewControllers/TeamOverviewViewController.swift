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
    
    //MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
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
    

    
    //MARK: - Instance Variables
    var parentVC : TeamsViewController?
    let dbManager = DatabaseManager.sharedInstance
    var team : Team?
    var topPerformersData : [[String]] = []
    var teamStats : [Double] = []
    var leagueStats : [Double] = []
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hexString: "E1E1E1")
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Default Functions
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
    
    //MARK:- Setup View Controller Functions
    func setupView(){
        scrollView.refreshControl = refresher
        let primaryColor = UIColor(hexString: parentVC!.team!.primaryColor)!
        let secondaryColor = UIColor(hexString: parentVC!.team!.secondaryColor)!

        if(parentVC!.team!.abb == "ASC") {
            parentVC!.bottomBorder.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: parentVC!.bottomBorder.frame, andColors:[primaryColor, secondaryColor])
        } else {
            parentVC!.bottomBorder.backgroundColor = UIColor(gradientStyle: UIGradientStyle.leftToRight, withFrame: parentVC!.bottomBorder.frame, andColors:[primaryColor, primaryColor, secondaryColor, secondaryColor, primaryColor, primaryColor])
        }
        showLoadingViews()
        parentVC!.setupTeamInfo(source: .cache) { (error) in
            if let error = error {
                print(error)
            } else {
                self.team = self.parentVC!.team
                self.updateViewData()
            }
        }
    }
    
    @objc func reloadData() {
        parentVC!.setupTeamInfo(source: .server) { (error) in
            if let error = error {
                print(error)
            } else {
                self.team = self.parentVC!.team
                self.refresher.endRefreshing()
                self.updateViewData()
            }
        }
    }

    func showLoadingViews() {
        parentVC!.teamOverview.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
        topPerformersVeiw.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
        teamAveragesView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: view.backgroundColor!))
    }
    
    func hideLoadingViews() {
        parentVC!.teamOverview.hideSkeleton()
        topPerformersVeiw.hideSkeleton()
        teamAveragesView.hideSkeleton()
        
    }
    
    func updateViewData() {
        setupTeamOverviewSubview()
        setupTopPerformersSubview()
        setupTeamAveragesSubview { (error) in
            if let error = error {
                print(error)
            } else {
                self.hideLoadingViews()
            }
        }
    }
    
    //MARK:- Setup Subviews
    
    func setupTeamOverviewSubview(){
        //TeamOverview Subview
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        
        parentVC!.teamImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: team!.abb))
//        leagueRanking.text = formatter.string(from: team!.leagueStanding as NSNumber)!
        parentVC!.headCoach.text = team!.headCoach
        parentVC!.hometown.text = team!.location
        parentVC!.seasonRecord.text = "\(team!.statistics!.wins!)-\(team!.statistics!.losses!)"
        
    }
    
    
    func setupTopPerformersSubview() {
        if(team!.statistics!.gamesPlayed == 0) {
            topPerformersVeiw.isHidden = true
        } else {
            topPerformersData = []
            topPerformersData.append(["", "PPG", "FG%", "3FG%", "2FG%", "FT%", "APG", "RPG", "STPG", "BLKPG", "EFFPG"])
            for player in team!.top3Players! {
                let stats = [
                    player.knownAs.first,
                    player.knownAs.last,
                    "\(player.statistics!.PTS.perGame)",
                    "\(String(format: "%.1f", player.statistics!.FG.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FG3.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FG2.percentage*100.0))%",
                    "\(String(format: "%.1f", player.statistics!.FT.percentage*100.0))%",
                    "\(player.statistics!.AST.perGame)",
                    "\(player.statistics!.TREB.perGame)",
                    "\(player.statistics!.STL.perGame)",
                    "\(player.statistics!.BLK.perGame)",
                    "\(player.statistics!.EFF!.perGame)"
                ]
                topPerformersData.append(stats)
            }
            topPerformersCollectionView.reloadData()
        }
    }
    
    
    func setupTeamAveragesSubview(completion: @escaping (Error?) -> Void) {
        if(team!.statistics!.gamesPlayed == 100) {
            teamAveragesView.removeFromSuperview()
            self.view.updateConstraints()
            completion(nil)
        } else {
            setupChartViewSettings()
            setupChartLegend()
            setupChartAxes()
            setupChartData { (error) in
                if let error = error {
                    completion(error)
                } else {
                    self.chartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeOutQuart)
                    completion(nil)
                }
            }
        }
    }
    
    //MARK:- Team Averages Subview Functions
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
    
    func setupChartData(completion: @escaping (Error?) -> Void) {
        if(team!.statistics!.gamesPlayed == 0) {
            chartView.data = nil
            completion(nil)
        } else {
            dbManager.getLeagueAverages { (leagueAverages, error) in
                if let error = error {
                    completion(error)
                } else {
                    var datasets : [RadarChartDataSet] = []
                    
                    var standardizedStats = self.team!.statistics!
                    let teamDataArray = [standardizedStats.PTS.perGame, standardizedStats.FG.percentage*100, standardizedStats.FG3.percentage*100, standardizedStats.FG2.percentage*100, standardizedStats.FT.percentage*100, standardizedStats.AST.perGame, standardizedStats.TREB.perGame, standardizedStats.STL.perGame, standardizedStats.TO.perGame]
                    
                    standardizedStats = leagueAverages!
                    let leagueDataArray = [standardizedStats.PTS.perGame, standardizedStats.FG.percentage*100, standardizedStats.FG3.percentage*100, standardizedStats.FG2.percentage*100, standardizedStats.FT.percentage*100, standardizedStats.AST.perGame, standardizedStats.TREB.perGame, standardizedStats.STL.perGame, standardizedStats.TO.perGame]
                    
                    var leagueEntries : [RadarChartDataEntry] = []
                    for i in 0...leagueDataArray.count-1 {
                        let entry = RadarChartDataEntry(value: 100.0)
                        entry.data = [self.team!.abb, teamDataArray[i], leagueDataArray[i], i]
                        leagueEntries.append(entry)
                    }
                    let leagueDataset = RadarChartDataSet(entries: leagueEntries, label: "League")
                    self.setupDatasetOptions(dataset: leagueDataset, color: UIColor(hexString: self.team!.primaryColor), isLeagueDataset: true)

                    var teamEntries : [RadarChartDataEntry] = []
                    for i in 0...teamDataArray.count-1 {
                        let entry = RadarChartDataEntry(value: teamDataArray[i] * 100 / leagueDataArray[i])
                        entry.data = [self.team!.abb, teamDataArray[i], leagueDataArray[i], i]
                        teamEntries.append(entry)
                    }
                    let teamDataset = RadarChartDataSet(entries: teamEntries, label: self.team!.abb)
                    self.setupDatasetOptions(dataset: teamDataset, color: UIColor(hexString: self.team!.primaryColor), isLeagueDataset: false)
                    
                    datasets.append(teamDataset)
                    datasets.append(leagueDataset)
                    let data = RadarChartData(dataSets: datasets)
                    self.chartView.yAxis.axisMaximum = data.yMax + 10
                    self.chartView.data = data
                    self.chartView.highlightValue(x: Double(0), dataSetIndex: 1)
                    completion(nil)
                }
            }
        }
    }
    
    func setupDatasetOptions(dataset: RadarChartDataSet, color: UIColor, isLeagueDataset: Bool) {
        if(isLeagueDataset) {
            dataset.lineWidth = 3
            dataset.drawValuesEnabled = false
            dataset.drawFilledEnabled = false
            dataset.setColor(UIColor(hexString: "2b2b2b"))
        } else {
            dataset.lineWidth = 2.5
            dataset.drawFilledEnabled = true
            dataset.highlightEnabled = false
            dataset.fillColor = color
            dataset.fillAlpha = 0.4
            dataset.setColor(color)
        }
        
        dataset.drawHighlightCircleEnabled = true
        dataset.setDrawHighlightIndicators(false)
        dataset.valueFont = .systemFont(ofSize: 11, weight: .regular)
        dataset.valueTextColor = UIColor.white
        dataset.valueFormatter = self
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
                if(topPerformersData.count > 0) {
                    cell.firstName.text = topPerformersData[indexPath.section][indexPath.row]
                    cell.lastName.text = topPerformersData[indexPath.section][indexPath.row + 1]
                }
                cell.backgroundColor = UIColor(hexString: "484848")

                return cell
            }
        default:
            if(indexPath.section == 0) {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell2", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                if(topPerformersData.count > 0) {
                    cell.titleLabel.text = topPerformersData[indexPath.section][indexPath.row]
                }
                cell.titleLabel.textColor = UIColor(hexString: "ffffff")
                cell.backgroundColor = UIColor(hexString: "2b2b2b")

                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell3", for: indexPath) as? StatsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                if(topPerformersData.count > 0) {
                    cell.titleLabel.text = topPerformersData[indexPath.section][indexPath.row + 1]
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
        let index = dataSetIndex == 0 ? 1 : 2
        
        let data = entry.data as! [Any]
        
        if((data[3] as! Int) > 0 && (data[3] as! Int) < 5) {
            return "\(String(format: "%.1f", data[index] as! Double))%"
            } else {
            return "\(String(format: "%.1f", data[index] as! Double))"
        }
    }
    
    
}



