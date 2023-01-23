//
//  BookmarkVC.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import UIKit

class BookmarkVC: UIViewController {
    
    var myArticles: [NewsesMODEL] = []
    var idxPath: IndexPath!
    var isSearching = false
    var searchedBookmarks: [NewsesMODEL] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var TopLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        leadingConstraints.constant = view.bounds.width
        TopLabel.textColor = .white
        CoreDataManager.shared.getFromBookmark(newsUrl: nil)
        loadBookmarkData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func loadBookmarkData() {
        let Bookmarks = CoreDataManager.shared.bookmarks
        for bookmark in Bookmarks {
            if let title = bookmark.title, let time = bookmark.time, let imgURL = bookmark.imgURL, let URL = bookmark.url, let author = bookmark.author, let desc = bookmark.desc, let content = bookmark.content, let category = bookmark.category {
                let val = NewsesMODEL(title: title, time: time, imgURL: imgURL, URL: URL, author: author, desc: desc, content: content, category: category, bookmarkTick: false)
                myArticles.append(val)
            }
        }
        tableView.reloadData()
    }

    func handleDeleteAction(indexPath: IndexPath) {
        CoreDataManager.shared.deleteFromBookmark(indexPath: indexPath, from: "BookmarkVC")
        tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.detailsFromBookmarkVC {
            if let detailsPage = segue.destination as? DetailsVC {
                detailsPage.ti_tle = myArticles[idxPath.row].title
                detailsPage.time = myArticles[idxPath.row].time
                detailsPage.imgURL = myArticles[idxPath.row].imgURL
                detailsPage.url = myArticles[idxPath.row].URL
                detailsPage.author = myArticles[idxPath.row].author
                detailsPage.content = myArticles[idxPath.row].content
                detailsPage.desc = myArticles[idxPath.row].desc
                detailsPage.bookmarkTick = true
            }
        }
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        doAnimation()
    }
    
}

extension BookmarkVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching == false) {
            return CoreDataManager.shared.bookmarks.count
        }
        else {
            return searchedBookmarks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.bookmarkCell, for: indexPath) as! bookmarkTVC
        
        cell.imgView.layer.cornerRadius = 15
        
        if(isSearching == true) {
            let imgURL = URL(string: searchedBookmarks[indexPath.row].imgURL)
            cell.imgView.sd_setImage(with: imgURL, placeholderImage: UIImage(systemName: "photo"), context: nil)
            cell.titleField.text = searchedBookmarks[indexPath.row].title
        }
        else {
            let imgURL = URL(string: CoreDataManager.shared.bookmarks[indexPath.row].imgURL ?? "")
            cell.imgView.sd_setImage(with: imgURL, placeholderImage: UIImage(systemName: "photo"), context: nil)
            cell.titleField.text = CoreDataManager.shared.bookmarks[indexPath.row].title
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        idxPath = indexPath
        performSegue(withIdentifier: Constants.detailsFromBookmarkVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else {
                return
            }
            self.handleDeleteAction(indexPath: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeAction
    }
}

extension BookmarkVC: UISearchBarDelegate {
    func doAnimation() {
        TopLabel.textColor = UIColor(named: "customColor")
        UIView.animate(withDuration: 0.9, animations: { [weak self] in
            self?.leadingConstraints.constant = 0
            self?.view.layoutIfNeeded()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedBookmarks = myArticles.filter({$0.title.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        leadingConstraints.constant = view.bounds.width
        TopLabel.textColor = .white
        isSearching = false
        tableView.reloadData()
    }
}
