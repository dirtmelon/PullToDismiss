//
//  TableViewViewController.swift
//  PullToDismiss
//
//  Created by postman on 2019/7/13.
//  Copyright © 2019 dirtmelon. All rights reserved.
//

import UIKit

class TableViewViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "UITableViewCell")
        }
    }
    private weak var interactiveDismissTransition: InteractiveDismissTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        transitioningDelegate = self
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handleDismissPanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        /// 如果 panGestureRecognizer 生效，则不触发
        tableView.panGestureRecognizer.require(toFail: panGestureRecognizer)
    }
    
    @objc private func handleDismissPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            dismiss(animated: true)
        default: break
        }
        interactiveDismissTransition?.didPan(with: gestureRecognizer)
    }

}

extension TableViewViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let translation = panGestureRecognizer.translation(in: view)
        let velocityPoint = panGestureRecognizer.velocity(in: view)
        let isVerticalDrag = abs(velocityPoint.y) > abs(velocityPoint.x)
        if translation.y > 0 && tableView.contentOffset.y <= -tableView.contentInset.top {
            return true
        }
        return !isVerticalDrag
    }
}

extension TableViewViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactiveDismissTransition = InteractiveDismissTransition()
        self.interactiveDismissTransition = interactiveDismissTransition
        return interactiveDismissTransition
    }
}

extension TableViewViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
                                                 for: indexPath)
        cell.textLabel?.text = "\(indexPath.row) Cell"
        return cell
    }
}
