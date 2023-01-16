//
//  customTVC.swift
//  NewsApp
//
//  Created by Admin on 16/1/23.
//

import UIKit

class customTVC: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var titleField: UILabel!
    
    @IBOutlet weak var authorField: UILabel!
    
    @IBOutlet weak var dateField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
