//
//  BaseViewController.swift
//  EfVideo
//
//  Created by user on 15.10.2022.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {

    let activityView: UIActivityIndicatorView
    var disposeBag: DisposeBag = DisposeBag()
    
    init() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView.tintColor = UIColor.black
        super.init(nibName: nil, bundle: nil)
        
        activityView.center = self.view.center
        self.view.addSubview(activityView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func showLoader() {
        activityView.startAnimating()
    }
    
    func hideLoader() {
        activityView.stopAnimating()
    }

}
