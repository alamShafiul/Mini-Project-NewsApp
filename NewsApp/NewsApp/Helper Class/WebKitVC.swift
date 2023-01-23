//
//  WKVC.swift
//  NewsApp
//
//  Created by Admin on 17/1/23.
//

import UIKit
import WebKit

class WebKitVC: UIViewController {

    var forURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        guard let url = URL(string: forURL ?? "") else { return }
        webView.load(URLRequest(url: url))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

}
