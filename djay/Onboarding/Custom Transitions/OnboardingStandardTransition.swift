import UIKit

final class OnboardingStandardTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.5

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = fromViewController.view,
            let toView = toViewController.view
        else {
            return transitionContext.completeTransition(true)
        }

        let containerView = transitionContext.containerView
        let screenWidth = containerView.bounds.width

        containerView.addSubview(toView)
        toView.frame = containerView.bounds
        toView.transform = CGAffineTransform(translationX: screenWidth, y: 0)

        containerView.addSubview(fromView)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
            fromView.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            toView.transform = .identity
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
