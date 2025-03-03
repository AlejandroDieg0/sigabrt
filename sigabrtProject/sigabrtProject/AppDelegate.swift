import UIKit
import Firebase
import FacebookCore
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Controllo termini accettati
        let disableWizard = UserDefaults.standard.bool(forKey: "disableWizard")
        if(disableWizard)
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapView")
            self.window?.rootViewController = vc
        }
        else
        {
            UserDefaults.standard.synchronize()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "wizardView")
            self.window?.rootViewController = vc
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                Funcs.loadUserData(){loadedUser in
                    print(loadedUser.userType)
                    
                    if (loadedUser.userType == 1) {
                        let vc = UIStoryboard(name: "Barber", bundle: nil).instantiateViewController(withIdentifier: "barberView")
                        self.window?.rootViewController = vc
                    } else if(loadedUser.userType == 0 && loadedUser.favBarberId != -1) {
                        if let a = self.window?.rootViewController as? UINavigationController{
                            if (a.visibleViewController as? UserReservationViewController) == nil{
                                let vc = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "userReservationNavigation")
                                self.window?.rootViewController = vc
                            }
                        }
                   }
                }
            } else if (disableWizard){
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapView")
                self.window?.rootViewController = vc
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.barTintColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        let toolbarAppereance = UIToolbar.appearance()
        toolbarAppereance.tintColor = UIColor.white
        toolbarAppereance.barTintColor = UIColor(red: 144/255, green: 175/255, blue: 197/255, alpha: 1)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
}

