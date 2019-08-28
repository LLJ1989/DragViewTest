//
//  ViewController.swift
//  DragViewTest
//
//  Created by Lucas Lombard on 28/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import UIKit

// source: https://stackoverflow.com/questions/3907397/uigesturerecognizer-on-uiimageview
// source: https://stackoverflow.com/questions/43714948/draggable-uiview-swift-3
// source: https://github.com/ioscreator/ioscreator/tree/master/IOS10DraggingViewsTutorial

class ViewController: UIViewController, UIGestureRecognizerDelegate {

  // MARK: - Outlets
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var draggingImage: UIImageView!
  @IBOutlet weak var draggingContainerView: UIView!
  
  // MARK: - Properties
  let cameraHandlerInstance = CameraHandler()
  var panRecognizer: UIPanGestureRecognizer?
  var pinchRecognizer: UIPinchGestureRecognizer?
  var rotateRecognizer: UIRotationGestureRecognizer?
  //var pangesture = UIPanGestureRecognizer()
  //var pinchGesture = UIPinchGestureRecognizer()
  //var rotateGesture = UIRotationGestureRecognizer()
  //var touchStart = CGPoint.zero
 // var proxyFactor = CGFloat(10)

  // MARK: - Methodes
  override func viewDidLoad() {
    super.viewDidLoad()
    self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
    self.pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
    self.rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotate(recognizer:)))
    //delegate gesture with UIGestureRecognizerDelegate
    pinchRecognizer?.delegate = self
    rotateRecognizer?.delegate = self
    panRecognizer?.delegate = self
    // than add gesture to imgView
    draggingContainerView.addGestureRecognizer(panRecognizer!)
    draggingContainerView.addGestureRecognizer(pinchRecognizer!)
    draggingContainerView.addGestureRecognizer(rotateRecognizer!)
   /* let sizeOfView = 50
    let maxViews = 100
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    // Add the Views
    for _ in 0 ..< maxViews {
      let pointX = Int.random(in: 0 ..< Int(view.bounds.width) - sizeOfView)
      let pointY = Int.random(in: Int(statusBarSize.height) ..< Int(view.bounds.height) - sizeOfView)

      let newView = CustomView(frame: CGRect(x: pointX, y: pointY, width: 50, height: 50))
      view.addSubview(newView)
    }*/
  }
  // handle UIPanGestureRecognizer
  @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    let gview = recognizer.view
    if recognizer.state == .began || recognizer.state == .changed {
      let translation = recognizer.translation(in: gview?.superview)
      gview?.center = CGPoint(x: (gview?.center.x)! + translation.x, y: (gview?.center.y)! + translation.y)
      recognizer.setTranslation(CGPoint.zero, in: gview?.superview)
    }
  }
  // handle UIPinchGestureRecognizer
  @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
    if recognizer.state == .began || recognizer.state == .changed {
      recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
      recognizer.scale = 1.0
    }
  }
  // handle UIRotationGestureRecognizer
  @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
    if recognizer.state == .began || recognizer.state == .changed {
      recognizer.view?.transform = (recognizer.view?.transform.rotated(by: recognizer.rotation))!
      recognizer.rotation = 0.0
    }
  }

  /*
   pour accéder à d'autres gestes, il faut décommenter ce qui a été commenter
   et commenter ce qui ne l'est pas. Il s'affichera alors des carrés colorés que l'on peut
   deplacer à loisir dans l'ensemble de la vue principale.
   */


 /* @objc func rotateAction(sender: UIRotationGestureRecognizer) {
    if sender.state == .began || sender.state == .changed {
      sender.view?.transform = (sender.view?.transform.rotated(by: sender.rotation))!
      sender.rotation = 0.0
    }
  }
  @objc func dragAction(_ sender: UIPanGestureRecognizer) {
    self.containerView.bringSubviewToFront(draggingContainerView)
    let translation = sender.translation(in: self.containerView)
    draggingContainerView.center = CGPoint(x: draggingContainerView.center.x + translation.x, y: draggingContainerView.center.y + translation.y)
    sender.setTranslation(CGPoint.zero, in: containerView)
  }
  @objc func pinchAction(_ sender: UIPinchGestureRecognizer) {
    if sender.state == .began || sender.state == .changed {
      sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
      sender.scale = 1.0
    }
  }*/
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

// MARK: - This extension manage adding picture
extension ViewController {
  // MARK: - Action
  @IBAction func didTapAddPictureButton(_ sender: UIButton) {
    addPicture()
  }
  // MARK: - Methodes
  private func addPicture() {
    cameraHandlerInstance.showPhotoActionSheet(controller: self)
    cameraHandlerInstance.imagePickedBlock = { (image) in
      self.draggingImage.image = image
    }
  }
}
