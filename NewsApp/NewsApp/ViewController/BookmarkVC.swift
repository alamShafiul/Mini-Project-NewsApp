//
//  BookmarkVC.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import UIKit

class BookmarkVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension BookmarkVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.bookmarkCell, for: indexPath) as! bookmarkTVC
        
        cell.titleField.text = "Title"
        
        return cell
    }
}
