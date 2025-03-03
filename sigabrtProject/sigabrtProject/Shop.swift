
import UIKit
import MapKit

class Shop: NSObject , MKAnnotation {
   
    var ID: Int = -1
    var name: String = ""
    var services: [Service] = []
    var numBarbers: Int = -1
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var desc: String = ""
    var phone: String = ""
    var address: String = ""
    var logo : URL?
    var hours: [String:[[Int]]]?
    var distance : Int?
    
    init(ID: Int, name : String, desc : String, coordinate: CLLocationCoordinate2D, phone: String, address: String, services: [Service], logo: URL?, hours:  [String:[[Int]]]){
        self.ID = ID
        self.name = name
        self.desc = desc
        self.coordinate = coordinate
        self.phone = phone
        self.address = address
        self.logo = logo
        self.services = services
        self.hours = hours
    }
    
    init(ID: Int, name : String, desc : String, phone: String, address: String, services: [Service], hours: [String:[[Int]]]){
        self.ID = ID
        self.name = name
        self.desc = desc
        self.phone = phone
        self.address = address
        self.services = services
        self.hours = hours
    }
    init(ID: Int, name : String, desc : String, phone: String, address: String, services: [Service], hours: [String:[[Int]]], distance: Int, logo: URL?){
        self.ID = ID
        self.name = name
        self.desc = desc
        self.phone = phone
        self.address = address
        self.services = services
        self.hours = hours
        self.distance = distance
        self.logo = logo


    }

}
