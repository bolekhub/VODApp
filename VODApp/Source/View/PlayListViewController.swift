//
//  PlayListViewController.swift
//  VODApp
//
//  Created by Boris Chirino on 24/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import ISHPullUp


protocol PlayListViewControllerEvents: class {
    func didSelectVideo(video: Video)
}

class PlayListViewController: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PlayListViewModelEvents {
    
    func didUpdate() {
        self.collectionView.reloadData()
    }
    weak var videoPlayerView: VersaPlayerView?
    
    @IBOutlet weak var seekbarSlider: VersaSeekbarSlider!
    @IBOutlet weak var titleLabel: UILabel!
    private var viewModel: PlayListViewModel!
    private var halfWayPoint = CGFloat(0)
    private var firstAppearanceCompleted = false
    
    weak var eventsDelegate: PlayListViewControllerEvents?
    weak var pullUpController: ISHPullUpViewController!
    @IBOutlet weak var collectionView: UICollectionView!

    //needed for ISHPullUp component
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var handleView: ISHPullUpHandleView!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let dataStore = VideoDataStore(usingDAO: CoreDataDAO())
        viewModel = PlayListViewModel(dataStore: dataStore)
        viewModel.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topView.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: UIApplication.didBecomeActiveNotification, object: nil)
        
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true;
        self.topView.addSubview(videoPlayerView!.controls!)
        //self.collectionView.addSubview(time!)
        //self.seekbarSlider = videoPlayerView?.controls?.seekbarSlider
    }
    
    //MARK: - UI actions
    @objc
    private func handleTapGesture(gesture: UITapGestureRecognizer) {
        if pullUpController.isLocked {
            return
        }
        pullUpController.toggleState(animated: true)
    }
    
    @objc
    private func refreshData(){
        self.viewModel.fetchData()
    }
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifiers.videoList.cell.rawValue, for: indexPath) as! VideoCell
        viewModel.configureCell(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        eventsDelegate?.didSelectVideo(video: self.viewModel.items[indexPath.row])
        pullUpController.toggleState(animated: true)
    }
}

//MARK: - ISHPullUpSizingDelegate, ISHPullUpStateDelegate
 extension PlayListViewController {
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        return topView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 50;
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        let totalHeight = rootView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here
        // and perform the snapping in ..targetHeightForBottomViewController..
        halfWayPoint = totalHeight / 2.0
        return maximumAvailableHeight - 50.0
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        if abs(height - halfWayPoint) < 30 {
            return halfWayPoint
        }
        
        // default behaviour
        return height
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController contentVC: UIViewController) {
        // we update the scroll view's content inset
        // to properly support scrolling in the intermediate states
        //scrollView.contentInset = edgeInsets;
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        if let emptyText = videoPlayerView?.controls?.videoTitle?.text?.isEmpty  {
            
            if emptyText {
               handleView.setState(ISHPullUpHandleView.handleState(for: state), animated: firstAppearanceCompleted)
            } else {
                handleView.isHidden = true
            }
            
        }

        /*
        // Hide the scrollview in the collapsed state to avoid collision
        // with the soft home button on iPhone X
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.scrollView.alpha = (state == .collapsed) ? 0 : 1;
        }
         */
    }
    
}



