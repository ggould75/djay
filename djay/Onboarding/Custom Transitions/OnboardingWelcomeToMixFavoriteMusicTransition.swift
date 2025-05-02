import UIKit

final class OnboardingWelcomeToMixFavoriteMusicTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.6

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? OnboardingWelcomeViewController,
            let toViewController = transitionContext.viewController(forKey: .to) as? OnboardingMixFavoriteMusicViewController,
            let toView = toViewController.view
        else {
            return transitionContext.completeTransition(true)
        }

        let containerView = transitionContext.containerView

        let fromLogoView = fromViewController.logoImageView
        guard let fromSnapshotLogoView = fromLogoView.snapshotView(afterScreenUpdates: false) else {
            return transitionContext.completeTransition(true)
        }

        containerView.addSubview(toView)

        toView.alpha = 0
        toView.setNeedsLayout()
        toView.layoutIfNeeded()

        let toLogoImageView = toViewController.logoImageView
        let logoViewStartFrame = fromLogoView.convert(fromLogoView.bounds, to: containerView)
        let logoViewEndFrame = toLogoImageView.convert(toLogoImageView.bounds, to: containerView)

        fromSnapshotLogoView.frame = logoViewStartFrame
        containerView.addSubview(fromSnapshotLogoView)

        fromLogoView.alpha = 0
        toLogoImageView.alpha = 0

        let welcomeLabel = fromViewController.welcomeLabel
        guard let welcomeLabelSnapshot = welcomeLabel.snapshotView(afterScreenUpdates: false) else {
            return transitionContext.completeTransition(true)
        }

        welcomeLabelSnapshot.frame = welcomeLabel.convert(welcomeLabel.bounds, to: containerView)
        containerView.addSubview(welcomeLabelSnapshot)
        welcomeLabel.alpha = 0

        let initialTransform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: 30)

        let favoriteMusicLabel = toViewController.favoriteMusicLabel
        favoriteMusicLabel.transform = initialTransform

        let appsImageView = toViewController.appsImageView
        appsImageView.transform = initialTransform

        let appleAwardImageView = toViewController.appleAwardImageView
        appleAwardImageView.transform = initialTransform

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // Translate the logo snapshot (first 60% of animation)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                fromSnapshotLogoView.frame = logoViewEndFrame
            }

            // Fade out and translate down the welcome label (first 30% of animation)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                welcomeLabelSnapshot.alpha = 0
                welcomeLabelSnapshot.transform = CGAffineTransform(translationX: 0, y: 50)
            }

            // Fade-in the destination view (100% of animation)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toView.alpha = 1
            }

            // Animate subviews to their final position (last 90% of animation)
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.9) {
                appsImageView.transform = .identity
                favoriteMusicLabel.transform = .identity
                appleAwardImageView.transform = .identity
            }
        }) { _ in
            toLogoImageView.alpha = 1
            welcomeLabel.alpha = 1

            fromLogoView.removeFromSuperview()
            fromSnapshotLogoView.removeFromSuperview()
            welcomeLabelSnapshot.removeFromSuperview()

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
