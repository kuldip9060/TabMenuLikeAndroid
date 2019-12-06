//
//  RootViewController.swift
//  demopageapp
//
//  Created by Kuldip Bhalodiya on 06/12/19.
//  Copyright © 2019 TechHolding. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var aryMain = [[String:Any]]()
    var pageViewController: UIPageViewController?
    
    @IBOutlet weak var colRootView: UICollectionView!
    
    var currIndex = 0 {
        didSet{
            self.colRootView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let startingViewController: DataViewController = //self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let vc1Controller = self.storyboard?.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        let vc2Controller: VC2 = self.storyboard?.instantiateViewController(withIdentifier: "VC2") as! VC2
        let vc3Controller: VC3 = self.storyboard?.instantiateViewController(withIdentifier: "VC3") as! VC3
        
        
        self.aryMain = [
            ["title": "VC1", "vc": vc1Controller],
            ["title": "VC2", "vc": vc2Controller],
            ["title": "VC3", "vc": vc3Controller],
        ]
        
        // Do any additional setup after loading the view.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self

        
        let viewControllers = [vc1Controller]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChild(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let frame = CGRect.init(x: 0, y: 150, width: self.view.bounds.width, height: self.view.bounds.height)
        var pageViewRect = frame
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect

        self.pageViewController!.didMove(toParent: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewController.SpineLocation.mid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (!completed)
        {
            return
        }
        let index = pageViewController.viewControllers!.first!.view.tag //Page Index
        let indexPath = IndexPath(item: index, section: 0)
        
        //scroll to index page
        self.colRootView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currIndex = indexPath.item
    }

}

extension RootViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.aryMain.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderColCell", for: indexPath) as! HeaderColCell
        cell.lblTitle.text = (self.aryMain[indexPath.item]["title"] as! String)
        cell.lblTitle.textColor = indexPath.item == self.currIndex ? .red : .black
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.colRootView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currIndex = indexPath.item
        let vc = self.aryMain[indexPath.item]["vc"] as! UIViewController
        self.pageViewController!.setViewControllers([vc], direction: .forward, animated: false, completion: {done in })
        self.colRootView.reloadData()
    }
    
}

class HeaderColCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
}
