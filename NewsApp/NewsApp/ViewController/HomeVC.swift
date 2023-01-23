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
    var currentoffset = 0
    var selectedIndexForCV = IndexPath(item: 0, section: 0)
    var myArticles = [NewsesMODEL]()
    var idxPath: IndexPath!
    var refreshControl = UIRefreshControl()
    
    
//MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var TopLabel: UILabel!
    
    
    
//MARK: - For Controlling Navigation Bar
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        leadingConstraints.constant = view.bounds.width
        TopLabel.textColor = .white
        populateTableView(category: CatModels.category[selectedIndexForCV.row])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    
//MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        searchBar.delegate = self
        
        autoRefresh()
        populateTableView(category: "All")
        
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    //MARK: - Action Buttons
    @IBAction func searchBtnTapped(_ sender: Any) {
        doAnimation()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.gotoDetailsSegue) {
            if let detailsPage = segue.destination as? DetailsVC {
                detailsPage.getHome = self
                detailsPage.ti_tle = myArticles[idxPath.row].title
                detailsPage.time = myArticles[idxPath.row].time
                detailsPage.imgURL = myArticles[idxPath.row].imgURL
                detailsPage.url = myArticles[idxPath.row].URL
                detailsPage.author = myArticles[idxPath.row].author
                detailsPage.content = myArticles[idxPath.row].content
                detailsPage.desc = myArticles[idxPath.row].desc
                detailsPage.bookmarkTick = myArticles[idxPath.row].bookmarkTick
            }
        }
    }
}


//MARK: - All functions
extension HomeVC {
    
    //MARK: autoRefresh
    func autoRefresh() {
        
        // return value in minute
        let prev = UserDefaults.standard.string(forKey: CatModels.category[selectedIndexForCV.row].uppercased()) ?? ""
        print("PrevTime: \(prev)")
        let totalClosedTime = calculateClosingTime(time: prev)
        print(totalClosedTime)
        if(totalClosedTime >= 30) {
            pleaseCallAPI(category: CatModels.category[selectedIndexForCV.row])
        }
        else {
            populateTableView(category: CatModels.category[selectedIndexForCV.row])
        }
    }

    
    func calculateClosingTime(time: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let date = dateFormatter.date(from: time)
        guard let date = date else {return 0.0}
        let passedTimeInSecond =  Date().timeIntervalSince(date)
        let minutes = round(passedTimeInSecond/60)
        print("sec: \(passedTimeInSecond), min: \(minutes)")
        return minutes
    }
    
    
    //MARK: refreshTable
    @objc func refreshTable() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("refreshed....")
            CoreDataManager.shared.deleteData(category: CatModels.category[self.selectedIndexForCV.row])
            self.pleaseCallAPI(category: CatModels.category[self.selectedIndexForCV.row])
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    //MARK: populateTableView
    func populateTableView(category: String) {
        
        // checking CoreData is empty or not
        CoreDataManager.shared.getData(category: category, searchText: " ")
        
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
            var flag = false
            for book in CoreDataManager.shared.bookmarks {
                if(item.URL == book.url) {
                    flag = true
                    break
                }
            }
            let val = NewsesMODEL(title: item.title, time: item.time, imgURL: item.imgURL, URL: item.URL, author: item.author, desc: item.desc, content: item.content, category: category, bookmarkTick: flag)
            CoreDataManager.shared.addData(newsModel: val)
        }
    }
    
    
    //MARK: getFromCoreData
    func getFromCoreData(category: String) {
        //CoreDataManager.shared.getData(category: category)
        let newses = CoreDataManager.shared.newses
        myArticles = []
        for news in newses {
            if let title = news.title, let time = news.time, let imgURL = news.imgURL, let URL = news.url, let author = news.author, let desc = news.desc, let content = news.content, let category = news.category {
                let val = NewsesMODEL(title: title, time: time, imgURL: imgURL, URL: URL, author: author, desc: desc, content: content, category: category, bookmarkTick: news.bookmarkTick)
                myArticles.append(val)
            }
        }
        tableView.reloadData()
    }
    
    
    //MARK: pleaseCallAPI
    func pleaseCallAPI(category: String) {
        activityIndicator.startAnimating()
        ApiCaller.shared.getDataFromAPI(category: category, completion: { [weak self] getArray in
            guard let self = self else { return }
            if let getArray = getArray {
                DispatchQueue.main.async {
                    self.myArticles = getArray
                    self.storeInCoreData(category: category)
                    //specifically changed for bookmark when pull to refresh is applied
                    self.populateTableView(category: category)
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    UserDefaults.standard.set(formatter.string(from: Date()), forKey: CatModels.category[self.selectedIndexForCV.row].uppercased())
                }
            }
        })
    }
    
    
    //MARK: bookMark
    func bookMark(indexPath: IndexPath)  {
        CoreDataManager.shared.getFromBookmark(newsUrl: myArticles[indexPath.row].URL)
        if(CoreDataManager.shared.bookmarks.count == 1) {
            // show some alert
        }
        else {
            CoreDataManager.shared.addToBookTable(newsModel: myArticles[indexPath.row])
            
            CoreDataManager.shared.getData(category: CatModels.category[selectedIndexForCV.row], searchText: " ")
            CoreDataManager.shared.updateData(indexPath: indexPath, flag: true)
            getFromCoreData(category: CatModels.category[selectedIndexForCV.row])
        }
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
        autoRefresh()
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
        cell.bookmarkView.image = UIImage(systemName: "bookmark")
        if(myArticles[indexPath.row].bookmarkTick == true) {
            cell.bookmarkView.image = UIImage(systemName: "bookmark.fill")
        }
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
        }
        bookmarkAction.image = UIImage(systemName: "bookmark.fill")
        bookmarkAction.backgroundColor = .systemYellow
        let actions = UISwipeActionsConfiguration(actions: [bookmarkAction])
        return actions
    }
}


//MARK: - SearchBarDelegate
extension HomeVC: UISearchBarDelegate {
    func doAnimation() {
        TopLabel.textColor = UIColor(named: "customColor")
        UIView.animate(withDuration: 0.9, animations: { [weak self] in
            self?.leadingConstraints.constant = 0
            self?.view.layoutIfNeeded()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        CoreDataManager.shared.getData(category: CatModels.category[selectedIndexForCV.row], searchText: searchText)
        getFromCoreData(category: CatModels.category[selectedIndexForCV.row])
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        leadingConstraints.constant = view.bounds.width
        TopLabel.textColor = .white
        CoreDataManager.shared.getData(category: CatModels.category[selectedIndexForCV.row], searchText: " ")
        getFromCoreData(category: CatModels.category[selectedIndexForCV.row])
    }
}


extension HomeVC{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}
