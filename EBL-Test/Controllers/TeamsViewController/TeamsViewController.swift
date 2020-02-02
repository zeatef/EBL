//
//  TeamsViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/23/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Segmentio
import NVActivityIndicatorView
import Firebase
import ChameleonFramework

class TeamsViewController : UIViewController {
    
    //MARK:- Instance Variables
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var tabbedMenuBar : Segmentio!
    let tabbedMenuBarContent : [SegmentioItem] = [SegmentioItem(title: "Overview", image: nil), SegmentioItem(title: "Game Statistics", image: nil), SegmentioItem(title: "Players", image: nil)]
    
    @IBOutlet weak var teamOverview: UIView!
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var currentRanking: UILabel!
    @IBOutlet weak var seasonRecord: UILabel!
    @IBOutlet weak var headCoach: UILabel!
    @IBOutlet weak var hometown: UILabel!
    @IBOutlet weak var bottomBorder: UIView!
    @IBOutlet weak var pageContent: UIView!

    let dbManager = DatabaseManager.sharedInstance
    var currentSubview = 0
    var team : Team?
    
    //Initialize First View (Team Overview)
    lazy var teamOverviewVC : TeamOverviewViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "TeamOverviewViewController") as! TeamOverviewViewController
        
        viewController.parentVC = self
        
        self.addViewControllerAsChildViewController(childViewController: viewController)
        
        return viewController
    }()
    
    //Initialize Second View (Team Stats)
    lazy var teamStatsVC : TeamStatsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "TeamStatsViewController") as! TeamStatsViewController
        
        viewController.parentVC = self

        self.addViewControllerAsChildViewController(childViewController: viewController)
        
        return viewController
    }()
    
    //Initialize Third View (Players Overview)
    lazy var playersOverviewVC : PlayersOverviewViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "PlayersOverviewViewController") as! PlayersOverviewViewController
        
        self.addViewControllerAsChildViewController(childViewController: viewController)
        
        return viewController
    }()
    
//    //Initialize Fourth View (Team Graphs)
//    lazy var teamGraphsVC : TeamGraphsViewController = {
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//        var viewController = storyboard.instantiateViewController(withIdentifier: "TeamGraphsViewController") as! TeamGraphsViewController
//
//        self.addViewControllerAsChildViewController(childViewController: viewController)
//
//        return viewController
//    }()
//
//    //Initialize Fifth View (Players Graphs)
//    lazy var playersGraphsVC : PlayersGraphsViewController = {
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//        var viewController = storyboard.instantiateViewController(withIdentifier: "PlayersGraphsViewController") as! PlayersGraphsViewController
//
//        self.addViewControllerAsChildViewController(childViewController: viewController)
//
//        return viewController
//    }()
    
    //MARK:- Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup PageContent View
        setupHeader()
        setupView()
    }

    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //MARK: - Setup View Controller Functions
    func setupTeamInfo(source: FirestoreSource, completion: @escaping (Error?) -> Void) {
        dbManager.getTeamStats(forTeam: self.team!, source: source) { (error) in
            if let error = error {
                completion(error)
            } else {
                self.dbManager.getAllPlayers(forTeam: self.team!.abb, source: source) { (players, error) in
                    if let error = error {
                        completion(error)
                    } else {
                        self.team!.allPlayers = players!
                        self.team!.setTop3Performers()
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func setupHeader() {
        let primaryColor = UIColor(hexString: team!.primaryColor)
        
        //Setup Navigation Bar
        title = team!.teamName
        navigationController?.navigationBar.tintColor = primaryColor
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Setup Tabbed Menu Bar
        setupTabbedMenuBar(indicatorColor: UIColor(hexString: team!.primaryColor))
    }
    
    private func setupView() {
        //Setup Loading View
        pageContent.isSkeletonable = true
        loadingView.color = UIColor.flatWhiteColorDark()
        loadingView.type = NVActivityIndicatorType.ballScale
        
        //Setup First Child View
        view.bringSubviewToFront(teamOverviewVC.view)
    }
    
    //MARK: - Tabbed Menu Bar Functions
    func setupTabbedMenuBar(indicatorColor: UIColor = UIColor.flatOrange()){
        tabbedMenuBar.setup(content: tabbedMenuBarContent, style: .onlyLabel, options: SegmentioOptions(
            backgroundColor: tabbedMenuBar.backgroundColor!,
            segmentPosition: SegmentioPosition.fixed(maxVisibleItems: 3),
            scrollEnabled: true,
            indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 0.9,
                height: 3,
                color: indicatorColor
            ),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
                type: SegmentioHorizontalSeparatorType.none
            ),
            verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(
                ratio: 0.4,
                color: UIColor(hexString: "E1E1E1", withAlpha: 0.5)
            ),
            labelTextAlignment: .center,
            segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont.systemFont(ofSize: 11.0, weight: .semibold),
                    titleTextColor: UIColor.white
                ),
                selectedState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont.systemFont(ofSize: 11.0, weight: .semibold),
                    titleTextColor: UIColor.white
                ),
                highlightedState: SegmentioState(
                    backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                    titleFont: UIFont.systemFont(ofSize: 11.0, weight: .semibold),
                    titleTextColor: .black
                )
            )
        ))
        tabbedMenuBar.isHidden = false
        tabbedMenuBar.selectedSegmentioIndex = 0
        tabbedMenuBar.valueDidChange = { segmentio, segmentIndex in
            self.updateView(tag: segmentIndex)
        }
    }
    
    func updateView(tag: Int) {
        switch tag {
        case 0:
            removeCurrentSubview()
            currentSubview = tag
            teamOverviewVC.view.isHidden = false
        case 1:
            removeCurrentSubview()
            currentSubview = tag
            teamStatsVC.view.isHidden = false
        case 2:
            removeCurrentSubview()
            currentSubview = tag
            playersOverviewVC.view.isHidden = false
//        case 3:
//            removeCurrentSubview()
//            currentSubview = tag
//            teamGraphsVC.view.isHidden = false
//        case 4:
//            removeCurrentSubview()
//            currentSubview = tag
//            playersGraphsVC.view.isHidden = false
        default:
            print("")
        }
    }
    
    private func removeCurrentSubview() {
        switch currentSubview {
        case 0:
            teamOverviewVC.view.isHidden = true
        case 1:
            teamStatsVC.view.isHidden = true
        case 2:
            playersOverviewVC.view.isHidden = true
//        case 3:
//            teamGraphsVC.view.isHidden = true
//        case 4:
//            playersGraphsVC.view.isHidden = true
        default:
            print("")
        }
    }
    
    //MARK: - Helper Methods
    func addViewControllerAsChildViewController(childViewController: UIViewController){
        addChild(childViewController)
        pageContent.addSubview(childViewController.view)
        
        childViewController.view.frame = pageContent.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childViewController.didMove(toParent: self)
    }
}
