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
    
    
    @IBOutlet weak var chartView: CombinedChartView!
    
    //MARK: - Instance Variables
    let dbManager = DatabaseManager.sharedInstance
    var team : TeamDisplayData?

    var opponents : [String] = []
    var chartManager : TeamChartManager?
    
    
    //MARK: - ViewDidLoad & RegisterXibFiles
    override func viewDidLoad() {
        super.viewDidLoad()
        registerXibFiles()
        initializeViewController()
        setupOpponentsCollectionView()
        setupStatButtons()
        setupPeriodButtons()
        getAllTeamGames { (error) in
            if let error = error {
                print(error)
            } else {
                
            }
        }
    }
    
    func registerXibFiles(){
        opponentCollectionView.register(UINib(nibName: "OpponentPickerCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "OpponentPickerCell")
    }
    
    func initializeViewController() {
        team = (parent as! TeamsViewController).team!
        chartManager = TeamChartManager(chartView: self.chartView, team: self.team!)
        setupOpponents()
    }
    
    //MARK: - Setup Instance Variables
    func setupOpponents() {
        opponents = dbManager.teamsDisplayData.map { $0.teamID }
        opponents.removeAll(where: {$0 == team!.teamID})
        opponents.insert("League", at: 0)
        opponents.append("League")
        opponents.append("League")
    }
    
    func getAllTeamGames(completion: @escaping  (Error?) -> Void) {
        dbManager.getTeamGameStats(forTeamRef: (parent as! TeamsViewController).team!.teamRef) { (error, hasData, games) in
            if let error = error {
                print(error)
                completion(error)
            } else {
                if hasData! {
                    self.chartManager!.allGames = games!
                }
                completion(nil)
            }
        }
    }
    
    //MARK: - Setup OpponentCollectionView
    func setupOpponentsCollectionView() {
        opponentCollectionView.allowsMultipleSelection = true
        opponentCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
        collectionViewHeightConstraint.constant = ((view.frame.width - 30)/8) * 2
        view.updateConstraints()
    }
    
    //MARK: - Setup StatsSelectedView
    func setupStatButtons() {
        let button = statButtonsView.viewWithTag(1) as! ButtonWithBorder
        button.selectButton()
    }
    
    @IBAction func statButtonPressed(_ sender: ButtonWithBorder) {
        if(chartManager!.stat != sender.tag) {
            let button = statButtonsView.viewWithTag(chartManager!.stat) as! ButtonWithBorder
            button.deselectButton()
            chartManager!.stat = sender.tag
            sender.selectButton()
            chartManager!.updateChartView()
        }
    }
    
    //MARK: - Setup PeriodSelectedView
    func setupPeriodButtons() {
        let button = periodButtonsView.viewWithTag(1) as! ButtonWithBorder
        button.selectButton()
    }
    
    @IBAction func periodButtonPressed(_ sender: ButtonWithBorder) {
        if(chartManager!.period != sender.tag) {
            let button = periodButtonsView.viewWithTag(chartManager!.period) as! ButtonWithBorder
            button.deselectButton()
            chartManager!.period = sender.tag
            sender.selectButton()
            chartManager!.updateChartView()
        }
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
        cell.imageView.kf.setImage(with: dbManager.getTeamImageURL(teamID: opponents[index]))
        
        if(!cell.isSelected) {
            cell.imageView.alpha = 0.2
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let i = indexPath.row + (indexPath.section * 8)
        if(indexPath.section == 0 && indexPath.row == 0) {
            toggleCell(at: indexPath)
            chartManager!.allOpponentsSelected = true
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
            if(chartManager!.allOpponentsSelected) {
                chartManager!.allOpponentsSelected = false
                chartManager!.opponentsSelected.append(opponents[i])
            } else {
                chartManager!.opponentsSelected.append(opponents[i])
            }
            if(collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!.isSelected) {
                collectionView.deselectItem(at: IndexPath(row: 0, section: 0), animated: true)
                toggleCell(at: IndexPath(row: 0, section: 0))
            }
        }
        chartManager!.updateChartView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let i = indexPath.row + (indexPath.section * 8)
        if(indexPath.section == 0 && indexPath.row == 0) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        } else {
            toggleCell(at: indexPath)
            chartManager!.opponentsSelected.removeAll(where: {$0 == opponents[i]})
            if let indexes = collectionView.indexPathsForSelectedItems {
                if(indexes.count == 0) {
                    collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
                    toggleCell(at: IndexPath(row: 0, section: 0))
                    chartManager!.allOpponentsSelected = true
                }
            }
        }
        chartManager!.updateChartView()
    }
    
    func toggleCell(at indexPath: IndexPath) {
        let cell = opponentCollectionView.cellForItem(at: indexPath) as! OpponentPickerCollectionViewCell
        cell.imageView.alpha = cell.imageView.alpha == 1 ? 0.2 : 1
    }
}

extension TeamGraphsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width)/8, height: (collectionView.frame.width)/8)
    }
}
