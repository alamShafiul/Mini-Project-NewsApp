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
    var selectedIndex = IndexPath(item: 0, section: 0)
    var myArticles = [Article]()
    
//MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
//MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        
        pleaseCallAPI(category: "All")
        tableView.reloadData()
    }


}

//MARK: - All functions
extension HomeVC {
    func pleaseCallAPI(category: String) {
        activityIndicator.startAnimating()
        ApiCaller.shared.getDataFromAPI(category: category, completion: { [weak self] getArray in
            if let getArray = getArray {
                self?.myArticles = getArray
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            }
        })
        
        
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
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
        
        cell.catLabel.text = CatModels.category[indexPath.row]
        cell.bgView.backgroundColor = .white
        
        if(indexPath == selectedIndex) {
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
        
        pleaseCallAPI(category: CatModels.category[indexPath.row])
        
        selectedIndex = indexPath
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
        cell.imgView.sd_setImage(with: URL(string: myArticles[indexPath.row].urlToImage ?? ""), placeholderImage: UIImage(systemName: "photo"), context: nil)
        cell.titleField.text = myArticles[indexPath.row].title
        cell.authorField.text = myArticles[indexPath.row].author ?? "unknown author"
        cell.dateField.text = myArticles[indexPath.row].publishedAt
        
        return cell
    }
}

//MARK: - TableViewDelegate
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.gotoDetailsSegue, sender: nil)
    }
}

