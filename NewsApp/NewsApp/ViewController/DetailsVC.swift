//
//  DetailsVC.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import UIKit

class DetailsVC: UIViewController {

    var getHome: HomeVC?
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var timeField: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var authorField: UILabel!
    
    @IBOutlet weak var contentField: UILabel!
    @IBOutlet weak var descField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = getHome?.myArticles[(getHome?.idxPath.row)!].title
        timeField.text = getHome?.myArticles[(getHome?.idxPath!.row)!].publishedAt
        
        let imgURL = getHome?.myArticles[(getHome?.idxPath.row)!].urlToImage
        imgView.sd_setImage(with: URL(string: imgURL ?? ""), placeholderImage: UIImage(systemName: "photo"), context: nil)
        
        
        authorField.text = "by-\(getHome?.myArticles[(getHome?.idxPath.row)!].author ?? "unknow author")"
        descField.text = getHome?.myArticles[(getHome?.idxPath.row)!].description
        contentField.text = getHome?.myArticles[(getHome?.idxPath.row)!].content
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.gotoWebSegue {
            if let webPage = segue.destination as? WKVC {
                webPage.forURL = getHome?.myArticles[(getHome?.idxPath.row)!].url
            }
        }
    }
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.gotoWebSegue, sender: nil)
    }
    
}
