//
//  DetailsVC.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import UIKit

class DetailsVC: UIViewController {

    var getHome: HomeVC?
    
    var ti_tle: String = ""
    var time: String = ""
    var imgURL: String = ""
    var url: String = ""
    var author: String = "unknown author"
    var content: String = ""
    var desc: String = ""
    var bookmarkTick: Bool = false
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeField: UILabel!
    
    @IBOutlet weak var bookmarkBtnOutlet: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var authorField: UILabel!
    
    @IBOutlet weak var contentField: UILabel!
    @IBOutlet weak var descField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.text = ti_tle
        timeField.text = time
        imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(systemName: "photo"), context: nil)
        authorField.text = author
        descField.text = desc
        contentField.text = content
        bookmarkBtnOutlet.setImage(UIImage(systemName: bookmarkTick ? "bookmark.fill" : "bookmark"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.gotoWebSegue {
            if let webPage = segue.destination as? WebKitVC {
                webPage.forURL = url
            }
        }
    }
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.gotoWebSegue, sender: nil)
    }
    
    
    @IBAction func bookmarkBtnTapped(_ sender: Any) {
        
        guard let getHome = getHome else {
            return
        }
        
        if bookmarkBtnOutlet.imageView?.image == UIImage(systemName: "bookmark") {
            bookmarkBtnOutlet.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            getHome.bookMark(indexPath: (getHome.idxPath))
        }
        else {
            bookmarkBtnOutlet.setImage(UIImage(systemName: "bookmark"), for: .normal)
            CoreDataManager.shared.deleteFromBookmark(indexPath: (getHome.idxPath)!, from: "DetailsVC")
        }
    }
    
}
