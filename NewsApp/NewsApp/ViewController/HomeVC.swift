//
//  ViewController.swift
//  NewsApp
//
//  Created by Admin on 16/1/23.
//

import UIKit
import SDWebImage

class HomeVC: UIViewController {
    
//MARK: - variables
    var selectedIndexForCV = IndexPath(item: 0, section: 0)
    var myArticles = [NewsesMODEL]()
    var idxPath: IndexPath!
    var refreshControl = UIRefreshControl()
    
//MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 
//MARK: - For Controlling Navigation Bar
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    
//MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        
        populateTableView(category: "All")
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.gotoDetailsSegue) {
            if let detailsPage = segue.destination as? DetailsVC {
                detailsPage.getHome = self
            }
        }
    }

}

//MARK: - All functions
extension HomeVC {
    //MARK: refreshTable
    @objc func refreshTable() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("refreshed....")
            self.pleaseCallAPI(category: CatModels.category[self.selectedIndexForCV.row])
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: populateTableView
    func populateTableView(category: String) {
        // checking CoreData is empty or not
        CoreDataManager.shared.getData(category: category)
        if(CoreDataManager.shared.newses.count == 0) {
            pleaseCallAPI(category: category)
        }
        else {
            getFromCoreData(category: category)
        }
    }
    
    //MARK: storeInCoreData
    func storeInCoreData(category: String) {
        for item in myArticles {
            let val = NewsesMODEL(title: item.title, time: item.time, imgURL: item.imgURL, URL: item.URL, author: item.author, desc: item.desc, content: item.content, category: category)
            CoreDataManager.shared.addData(newsModel: val)
        }
    }
    
    //MARK: getFromCoreData
    func getFromCoreData(category: String) {
        CoreDataManager.shared.getData(category: category)
        let newses = CoreDataManager.shared.newses
        myArticles = []
        for news in newses {
            if let title = news.title, let time = news.time, let imgURL = news.imgURL, let URL = news.url, let author = news.author, let desc = news.desc, let content = news.content, let category = news.category {
                let val = NewsesMODEL(title: title, time: time, imgURL: imgURL, URL: URL, author: author, desc: desc, content: content, category: category)
                myArticles.append(val)
            }
        }
        tableView.reloadData()
    }
    
    //MARK: pleaseCallAPI
    func pleaseCallAPI(category: String) {
        activityIndicator.startAnimating()
        ApiCaller.shared.getDataFromAPI(category: category, completion: { [weak self] getArray in
            if let getArray = getArray {
                self?.myArticles = getArray
                self?.storeInCoreData(category: category)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            }
        })
    }
    
    //MARK: bookMark
    func bookMark(indexPath: IndexPath) {
        
    }
    
    //MARK: setupCollectionView
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //MARK: setupTableView
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: - collectionViewDataSource
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CatModels.category.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.customColCell, for: indexPath) as! customCVC
        
        cell.catLabel.text = CatModels.category[indexPath.row].capitalized
        cell.bgView.backgroundColor = .white
        
        if(indexPath == selectedIndexForCV) {
            cell.bgView.backgroundColor = .systemGray4
        }
        
        return cell
    }
}

//MARK: - collectionViewDelegate
extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? customCVC else {
            return
        }
        
        //pleaseCallAPI(category: CatModels.category[indexPath.row])
        populateTableView(category: CatModels.category[indexPath.row])
        
        selectedIndexForCV = indexPath
        cell.bgView.backgroundColor = .systemGray
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? customCVC else {
            return
        }
        cell.bgView.backgroundColor = .white
        collectionView.reloadData()
    }
}

//MARK: - TableViewDataSource
extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArticles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customTblCell, for: indexPath) as! customTVC
        
        cell.imgView.layer.cornerRadius = 15
        
        cell.imgView.sd_setImage(with: URL(string: myArticles[indexPath.row].imgURL), placeholderImage: UIImage(systemName: "photo"), context: nil)
        cell.titleField.text = myArticles[indexPath.row].title
        cell.authorField.text = myArticles[indexPath.row].author
        cell.dateField.text = myArticles[indexPath.row].time
        
        return cell
    }
}

//MARK: - TableViewDelegate
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        idxPath = indexPath
        performSegue(withIdentifier: Constants.gotoDetailsSegue, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let bookmarkAction = UIContextualAction(style: .normal, title: nil) { [weak self]
            _, _, _ in
            guard let self = self else {
                return
            }
            self.bookMark(indexPath: indexPath)
            //completion(true)
        }
        bookmarkAction.image = UIImage(systemName: "bookmark.fill")
        bookmarkAction.backgroundColor = .systemYellow
        
        let actions = UISwipeActionsConfiguration(actions: [bookmarkAction])
        
        return actions
    }
}

