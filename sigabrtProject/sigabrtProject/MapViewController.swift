
import UIKit
import MapKit
import Firebase
import Nuke
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate, ModernSearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var personalMap: MKMapView!
    
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    
    @IBOutlet weak var imgShop: UIImageView!
    
    var locManager = CLLocationManager()
    var floatSpan1: Float = 1
    var floatSpan2: Float = 1
    
    let regionRadius: CLLocationDistance = 20000
    var pins: [MKPointAnnotation: Shop] = [:]
    var TempID: Int = 0
    var barbers: [Shop] = []
    var currentBarber : Shop?
    var bottomSheetVC: bottomScrollable!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        addBottomSheetView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //let myPosition = CLLocationCoordinate2D(latitude: Double("41.9102399")!, longitude: Double("12.2551245")!)
        /*personalMap.setRegion(MKCoordinateRegionMakeWithDistance(myPosition, regionRadius, regionRadius), animated: true)*/
        self.hideKeyboardWhenTappedAround()
        UserDefaults.standard.set(true, forKey: "disableWizard")
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        locManager.distanceFilter = 4000
        drawMap()
        self.modernSearchBar.delegateModernSearchBar = self
        self.addBottomSheetView()

    }
    
    @IBAction func loginButton(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
            return
        }
        
        let controller = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "userReservation") as? UserReservationViewController
        self.addChildViewController(controller!)
     
        Funcs.animateIn(sender: (controller?.loginView)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(CLLocationDegrees(floatSpan1),CLLocationDegrees(floatSpan2))
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        personalMap.setRegion(region, animated: true)
        self.personalMap.showsUserLocation = true
    }
    public func zoomMap(){
        self.floatSpan1 = 0.5
        self.floatSpan2 = 0.5
    }
    
    func drawMap(){
        var ref: DatabaseReference!
        
        ref = Database.database().reference().child("barbers")
        
        
        ref.observe(.childAdded, with: { snapshot in

            if let snapshotValue = snapshot.value as? [String:Any] {
                var barberServices:[Service] = []

                let barberName = snapshotValue["name"] as? String ?? "NoName"
                let barberDesc = snapshotValue["description"] as? String ?? "NoDesc"
                let barberLat = snapshotValue["latitude"] as? Double ?? 14.04
                let barberLon = snapshotValue["longitude"] as? Double ?? 44.03
                let ID = Int(snapshot.key)!
                let barberPhone = snapshotValue["phone"] as? String ?? "NoPhone"
                let barberAddress = (snapshotValue["address"])! as? String ?? "NoAddress"
                if let child = snapshot.childSnapshot(forPath: "services").value as? [String:Any] {
                    for c in child{
                        if let smallChild = snapshot.childSnapshot(forPath: "services/\(c.key)").value as? [String:Any]  {
                                    let id = c.key
                                    let serviceName = smallChild["name"] as? String ?? "NoName"
                                    let serviceDuration = smallChild["duration"] as? Int ?? 0
                                    let servicePrice = smallChild["price"] as? Int ?? 0
                                    let service = Service(name: serviceName, duration: serviceDuration, price: servicePrice, id: id)
                                    barberServices.append(service)
                                
                            }
                        }
                    }
                
                var hours : [String:[[Int]]] = [:]
                if let child = snapshot.childSnapshot(forPath: "hours").value as? [String:Any]  {
    
                    for c in child{
                     hours[c.key] = []
                        if let smallChild = snapshot.childSnapshot(forPath: "hours/\(c.key)").value as? NSArray  {
                            for smallC in smallChild{
                                if let tempTime = smallC as? [String:Any]{
                                    
                                    let open = tempTime["open"] as? Int ?? 0
                                    let close = tempTime["close"] as? Int ?? 0
                                    
                                    hours[c.key]?.append([open,close])
                                    
                                }
                            }
                        }
                    }
                }
                
                let tempPin : MKPointAnnotation = MKPointAnnotation()
                
                tempPin.title = barberName
                tempPin.subtitle = barberDesc
                tempPin.coordinate = CLLocationCoordinate2D(latitude: Double(barberLat), longitude: Double(barberLon))
                print(barberName)
                let imageURL = Storage.storage().reference(forURL: "gs://sigabrt-iosda.appspot.com/").child("barbers/\(ID).png")
                
                imageURL.downloadURL(completion: { (url, error) in
                    self.pins[tempPin] = Shop(ID: ID, name: barberName, desc: barberDesc, coordinate: tempPin.coordinate, phone: barberPhone, address: barberAddress, services: barberServices, logo: url, hours: hours)
                    self.barbers.append( self.pins[tempPin]!)
                    
                    self.bottomSheetVC.pins = self.pins
                    self.bottomSheetVC.barbersShop = self.barbers
                    self.bottomSheetVC.tableView.reloadData()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: self)

                    self.personalMap.addAnnotation(tempPin)
                    self.initializeSearchBar()
                    
                })
                
            }
            self.initializeSearchBar()
            
        })
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sigabrt")
        let tempAnnotation = annotation as? MKPointAnnotation
        
        let shop = self.pins[tempAnnotation!]
        let barberLogo : UIImageView = UIImageView(image: #imageLiteral(resourceName: "pin"))
        
        
        pin.pinTintColor = UIColor(red: 51/255, green: 107/255, blue: 135/255, alpha: 1)

        pin.canShowCallout = true
        pin.animatesDrop = true
        
        
        if shop?.logo != nil { Nuke.loadImage(with: (shop?.logo)!, into: barberLogo) }
        
        pin.leftCalloutAccessoryView = barberLogo
        
        
        let button = UIButton(type: .detailDisclosure) as UIButton // button with info sign
        pin.rightCalloutAccessoryView = button
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let tempAnnotation = view.annotation as? MKPointAnnotation
        let shop = self.pins[tempAnnotation!]
        if control == view.rightCalloutAccessoryView{
            self.currentBarber = shop
            performSegue(withIdentifier: "barberDetail", sender: nil)
            
        }
    }
    
    func onClickItemWithUrlSuggestionsView(item: ModernSearchBarModel) {
        //per il click
        print("User touched this item: "+item.title+" with this url: "+item.url.description)
        let selectedPin = findKeyForValue(value: item.url.description, shops: self.pins)!
        self.personalMap.selectAnnotation(selectedPin, animated: true)
    }
    
    func findKeyForValue(value: String, shops: [MKPointAnnotation: Shop]) ->MKPointAnnotation?
    {
        for (key, shop) in shops
        {
            if (shop.logo?.absoluteString.contains(value))!
            {
                return key
            }
        }
        
        return nil
    }
    
    func initializeSearchBar(){
        var barberList = Array<ModernSearchBarModel>()
        let defautlIcon : URL = URL(string: "https://cdn2.iconfinder.com/data/icons/gnomeicontheme/32x32/actions/edit-cut.png")!
        for barber in self.pins.values {
            let barberIcon = barber.logo ?? defautlIcon
            barberList.append(ModernSearchBarModel(title: barber.name, url: barberIcon))
        }
        
        self.modernSearchBar.setDatasWithUrl(datas: barberList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondVC = segue.destination as? ShopDetailViewController{
            secondVC.barber = self.currentBarber
        }
    
    }
    
    @IBAction func merchantButton(_ sender: Any) {
        let errorAlert = UIAlertController(title: "Merchant registration", message: "If you are a merchant and want your shop to be bookable in this app contact us at info@sigabrt.lol", preferredStyle: .actionSheet)
        
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(errorAlert, animated: true, completion:  nil)
    }
    
    func addBottomSheetView() {
        
        bottomSheetVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bottomScrollable") as! bottomScrollable
        
        self.addChildViewController(bottomSheetVC)
        
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        bottomSheetVC.personalMap = self.personalMap
        //qui vanno passati gli shop
        //come bottomSheetVC.variabileArrayDellaScrollableView = array

        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0,y: self.view.frame.maxY,width: width,height: height)
    }
}
