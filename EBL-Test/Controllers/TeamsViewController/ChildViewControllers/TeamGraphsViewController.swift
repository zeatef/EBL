//
//  TeamGraphsViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/23/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Charts

class TeamGraphsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var opponentCollectionView: UICollectionView!
    @IBOutlet weak var gridTableLayout: GridTableCustomLayout! {
        didSet {
            gridTableLayout.stickyRowsCount = 0
            gridTableLayout.stickyColumnsCount = 0
        }
    }
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statButtonsView: UIView!
    @IBOutlet weak var periodButtonsView: UIView!
    
    
    @IBOutlet weak var chartView: LineChartView!
    
    //MARK: - Instance Variables
    let dbManager = DatabaseManager.sharedInstance
    var team : TeamDisplayData?

    var opponentNames : [String] = []
    var allGames : [TeamGameStats] = []
    
    var teamsSelected : [Bool] = Array(repeating: false, count: 16)
    var statSelected : Int = 0
    var periodSelected : Int = 0
    
    
    //MARK: - ViewDidLoad & RegisterXibFiles
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXibFiles()
        setupTeamsData()
        setupFilterOptions()
        setupOpponentsCollectionView()
        setupStatButtons()
        setupPeriodButtons()
        getAllTeamGames { (error) in
            if let error = error {
                print(error)
            } else {
                self.setupChartView()
                self.chartView.animate(xAxisDuration: 0.3, easingOption: .easeInBack)
            }
        }
        
    }
    
    func registerXibFiles(){
        opponentCollectionView.register(UINib(nibName: "OpponentPickerCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "OpponentPickerCell")
    }
    
    //MARK: - Setup Instance Variables
    func setupTeamsData() {
        team = (parent as! TeamsViewController).team!
        
        opponentNames.append("League")
        for i in dbManager.teamsDisplayData {
            if(i.teamID != team!.teamID) {
                opponentNames.append(i.teamID)
            }
        }
        opponentNames.append("League")
        opponentNames.append("League")
    }
    
    func getAllTeamGames(completion: @escaping  (Error?) -> Void) {
        dbManager.getTeamGameStats(forTeamRef: (parent as! TeamsViewController).team!.teamRef) { (error, hasData, games) in
            if let error = error {
                print(error)
                completion(error)
            } else {
                if hasData! {
                    self.allGames = games!
                }
                completion(nil)
            }
        }
    }
    
    //MARK: - Setup OpponentCollectionView
    func setupOpponentsCollectionView() {
        opponentCollectionView.allowsMultipleSelection = true
        
        for i in 0...teamsSelected.count-1 {
            if(teamsSelected[i]) {
                opponentCollectionView.selectItem(at: IndexPath(row: i%6, section: i/6), animated: true, scrollPosition: .centeredVertically)
            }
        }
        collectionViewHeightConstraint.constant = ((view.frame.width - 30)/8) * 2
        view.updateConstraints()
    }
    
    //MARK: - Setup StatsSelectedView
    func setupStatButtons() {
        let button = statButtonsView.viewWithTag(statSelected) as! ButtonWithBorder
        button.selectButton()
    }
    
    @IBAction func statButtonPressed(_ sender: ButtonWithBorder) {
        if(statSelected != sender.tag) {
            let button = statButtonsView.viewWithTag(statSelected) as! ButtonWithBorder
            button.deselectButton()
            statSelected = sender.tag
            sender.selectButton()
            setupChartView()
        }
    }
    
    //MARK: - Setup PeriodSelectedView
    func setupPeriodButtons() {
        let button = periodButtonsView.viewWithTag(periodSelected) as! ButtonWithBorder
        button.selectButton()
    }
    
    @IBAction func periodButtonPressed(_ sender: ButtonWithBorder) {
        if(periodSelected != sender.tag) {
            let button = periodButtonsView.viewWithTag(periodSelected) as! ButtonWithBorder
            button.deselectButton()
            periodSelected = sender.tag
            sender.selectButton()
            setupChartView()
        }
    }

    
    //MARK: - Setup LineChartView
    func setupChartView() {
        setupChartAxes()
        setupChartViewSettings()
        setupChartLegend()
        setupChartData()
    }
    
    func setupChartViewSettings() {
        chartView.delegate = self
        chartView.dragEnabled = true
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.gridBackgroundColor = UIColor(hexString: "2B2B2B", withAlpha: 0.3)
        chartView.drawGridBackgroundEnabled = true
        
        let marker = RadarMarkerView.viewFromXib()!
        marker.chartView = chartView
        chartView.marker = marker
    }
    
    func setupChartLegend() {
        chartView.legend.enabled = true
        chartView.legend.verticalAlignment = .top
        chartView.legend.horizontalAlignment = .center
        chartView.legend.font = .systemFont(ofSize: 10, weight: .regular)
        chartView.legend.form = .line
        chartView.legend.formLineWidth = 2
        chartView.legend.formSize = 20
        chartView.legend.textColor = UIColor(hexString: "E1E1E1")
    }
    
    func setupChartAxes() {
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.spaceMax = 1
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.labelTextColor = UIColor(hexString: "E1E1E1")
        chartView.xAxis.labelFont = .systemFont(ofSize: 8, weight: .semibold)
        
        
        chartView.leftAxis.granularity = 1
        chartView.leftAxis.labelTextColor = UIColor(hexString: "E1E1E1")
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.rightAxis.enabled = false
        
    }
    
    
    
    func setupChartData() {
        var datasets : [LineChartDataSet] = []
        
        var result = allGames
        result.sort(by: {
            return $0.date.compare($1.date) == .orderedDescending
        })
        result = setupPeriodSelected(games: result)
        result = setupOpponentsSelected(games: result)
        
        if(!result.isEmpty) {
            result.append(contentsOf: result)
            result.append(contentsOf: result)
            result.append(contentsOf: result)
            datasets = setupStatsSelected(games: result)
            
            setupAxisLabels(games: result)
            
            let data = LineChartData(dataSets: datasets)
            data.setDrawValues(false)
            chartView.data = data
            chartView.setVisibleXRangeMaximum(100)
            chartView.invalidateIntrinsicContentSize()
        } else {
            chartView.data = nil
            chartView.invalidateIntrinsicContentSize()
        }
    }
    
    func setupAxisLabels(games: [TeamGameStats]) {
        var xAxisLabels = [""]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"

        for item in games {
            xAxisLabels.append(item.opponentAbb + "\n" + dateFormatter.string(from: item.date))
        }
       
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xAxisLabels)
    }
    
    //MARK: - Setup Filters
    func setupFilterOptions() {
        teamsSelected[0] = true
        statSelected = 1
        periodSelected = 1
    }
    
    func setupPeriodSelected(games: [TeamGameStats]) -> [TeamGameStats] {
        print(periodSelected)
        switch periodSelected {
        case 2:
            return Array(games.suffix(5))
        case 3:
            return Array(games.suffix(10))
        case 4:
            return Array(games.suffix(20))
        default:
            return games
        }
    }
    
    func setupOpponentsSelected(games: [TeamGameStats]) -> [TeamGameStats] {
        if(teamsSelected[0]) {
            return games
        } else {
            var result : [TeamGameStats] = []
            for i in 1...teamsSelected.count-1 {
                if(teamsSelected[i]) {
                    result.append(contentsOf: filterTeams(team: opponentNames[i], games: games))
                }
            }
            return result
        }
    }
    
    func filterTeams(team: String, games: [TeamGameStats]) -> [TeamGameStats] {
        var result : [TeamGameStats] = []
        for game in games {
            if game.opponentAbb == team {
                result.append(game)
            }
        }
        return result
    }
    
    func setupStatsSelected(games: [TeamGameStats]) -> [LineChartDataSet] {
        var datasets : [LineChartDataSet] = []
        var entries : [ChartDataEntry] = []
        switch statSelected {
        //PTS
        case 1:
            for i in 0...1 {
                entries = []
                let firstValue = (i == 0 ? Double(games[0].PTS) : Double(games[0].opponentPTS))
                entries.append(ChartDataEntry(x: Double(0), y: firstValue))
                for j in 0...games.count-1 {
                    let value = (i == 0 ? Double(games[j].PTS) : Double(games[j].opponentPTS))
                    let entry = ChartDataEntry(x: Double(j+1), y: value)
                    entry.data = Int(entry.y) as AnyObject
                    entries.append(entry)
                }
                if (i == 0) {
                    let dataset = LineChartDataSet(values: entries, label: "PTS Scored")
                    setupDatasetOptions(dataset: dataset, color: "17DA2E")
                    datasets.append(dataset)
                } else {
                    let dataset = LineChartDataSet(values: entries, label: "PTS Allowed")
                    setupDatasetOptions(dataset: dataset, color: "E81212")
                    datasets.append(dataset)
                }
            }
        //FG%
        case 2:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avgFGP*100)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].avgFGP*100)))
            }
            let dataset = LineChartDataSet(values: entries, label: "FG%")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //3FG%
        case 3:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avg3FGP*100)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].avg3FGP*100)))
            }
            let dataset = LineChartDataSet(values: entries, label: "3FG%")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //2FG%
        case 4:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avg2FGP*100)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].avg2FGP*100)))
            }
            let dataset = LineChartDataSet(values: entries, label: "2FG%")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //FT%
        case 5:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avgFTP*100)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].avgFTP*100)))
            }
            let dataset = LineChartDataSet(values: entries, label: "FT%")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //AST
        case 6:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].AST)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].AST)))
            }
            let dataset = LineChartDataSet(values: entries, label: "AST")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //REB
        case 7:
            for i in 0...2 {
                entries = []
                let firstValue = (i == 0 ? Double(games[0].REB) : (i == 1 ? Double(games[0].ORB) : Double(games[0].DRB)))
                entries.append(ChartDataEntry(x: Double(0), y: firstValue))
                for j in 0...games.count-1 {
                    let value = (i == 0 ? Double(games[j].REB) : (i == 1 ? Double(games[j].ORB) : Double(games[j].DRB)))
                    let entry = ChartDataEntry(x: Double(j+1), y: value)
                    entry.data = Int(entry.y) as AnyObject
                    entries.append(entry)
                }
                if (i == 0) {
                    let dataset = LineChartDataSet(values: entries, label: "Total Rebounds")
                    setupDatasetOptions(dataset: dataset, color: "FFA442")
                    datasets.append(dataset)
                } else if (i == 1) {
                    let dataset = LineChartDataSet(values: entries, label: "Offensive Rebounds")
                    setupDatasetOptions(dataset: dataset, color: "429DFF")
                    datasets.append(dataset)
                } else {
                    let dataset = LineChartDataSet(values: entries, label: "Defensive Rebounds")
                    setupDatasetOptions(dataset: dataset, color: "DAF7A6")
                    datasets.append(dataset)
                }
            }
        //STL
        case 8:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].STL)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].STL)))
            }
            let dataset = LineChartDataSet(values: entries, label: "STL")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //TO
        case 9:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].TO)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].TO)))
            }
            let dataset = LineChartDataSet(values: entries, label: "TO")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)
        //BLK
        case 10:
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].BLK)))
            for j in 0...games.count-1 {
                entries.append(ChartDataEntry(x: Double(j+1), y: Double(games[j].BLK)))
            }
            let dataset = LineChartDataSet(values: entries, label: "BLK")
            setupDatasetOptions(dataset: dataset, color: "FFA442")
            datasets.append(dataset)

        default:
            print("Default")
        }
        
        return datasets

    }
    
    func setupDatasetOptions(dataset: LineChartDataSet, color: String) {
        dataset.setColor(UIColor(hexString: color))
        dataset.setCircleColor(UIColor(hexString: color, withAlpha: 0.5))
        dataset.circleRadius = 5
        dataset.circleHoleRadius = 2
        dataset.circleHoleColor = UIColor.flatGray()
        dataset.valueTextColor = UIColor.flatWhiteColorDark()
        dataset.valueFont = .systemFont(ofSize: 10)
        dataset.drawHorizontalHighlightIndicatorEnabled = true
        dataset.drawVerticalHighlightIndicatorEnabled = false
    }
    
}

//MARK: - Collection View Delegate
extension TeamGraphsViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
}

//MARK: - Collection View DataSource
extension TeamGraphsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpponentPickerCell", for: indexPath) as? OpponentPickerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let index = (indexPath.section * 8) + indexPath.row
        cell.imageView.kf.setImage(with: dbManager.getTeamImageURL(teamID: opponentNames[index]))
        
        if(!cell.isSelected) {
            cell.imageView.alpha = 0.2
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0) {
            toggleCell(at: indexPath)
            if let indexes = collectionView.indexPathsForSelectedItems {
                for index in indexes {
                    if(!(index.section == 0 && index.row == 0)) {
                        collectionView.deselectItem(at: index, animated: true)
                        toggleCell(at: index)
                    }
                }
            }
        } else {
            toggleCell(at: indexPath)
            if(collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!.isSelected) {
                collectionView.deselectItem(at: IndexPath(row: 0, section: 0), animated: true)
                toggleCell(at: IndexPath(row: 0, section: 0))
            }
        }
        setupChartView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        } else {
            toggleCell(at: indexPath)
            if let indexes = collectionView.indexPathsForSelectedItems {
                if(indexes.count == 0) {
                    collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
                    toggleCell(at: IndexPath(row: 0, section: 0))
                }
            }
        }
        setupChartView()
    }
    
    func toggleCell(at indexPath: IndexPath) {
        let cell = opponentCollectionView.cellForItem(at: indexPath) as! OpponentPickerCollectionViewCell
        cell.imageView.alpha = cell.imageView.alpha == 1 ? 0.2 : 1
        teamsSelected[(indexPath.section * 8) + indexPath.row] = !(teamsSelected[(indexPath.section * 8) + indexPath.row])
    }
}

extension TeamGraphsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width)/8, height: (collectionView.frame.width)/8)
    }
}

//MARK: - ChartView Delegate
extension TeamGraphsViewController : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if(entry.x == 0) {
            chartView.highlightValues([])
        }
    }
}
