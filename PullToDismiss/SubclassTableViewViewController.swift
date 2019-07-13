//
//  SubclassTableViewViewController.swift
//  PullToDismiss
//
//  Created by postman on 2019/7/10.
//  Copyright © 2019 dirtmelon. All rights reserved.
//

import UIKit

class SubclassTableViewViewController: UIViewController {

    @IBOutlet weak var tableView: TableView! {
        didSet {
            tableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "UITableViewCell")
        }
    }
    private weak var interactiveDismissTransition: InteractiveDismissTransition?
    private var needToResetTranslation: Bool = true
    private var currentTableViewOffset: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        transitioningDelegate = self
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handleDismissPanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
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

extension SubclassTableViewViewController: UITableViewDataSource, UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.setContentOffset(.zero, animated: false)
        } else if let currentTableViewOffset = currentTableViewOffset {
            scrollView.setContentOffset(currentTableViewOffset, animated: false)
        }
    }

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
extension SubclassTableViewViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactiveDismissTransition = InteractiveDismissTransition()
        self.interactiveDismissTransition = interactiveDismissTransition
        return interactiveDismissTransition
    }
}

class TableView: UITableView {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        /// 在手势开始时判断是否需要开始滑动
        if gestureRecognizer.state == .possible {
            let translation = panGestureRecognizer.translation(in: self)
            if translation.y > 0 && contentOffset.y <= -contentInset.top {
                return false
            }
        }
        return true
    }
}
