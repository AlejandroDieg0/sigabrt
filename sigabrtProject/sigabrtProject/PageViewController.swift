import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource , UIPageViewControllerDelegate {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all //return the value as per the required orientation
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    lazy var WIZarray: [UIViewController] = {
        return [self.VCinstance(name: "FirstViewController"),
                self.VCinstance(name: "SecondViewController"),
                self.VCinstance(name: "ThirdViewController")]
    }()
    
    private func VCinstance(name: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstViewController = WIZarray.first{
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = WIZarray.index(of: viewController) else{
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        //quando si trova al numero 0 non andare indietro
        guard previousIndex >= 0 else {
            return nil
        }
        
        // se l'array cambia
        guard WIZarray.count > previousIndex else {
            return nil
        }
        
        return WIZarray[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = WIZarray.index(of: viewController) else{
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < WIZarray.count else {
            return nil
        }
        
        // se l'array cambia
        guard WIZarray.count > nextIndex else {
            return nil
        }
        
        return WIZarray[nextIndex]
    }
    
//    
////    EDIT: Sostituito con page control sulla storyboard top
//    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return WIZarray.count
//    }
//    
//    
//    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = WIZarray.index(of: firstViewController) else {
//            return 0
//        }
//        return firstViewControllerIndex
//    }
//    
////    some magic to make UIPageControl transparent
//    override func viewDidLayoutSubviews() {
//        for subView in self.view.subviews {
//            if subView is UIScrollView {
//                subView.frame = self.view.bounds
//            } else if subView is UIPageControl {
//                self.view.bringSubview(toFront: subView)
//            }
//        }
//        super.viewDidLayoutSubviews()
//    }
//    
}
