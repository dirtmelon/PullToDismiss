//
//  ContinuousGestureViewController.swift
//  PullToDismiss
//
//  Created by postman on 2019/7/13.
//  Copyright © 2019 dirtmelon. All rights reserved.
//

import UIKit

class ContinuousGestureViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!{
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
        panGestureRecognizer.delegate = self
    }

    @objc private func handleDismissPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        if velocity.y > 0 && tableView.contentOffset.y <= -tableView.contentInset.top {
            if needToResetTranslation {
                /// 开始进行 dismiss ，且需要对 translation 进行复原，防止位置错乱
                dismiss(animated: true)
                needToResetTranslation = false
                gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
                currentTableViewOffset = tableView.contentOffset
            }
        }
        /// 如果已回滚到顶部，且在 dismiss 过程中，则复位 needToResetTranslation 和 currentTableViewOffset
        if translation.y < 0 && !needToResetTranslation {
            needToResetTranslation = true
            currentTableViewOffset = nil
        }
        /// 如果是在 dismiss 过程中，则进行 dismiss 的交互动画
        if !needToResetTranslation {
            interactiveDismissTransition?.didPan(with: gestureRecognizer)
        }
        /// 如果手势结束，则复位 needToResetTranslation
        if gestureRecognizer.state != .began && gestureRecognizer.state != .changed {
            needToResetTranslation = true
            currentTableViewOffset = nil
        }
    }
}

extension ContinuousGestureViewController: UITableViewDataSource, UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 防止在 dismiss 过程中 tableView 滑动
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

extension ContinuousGestureViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        let interactiveDismissTransition = InteractiveDismissTransition()
        self.interactiveDismissTransition = interactiveDismissTransition
        return interactiveDismissTransition
    }
}

extension ContinuousGestureViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
