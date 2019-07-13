//
//  InteractiveDismissTransition.swift
//  PullToDismiss
//
//  Created by postman on 2019/7/10.
//  Copyright © 2019 dirtmelon. All rights reserved.
//

import UIKit

class DismissTransition: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        [toView, fromView]
            .compactMap { $0 }
            .forEach { containerView.addSubview($0) }

        let duration = transitionDuration(using: transitionContext)
        let spring: CGFloat = 0.9
        let animator = UIViewPropertyAnimator(duration: duration,
                                              dampingRatio: spring) {
                                                fromView.frame.origin.y = containerView.frame.height
        }
        animator.addCompletion { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
}

class InteractiveDismissTransition: NSObject, UIViewControllerInteractiveTransitioning {

    typealias Range = (min: CGFloat, max: CGFloat)
    private var transitionContext: UIViewControllerContextTransitioning?

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                return
        }
        self.transitionContext = transitionContext
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
    }

    func didPan(with gestureRecognizer: UIPanGestureRecognizer) {
        guard let transitionContext = transitionContext else {
                return
        }

        let velocityPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let translationPoint = gestureRecognizer.translation(in: gestureRecognizer.view)

        let percentComplete = self.percentComplete(for: translationPoint.y)

        switch gestureRecognizer.state {
        case .possible, .began:
            break
        case .cancelled, .failed:
            completeTransition(didCancel: true)
        case .changed:
            let translation: CGFloat = translationPoint.y
            if translation >= 0 {
                let fromView = transitionContext.view(forKey: .from)
                fromView?.frame.origin.y = translation
                transitionContext.updateInteractiveTransition(percentComplete)
            }
        case .ended:
            let velocityShouldComple: CGFloat = 320.0
            completeTransition(didCancel: !(velocityPoint.y >= velocityShouldComple || percentComplete > 0.3))
        @unknown default:
            break
        }

    }

    private func percentComplete(for translation: CGFloat) -> CGFloat {
        let maximumDelta: CGFloat = UIScreen.main.bounds.height
        let inRange: Range = (CGFloat(0), maximumDelta)
        let toRange: Range = (CGFloat(0.0), CGFloat(1.0))
        if translation < inRange.min {
            return toRange.min
        } else if translation > inRange.max {
            return toRange.max
        } else {
            let ratio = (translation - inRange.min) / (inRange.max - inRange.min)
            return toRange.min + ratio * (toRange.max - toRange.min)
        }
    }

    private func completeTransition(didCancel: Bool) {
        guard let transitionContext = transitionContext,
            let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        let completionDuration: Double
        let completionDamping: CGFloat
        if didCancel {
            completionDuration = 0.45
            completionDamping = 0.75
        } else {
            completionDuration = 0.37
            completionDamping = 0.90
        }

        let animator = UIViewPropertyAnimator(duration: completionDuration,
                                              dampingRatio: completionDamping)
        animator.addAnimations {
            if didCancel {
                fromView.frame = containerView.bounds
            } else {
                fromView.frame.origin.y = containerView.frame.height
            }
        }
        animator.addCompletion { _ in

            if didCancel {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
            transitionContext.completeTransition(!didCancel)
            self.transitionContext = nil
        }
        animator.startAnimation()
    }
}
