//
//  ViewController.swift
//  NewsApp
//
//  Created by Admin on 16/1/23.
//

import UIKit

class HomeVC: UIViewController {
    
//MARK: - variables
    var selectedIndex = IndexPath(item: 0, section: 0)
    
//MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
//MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }


}

//MARK: - All functions
extension HomeVC {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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

