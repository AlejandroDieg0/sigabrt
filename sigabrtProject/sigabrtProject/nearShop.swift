//
//  nearShop.swift
//  sigabrtProject
//
//  Created by Luigi Faticoso on 25/05/2017.
//  Copyright © 2017 Alessandro Cascino. All rights reserved.
//

import UIKit

class nearShop: UITableViewCell {

    @IBOutlet weak var shopName: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var imgShop: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
