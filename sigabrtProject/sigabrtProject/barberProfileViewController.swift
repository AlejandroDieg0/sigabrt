
import UIKit
import Firebase
import FBSDKLoginKit


class barberProfileViewController: UITableViewController {
    
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    
    //INFO LABEL
    @IBOutlet weak var changeMail: UITextField!
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var helloName: UILabel!
    @IBOutlet weak var changePhone: UITextField!
    @IBOutlet weak var logoBarber: UIImageView!
    
    @IBOutlet weak var sendMailPwReset: UIButton!

    //  var myContainerViewDelegate: BarberDetailViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoBarber.layer.cornerRadius = logoBarber.frame.size.width/2
        // let editBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: Selector(("setEditing")))
        navigationItem.rightBarButtonItem = editButtonItem
        
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(barberProfileViewController.editing),
                name: NSNotification.Name(rawValue: "editTableView"),
                object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(barberProfileViewController.doneEditing),
            name: NSNotification.Name(rawValue: "doneTableView"),
            object: nil)
        //GESTURE
        self.hideKeyboardWhenTappedAround()
        
        self.changeName.isUserInteractionEnabled = false
        self.changeMail.isUserInteractionEnabled = false
        self.changePhone.isUserInteractionEnabled = false
        
        
        if(FBSDKAccessToken.current() != nil){
            
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,email, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(String(describing: error))")
                }
                else
                {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(data)
                    let firstName = data["first_name"]
                    
                    self.helloName.text = "Hello \(firstName!)"
                    self.changeName.text = firstName! as? String
                    self.changeMail.text = data["email"] as? String
                    self.sendMailPwReset.setTitle("Connected as \(firstName!)", for: .normal)
                    
                }
            })
            
        }else{
            if Auth.auth().currentUser != nil {
                self.changeName.text = Funcs.loggedUser.name
                self.changePhone.text = Funcs.loggedUser.phone
                self.changeMail.text = Funcs.loggedUser.mail
                self.helloName.text = "Hello \(self.changeName.text!)"
                
            } else {
                print("no logged with Firebase")
                helloName.text = "Hello User!"
            }
        }
        
        
    }
    func reloadData(){
            self.tableView.reloadData()
           }

    func editing(){
        print("sono qui dento")
        self.changePhone.isUserInteractionEnabled = true
        self.changePhone.textColor = UIColor.black
        
        self.changeMail.isUserInteractionEnabled = true
        self.changeMail.textColor = UIColor.black
        
        self.changeName.isUserInteractionEnabled = true
        self.changeName.textColor = UIColor.black
    }
    
    func doneEditing() {
        let ref = Database.database().reference().child("user/\(Auth.auth().currentUser?.uid ?? "noLogin")")
        ref.updateChildValues([
            "name": self.changeName.text!,
            "phone": self.changePhone.text!,
            ])

        self.changePhone.isUserInteractionEnabled = false
        self.changePhone.textColor = UIColor.gray

        self.changeMail.isUserInteractionEnabled = false
        self.changeMail.textColor = UIColor.gray

        self.changeName.isUserInteractionEnabled = false
        self.changeName.textColor = UIColor.gray
        
        print("Changes Uploaded")
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        do {
            try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.navigationController?.popViewController(animated: true)
        return
    }
    
    // Delete profile
    
    @IBAction func deleteProfile(_ sender: UIButton) {
        user?.delete { error in
            if error != nil {
                // An error happened.
            } else {
                // Account deleted.
                self.dismiss(animated: true, completion: nil)
            }
        }
        return
    }
    
    // Send mail for password reset
    
    @IBAction func sendMailPwReset(_ sender: Any) {
        guard let mail = self.changeMail.text, !mail.isEmpty else {
            return
        }
            Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            // ...
        }
        
        return
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if isEditing {
            print(editing)
            self.changePhone.isUserInteractionEnabled = true
            self.changePhone.textColor = UIColor.black
            
            self.changeMail.isUserInteractionEnabled = true
            self.changeMail.textColor = UIColor.black
            
            self.changeName.isUserInteractionEnabled = true
            self.changeName.textColor = UIColor.black
            
            
        } else {
            createAlert()
            let ref = Database.database().reference().child("user/\(Auth.auth().currentUser?.uid ?? "noLogin")")
            ref.updateChildValues([
                "name": self.changeName.text!,
                "phone": self.changePhone.text!,
                ])
            
            self.changePhone.isUserInteractionEnabled = false
            self.changePhone.textColor = UIColor.gray
            
            self.changeMail.isUserInteractionEnabled = false
            self.changeMail.textColor = UIColor.gray
            
            self.changeName.isUserInteractionEnabled = false
            self.changeName.textColor = UIColor.gray
            
            print("Changes Uploaded")
            
        }
    }
    
//    //TABLE VIEW
//     override func numberOfSections(in tableView: UITableView) -> Int {
//        if tableView == self.tableViewService {
//        return 1
//        }
//        else{
//            return super.numberOfSections(in: tableView)
//        }
//    }
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//       if tableView == self.tableViewService {
//        return Funcs.currentShop.services.count
//       } else {
//        return super.tableView(tableView, numberOfRowsInSection: section)
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//       if tableView == self.tableViewService {
//        let cell = tableViewService.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! barberSelfServiceTableViewCell
//        cell.labelService.text = Funcs.currentShop.services[indexPath.row].name
//        cell.labelPrice.text = String(Funcs.currentShop.services[indexPath.row].price) + "€"
//        return cell
//       }
//       else{
//        return super.tableView(tableView, cellForRowAt: indexPath)
//        }
//    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
//
//    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//    
//    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    // REAUTH
    func createAlert(){
        let alert = UIAlertController(title: "Authentication", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField { (password) in
            password.placeholder = "Current Password"
            password.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
         self.present(alert, animated: true)
    }

}
