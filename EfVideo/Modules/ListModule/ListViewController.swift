//
//  ListViewController.swift
//  EfVideo
//
//  Created by user on 21.10.2022.
//

import UIKit

class ListViewController: BaseViewController {
    
    var viewModel: ListViewModelProtocol!
    @IBOutlet private weak var blueView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var tableViewManager: ListTableViewManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        complexShape()
        setupUI()
    }
    
    private func complexShape() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        let constWidth = UIScreen.main.bounds.size.width
        let constHeight = blueView.frame.size.height
        
        path.addLine(to: CGPoint(x: constWidth, y: 0.0))
        path.addLine(to: CGPoint(x: constWidth, y: constHeight - 60))
        path.addQuadCurve(to: CGPoint(x: constWidth - 30, y: constHeight - 30), controlPoint: CGPoint(x: constWidth, y: blueView.frame.size.height - 30))
        path.addLine(to: CGPoint(x: 30, y: constHeight - 30))
        path.addQuadCurve(to: CGPoint(x: 0.0, y: constHeight), controlPoint: CGPoint(x: 0.0, y: constHeight - 30))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        blueView.layer.mask = shapeLayer
    }
    
    func setupUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            self.viewModel.delegate = self
           
            self.tableViewManager = ListTableViewManager(tableView, data: viewModel.models())
            self.tableViewManager?.eventHandler = { event in
             //   self?.employeeEvent(event)
            }
        }
    }
}

extension ListViewController: ListViewModelDelegate {
    func didFetchingData() {
        self.tableViewManager?.reloadTable(data: viewModel.models())
    }
}
