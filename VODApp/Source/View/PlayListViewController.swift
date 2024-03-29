//
//  PlayListViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import ISHPullUp

class PlayListViewController: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, PlayListViewModelEvents,
PlayerSwipeGestureConformable {
    
    /// Reference to videoPlayer from mainView
    weak var videoPlayerView: VersaPlayerView?

    /// viewmodel
    private var viewModel: PlayListViewModel!
    
    /// calculate the middlepoint when draging the view
    private var halfWayPoint = CGFloat(0)
    
    /// indicate when the bottom viewcontroller appear for this time
    private var firstAppearanceCompleted = false

    /// container viewcontroller
    weak var pullUpController: ISHPullUpViewController!
    
    /// play list items
    @IBOutlet weak var collectionView: UICollectionView!

    //needed for ISHPullUp component, its the superview for all components.
    @IBOutlet weak var rootView: UIView!
    
    /// where the video controls are palced
    @IBOutlet weak var topView: UIView!
    
    /// blue line indicating drag direction. Appear just when no video is selected
    @IBOutlet weak var handleView: ISHPullUpHandleView!
    
    //MARK - ViewLifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let dataStore = VideoDataStore(usingDAO: CoreDataDAO.shared)
        viewModel = PlayListViewModel(dataStore: dataStore)
        viewModel.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true;
        self.topView.addSubview(videoPlayerView!.controls!)
        guard videoPlayerView?.gestureDelegate == nil else { return }
        videoPlayerView?.gestureDelegate = self
    }
    
    
    //MARK: - UI actions
    @objc
    private func handleTapGesture(gesture: UITapGestureRecognizer) {
        
        pullUpController.toggleState(animated: true)
    }
    
    @objc
    private func refreshData(){
        self.viewModel.fetchData()
    }
    
    func handleSwipe(direction: UISwipeGestureRecognizer.Direction) {
        
        if let nextVideo = viewModel.nextVideo(inPlayer: self.videoPlayerView!) {
            self.videoPlayerView?.set(item: nextVideo)
            handleView.isHidden = true
        }
    }
    
    //MARK: - PlayListViewModelEvents
    func didUpdate() {
        
        self.collectionView.reloadData()
    }
    
    //MARK: - static methods
    class func fromStoryboard() -> PlayListViewController {
        
        let sb = UIStoryboard(name: Storyboard.nameIdentifier.main.rawValue, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: PlayListViewController.storyboardidentifier())
        return vc as! PlayListViewController
    }
    
    static func storyboardidentifier() -> String {
        
        return String(describing: PlayListViewController.self)
    }
}



//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PlayListViewController {
    
    //UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.videoList.cell.rawValue,
                                                      for: indexPath) as! VideoCell
        viewModel.configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let playerItem = self.viewModel.configurePlayer(self.videoPlayerView!,
                                                        forSelectedIndex: indexPath)
        videoPlayerView?.set(item: playerItem)
        pullUpController.toggleState(animated: true)
    }
}

//MARK: - ISHPullUpSizingDelegate, ISHPullUpStateDelegate
 extension PlayListViewController {
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController
        bottomVC: UIViewController) -> CGFloat {
        
        return topView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 50;
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController,
                              maximumHeightForBottomViewController bottomVC: UIViewController,
                              maximumAvailableHeight: CGFloat) -> CGFloat {
        let totalHeight = rootView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here
        // and perform the snapping in ..targetHeightForBottomViewController..
        halfWayPoint = totalHeight / 2.0
        return maximumAvailableHeight - 50.0
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController,
                              targetHeightForBottomViewController bottomVC: UIViewController,
                              fromCurrentHeight height: CGFloat) -> CGFloat {
        if abs(height - halfWayPoint) < 30 {
            return halfWayPoint
        }
        
        // default behaviour
        return height
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets,
                              forBottomViewController contentVC: UIViewController) {}
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        
        if let emptyText = videoPlayerView?.controls?.videoTitle?.text?.isEmpty  {
            
            if emptyText {
                
               handleView.setState(ISHPullUpHandleView.handleState(for: state), animated: firstAppearanceCompleted)
            } else {
                handleView.isHidden = true
            }
        }
    }
    
}



