//
//  TeamStatsChartView.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 5/13/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Charts

class TeamChartManager {
    
    //MARK:- Instance Variables
    var chart : CombinedChartView
    
    var team : TeamDisplayData?
    
    var allOpponentsSelected : Bool = true {
        didSet {
            if(allOpponentsSelected) {
                opponentsSelected = []
            }
        }
    }
    var opponentsSelected : [String] = []
    var stat : Int = 1
    var period : Int = 1
    
    var allGames : [TeamGameStats] = [] {
        didSet {
            initializeChartView()
        }
    }
    var gamesToFilter : [TeamGameStats] = []

    //MARK:- Initialization
    init(chartView: CombinedChartView, team: TeamDisplayData) {
        self.chart = chartView
        chart.noDataText = "No games played against the selected teams yet."
        chart.noDataTextColor = UIColor(hexString: "E1E1E1")
        chart.noDataFont = .systemFont(ofSize: 11, weight: .semibold)
        self.team = team
    }
    
    func initializeChartView() {
        gamesToFilter = addGamesRandomly(numberOfGames: 40, games: allGames)
        setupChartViewSettings()
        setupChartAxes()
        setupChartLegend()
        updateChartView()
    }
    
    func setupChartViewSettings() {
        chart.delegate = self
        chart.dragEnabled = true
        chart.scaleXEnabled = true
        chart.scaleYEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.gridBackgroundColor = UIColor(hexString: "2B2B2B", withAlpha: 0.3)
        chart.drawGridBackgroundEnabled = true
    }
    
    func setupChartLegend() {
        chart.legend.enabled = true
        chart.legend.verticalAlignment = .top
        chart.legend.horizontalAlignment = .center
        chart.legend.font = .systemFont(ofSize: 10, weight: .regular)
        chart.legend.form = .line
        chart.legend.formLineWidth = 2
        chart.legend.formSize = 20
        chart.legend.textColor = UIColor(hexString: "E1E1E1")
    }
    
    func setupChartAxes() {
        chart.xAxis.granularity = 1
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.spaceMin = 0.5
        chart.xAxis.spaceMax = 0.5
        chart.xAxis.drawGridLinesEnabled = true
        chart.xAxis.labelTextColor = UIColor(hexString: "E1E1E1")
        chart.xAxis.labelFont = .systemFont(ofSize: 8, weight: .semibold)
        
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.granularity = 1
        chart.leftAxis.labelTextColor = UIColor(hexString: "E1E1E1")
        chart.leftAxis.drawLabelsEnabled = true
        chart.rightAxis.enabled = false
        
    }
    
    //MARK:- Update ChartView
    func updateChartView() {
        let games = filterGames()
        if(games.isEmpty) {
            chart.data = nil
        } else {
            chart.highlightValues(nil)
            chart.zoomToCenter(scaleX: 0, scaleY: 0)
            setAxisLabels(games: games)
            setChartData(games: games)
        }
    }
    
    //MARK:- Add Random Games Manually
    func addGamesRandomly(numberOfGames count: Int, games: [TeamGameStats]) -> [TeamGameStats] {
        if(count == 0) {
            return games
        }
        
        var result : [TeamGameStats] = []
        
        for game in games {
            result.append(game.copy() as! TeamGameStats)
        }
        
        result.sort(by: {
            return $0.date.compare($1.date) == .orderedAscending
        })
        for _ in 0..<count {
            let lastDate = result.last!.date
            let index = Int.random(in: 0..<games.count)
            let gameToAdd = games[index].copy()
            result.append(gameToAdd as! TeamGameStats)
            result.last!.date = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!
        }
        return result
    }
    
    //MARK: - Filters Functions
    func filterGames() -> [TeamGameStats] {
        var result = gamesToFilter

        result.sort(by: {
            return $0.date.compare($1.date) == .orderedAscending
        })
        
        result = filterPeriod(games: result)
        result = filterOpponents(games: result)
        
        return result
    }
    
    func filterPeriod(games: [TeamGameStats]) -> [TeamGameStats] {
        switch period {
        case 1:
            return Array(games.suffix(5))
        case 2:
            return Array(games.suffix(10))
        case 3:
            return Array(games.suffix(20))
        default:
            return games
        }
    }
    
    func filterOpponents(games: [TeamGameStats]) -> [TeamGameStats] {
        if(allOpponentsSelected) {
            return games
        } else {
            var result : [TeamGameStats] = []
            for game in games {
                for opponent in opponentsSelected {
                    if game.opponentAbb == opponent {
                        result.append(game)
                    }
                }
            }
            return result
        }
    }
    
    //MARK:- Update Dataset Methods
    func setChartData(games: [TeamGameStats]) {
        var combinedData : CombinedChartData? = nil
        if(stat == 1) {
            var teamEntries : [ChartDataEntry] = []
            var opponentEntries : [ChartDataEntry] = []
            
            let teamData = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "teamPTS" : games[0].PTS,
                "opponentPTS" : games[0].opponentPTS,
            ] as [String : Any]
            
            teamEntries.append(ChartDataEntry(x: Double(0), y: Double(games[0].PTS), data: teamData as AnyObject))
            opponentEntries.append(ChartDataEntry(x: Double(0), y: Double(games[0].opponentPTS), data: teamData as AnyObject))
            
            for i in 0..<games.count {
                let teamData = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "teamPTS" : games[i].PTS,
                    "opponentPTS" : games[i].opponentPTS,
                    ] as [String : Any]
                teamEntries.append(ChartDataEntry(x: Double(i), y: Double(games[i].PTS), data: teamData as AnyObject))
                let opponentData = [
                    "team" : games[i].opponentAbb,
                    "opponent" : team!.teamID,
                    "home" : !games[i].home,
                    "win" : !(games[i].PTS > games[i].opponentPTS),
                    "teamPTS" : games[i].opponentPTS,
                    "opponentPTS" : games[i].PTS,
                    ] as [String : Any]
                opponentEntries.append(ChartDataEntry(x: Double(i), y: Double(games[i].opponentPTS), data: opponentData as AnyObject))
            }
            
            let teamDataset = LineChartDataSet(entries: teamEntries, label: "PTS Scored")
            lineDatasetOptions(dataset: teamDataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            teamDataset.mode = .horizontalBezier
            
            let opponentDataset = LineChartDataSet(entries: opponentEntries, label: "PTS Allowed")
            lineDatasetOptions(dataset: opponentDataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: false)
            opponentDataset.lineDashLengths = [2, 6]
            opponentDataset.formLineDashLengths = [2, 3]
            
            let lineData = LineChartData(dataSets: [teamDataset, opponentDataset])
            
            combinedData = CombinedChartData(dataSets: [teamDataset, opponentDataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 2) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "FG%: \(Double(games[0].avgFGP*100))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avgFGP*100), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "FG%: \(Double(games[i].avgFGP*100))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].avgFGP*100), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Field Goals %")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)

            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 3) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "3FG%: \(Double(games[0].avg3FGP*100))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avg3FGP*100), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "3FG%: \(Double(games[i].avg3FGP*100))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].avg3FGP*100), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "3PTS Field Goals %")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 4) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "2FG%: \(Double(games[0].avg2FGP*100))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avg2FGP*100), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "2FG%: \(Double(games[i].avg2FGP*100))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].avg2FGP*100), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "2PTS Field Goals %")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 5) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "FT%: \(Double(games[0].avgFTP*100))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].avgFTP*100), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "FT%: \(Double(games[i].avgFGP*100))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].avgFTP*100), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Free Throws %")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 6) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "AST: \((games[0].AST))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].AST), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "AST: \((games[i].AST))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].AST), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Assists")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 7) {
            var rebEntries : [ChartDataEntry] = []
            var orbEntries : [ChartDataEntry] = []
            var drbEntries : [ChartDataEntry] = []
            
            var teamData = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat1" : "REB: \((games[0].REB))",
                "stat2" : "DRB: \((games[0].DRB))",
                "stat3" : "ORB: \((games[0].ORB))"
            ] as [String : Any]
            
            rebEntries.append(ChartDataEntry(x: Double(0), y: Double(games[0].REB), data: teamData as AnyObject))
            orbEntries.append(ChartDataEntry(x: Double(0), y: Double(games[0].ORB), data: teamData as AnyObject))
            drbEntries.append(ChartDataEntry(x: Double(0), y: Double(games[0].DRB), data: teamData as AnyObject))

            for i in 0..<games.count {
                teamData = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat1" : "REB: \((games[i].REB))",
                    "stat2" : "DRB: \((games[i].DRB))",
                    "stat3" : "ORB: \((games[i].ORB))"
                    ] as [String : Any]
                
                rebEntries.append(ChartDataEntry(x: Double(i), y: Double(games[i].REB), data: teamData as AnyObject))
                orbEntries.append(ChartDataEntry(x: Double(i), y: Double(games[i].ORB), data: teamData as AnyObject))
                drbEntries.append(ChartDataEntry(x: Double(i), y: Double(games[i].DRB), data: teamData as AnyObject))
            }
            
            let rebDataset = LineChartDataSet(entries: rebEntries, label: "Total REB")
            lineDatasetOptions(dataset: rebDataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let drbDataset = LineChartDataSet(entries: drbEntries, label: "Defensive REB")
            lineDatasetOptions(dataset: drbDataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: false)
            
            let orbDataset = LineChartDataSet(entries: orbEntries, label: "Offensive REB")
            lineDatasetOptions(dataset: orbDataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: false)
            orbDataset.lineDashLengths = [2, 6]
            orbDataset.formLineDashLengths = [2, 3]
            
            let lineData = LineChartData(dataSets: [rebDataset, drbDataset, orbDataset])
            
            combinedData = CombinedChartData(dataSets: [rebDataset, drbDataset, orbDataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 8) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "STL: \((games[0].STL))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].STL), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "STL: \((games[i].STL))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].STL), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Steals")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 9) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "TO: \((games[0].TO))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].TO), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "TO: \((games[i].TO))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].TO), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Turnovers")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        else if(stat == 10) {
            var entries : [ChartDataEntry] = []
            
            var data = [
                "team" : team!.teamID,
                "opponent" : games[0].opponentAbb,
                "home" : games[0].home,
                "win" : games[0].PTS > games[0].opponentPTS,
                "stat" : "BLK: \((games[0].BLK))",
                ] as [String : Any]
            
            entries.append(ChartDataEntry(x: Double(0), y: Double(games[0].BLK), data: data as AnyObject))
            for i in 0..<games.count {
                data = [
                    "team" : team!.teamID,
                    "opponent" : games[i].opponentAbb,
                    "home" : games[i].home,
                    "win" : games[i].PTS > games[i].opponentPTS,
                    "stat" : "BLK: \((games[i].BLK))",
                    ] as [String : Any]
                entries.append(ChartDataEntry(x: Double(i), y: Double(games[i].BLK), data: data as AnyObject))
            }
            
            let dataset = LineChartDataSet(entries: entries, label: "Blocks")
            lineDatasetOptions(dataset: dataset, colorsHEX: [team!.primaryColor, team!.secondaryColor], teamColor: true)
            
            let lineData = LineChartData(dataSet: dataset)
            
            combinedData = CombinedChartData(dataSets: [dataset])
            combinedData!.lineData = lineData
        }
        chart.data = combinedData
        if(stat == 2 || stat == 3 || stat == 4 || stat == 5) {
            chart.data!.setValueFormatter(DefaultValueFormatter(decimals: 1))
        } else {
            chart.data!.setValueFormatter(DefaultValueFormatter(decimals: 0))
        }
        combinedData!.setDrawValues(false)
        chart.notifyDataSetChanged()
    }
    
    func lineDatasetOptions(dataset: LineChartDataSet, colorsHEX: [String], teamColor: Bool) {
        let color1 = UIColor(hexString: colorsHEX[0])!
        let color2 = UIColor(hexString: colorsHEX[1])!
        let color3 = UIColor(hexString: "FFFFFF")!
        
        dataset.lineWidth = 1.5
        dataset.setColor(teamColor ? color1 : color3.withAlphaComponent(0.3))
        
        dataset.circleRadius = period > 2 ? 3.0 : 4.0
        dataset.circleHoleRadius = dataset.circleRadius/2
        dataset.setCircleColor(UIColor.flatWhite()!.withAlphaComponent(0.5))
        dataset.circleHoleColor = color2.withAlphaComponent(0.7)
        
        dataset.valueTextColor = UIColor.flatWhiteColorDark()
        dataset.valueFont = .systemFont(ofSize: 10, weight: .semibold)
        
        dataset.drawHorizontalHighlightIndicatorEnabled = false
        dataset.drawVerticalHighlightIndicatorEnabled = true
        dataset.highlightColor = UIColor(hexString: "2B2B2B")
        dataset.highlightLineWidth = 2
    }
    
    func setAxisLabels(games: [TeamGameStats]) {
        var xAxisLabels : [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        
        for item in games {
            let home = item.home ? "vs " : "at "
            xAxisLabels.append(home + item.opponentAbb + "\n" + dateFormatter.string(from: item.date))
        }
        
        chart.xAxis.spaceMin = Double(games.count)/14.0
        chart.xAxis.spaceMax = Double(games.count)/11.0
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values:xAxisLabels)
    }
}

//MARK: - ChartView Delegate
extension TeamChartManager : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {        
        var marker : MarkerView
        
        switch stat {
        case 1:
            marker = LineMarkerView1.viewFromXib()!
        case 7:
            marker = LineMarkerView3.viewFromXib()!
        default:
            marker = LineMarkerView2.viewFromXib()!
        }
        marker.chartView = chart
        chart.marker = marker
    }
}
