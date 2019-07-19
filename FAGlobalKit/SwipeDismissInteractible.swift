//
//  PriveFinalizeTransitionInteraction.swift
//  Mf_3
//
//  Created by Ferhat Abdullahoglu on 26.04.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//


import UIKit

public protocol SwipeDismissInteractible where Self: UIViewController & UIGestureRecognizerDelegate {
    /// Variable to add the gesture recognizer to
    var gestureView: UIView {get}
}

public protocol SwipeDismissInteractibleNavigationController where Self: UINavigationController & UIGestureRecognizerDelegate {
    /// Variable to add the gesture recognizer to
    var gestureView: UIView {get}
}

public class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    private enum InteractorType: Int {
        case viewController = 0
        case navigationController = 1
    }
    
    public var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: SwipeDismissInteractible!
    private weak var navigationController: SwipeDismissInteractibleNavigationController!
    private let interactorType: InteractorType
    private var oldTranslation: CGFloat = 0
    
    public init(viewController: UIViewController & SwipeDismissInteractible) {
        self.interactorType = .viewController
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.gestureView)
    }
    
    public init(navigationController: SwipeDismissInteractibleNavigationController) {
        self.interactorType = .navigationController
        super.init()
        self.navigationController = navigationController
        prepareGestureRecognizer(in: self.navigationController.gestureView)
    }
    
    
    private func prepareGestureRecognizer(in view: UIView) {
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        
        view.addGestureRecognizer(gesture)
        
        switch interactorType {
        case .viewController:
            gesture.delegate = viewController
        case .navigationController:
            gesture.delegate = navigationController
        }
    }
    
    
    @objc
    public func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let viewToCheck: UIView
        
        switch interactorType {
        case .viewController:
            viewToCheck = viewController.view
        case .navigationController:
            viewToCheck = navigationController.view
        }
        
        let translation = gestureRecognizer.translation(in: viewToCheck)
        
        var progress = ((translation.y * 1) / viewToCheck.bounds.height)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            switch interactorType {
            case .viewController:
                viewController.dismiss(animated: true, completion: nil)
            case .navigationController:
                navigationController.dismiss(animated: true, completion: nil)
            }
            completionSpeed = 1
        case .changed:
            shouldCompleteTransition = progress > 0.4 || ((translation.y - oldTranslation) > 5)
            update(progress)
        case .cancelled:
            completionCurve = .easeOut
            completionSpeed = 0.5
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                completionCurve = .easeOut
                completionSpeed = 0.5
                cancel()
            }
        default:
            break
        }
        
        oldTranslation = translation.y
    }
}
