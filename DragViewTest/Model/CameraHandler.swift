//
//  CameraHandler.swift
//  DragViewTest
//
//  Created by Lucas Lombard on 28/08/2019.
//  Copyright © 2019 Lucas Lombard. All rights reserved.
//

import UIKit
import Foundation
import Photos
import MobileCoreServices

//swiftlint:disable all
class CameraHandler: NSObject {

  // MARK: - Properties
  var currentVC: UIViewController!
  var imagePickedBlock: ((UIImage) -> Void)?
  var videoPickedBlock: ((NSURL) -> Void)?

  // MARK: - Enumerations
  enum AttachmentType: String {
    case camera, photoLibrary
  }

  // MARK: - Structures
  struct Constants {
    static let camera = "Appareil Photo"
    static let phoneLibrary = "Pellicule"
    static let cancelBtnTitle = "Annuler"
    static let alertForPhotoLibraryMessage = "Vous n'avez pas donné l'authorisation à Travel Friend d'accéder à la pélicule. Pour l'autoriser, allez dans les paramètres puis revenez ici."
    static let alertForCameraAccessMessage = "Vous n'avez pas donné l'authorisation à Travel Friend d'utiliser la caméra. Pour l'autoriser, allez dans les paramètres puis revenez ici."
    static let settingsBtnTitle = "Paramètres"
  }

  // MARK: - Methodes

  // These methodes manage adding photo or video to traval album
  func showPhotoVideoActionSheet(controller: UIViewController) {
    currentVC = controller
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
      self.authorisationPhotoStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
    }))
    actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
    controller.present(actionSheet, animated: true, completion: nil)
  }
  func authorisationPhotoStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
    currentVC = vc ; let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      if attachmentTypeEnum == AttachmentType.camera {
        cameraPhoto()
      }
    case .denied: print("permission denied")
    self.addAlertForSettings(attachmentTypeEnum)
    case .notDetermined:
      print("Permission Not Determined")
      PHPhotoLibrary.requestAuthorization({ (status) in
        if status == PHAuthorizationStatus.authorized{
          print("access given")
          if attachmentTypeEnum == AttachmentType.camera {
            self.cameraPhoto()
          }
        }else{
          print("restriced manually") ; self.addAlertForSettings(attachmentTypeEnum)
        }
      })
    case .restricted:
      print("permission restricted")
      self.addAlertForSettings(attachmentTypeEnum)
    default:
      break
    }
  }
  func cameraPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
      myPickerController.sourceType = .camera
      myPickerController.allowsEditing = true
      myPickerController.showsCameraControls = true
      myPickerController.mediaTypes = ["public.image", "public.movie"]
      currentVC.present(myPickerController, animated: true, completion: nil)
    }
  }
  // This methode manage adding profil photo and cover photo to trvail album
  func showPhotoActionSheet(controller: UIViewController) {
    currentVC = controller
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
      self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
    }))
    actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
      self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
    }))
    actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
    controller.present(actionSheet, animated: true, completion: nil)
  }
  // These methodes manages the differents possible stutus of authorization (using and/or accessing to camera, photo library)
  func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController) {
    currentVC = vc ; let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      if attachmentTypeEnum == AttachmentType.camera{
        camera()
      }
      if attachmentTypeEnum == AttachmentType.photoLibrary{
        photoLibrary()
      }
    case .denied: print("permission denied") ; self.addAlertForSettings(attachmentTypeEnum)
    case .notDetermined:
      print("Permission Not Determined")
      PHPhotoLibrary.requestAuthorization({ (status) in
        if status == PHAuthorizationStatus.authorized{
          print("access given")
          if attachmentTypeEnum == AttachmentType.camera{
            self.camera()
          }
          if attachmentTypeEnum == AttachmentType.photoLibrary{
            self.photoLibrary()
          }
        }else{
          print("restriced manually") ; self.addAlertForSettings(attachmentTypeEnum)
        }
      })
    case .restricted:
      print("permission restricted")
      self.addAlertForSettings(attachmentTypeEnum)
    default:
      break
    }
  }
  func addAlertForSettings(_ attachmentTypeEnum: AttachmentType){
    var alertTitle: String = ""
    if attachmentTypeEnum == AttachmentType.camera{
      alertTitle = Constants.alertForCameraAccessMessage
    }
    if attachmentTypeEnum == AttachmentType.photoLibrary{
      alertTitle = Constants.alertForPhotoLibraryMessage
    }
    let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
    let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
      let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
      if let url = settingsUrl {
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
      }
    }
    let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
    cameraUnavailableAlertController .addAction(cancelAction)
    cameraUnavailableAlertController .addAction(settingsAction)
    currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
  }
  // This methode manage the access to Camera.
  func camera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
      myPickerController.sourceType = .camera
      myPickerController.showsCameraControls = true
      myPickerController.allowsEditing = true
      myPickerController.mediaTypes = ["public.image"]
      currentVC.present(myPickerController, animated: true, completion: nil)
    }
  }
  // This methode manage access to photo library.
  func photoLibrary() {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
      myPickerController.sourceType = .photoLibrary
      myPickerController.allowsEditing = true
      myPickerController.mediaTypes = ["public.image"]
      currentVC.present(myPickerController, animated: true, completion: nil)
    }
  }
}

// MARK: - This extention is needed since Swift 4.2 migrator
extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // MARK: - Methodes
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    currentVC?.dismiss(animated: true, completion: nil)
  }
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      self.imagePickedBlock?(image)
    } else {
      print("Something went wrong in  image")
    }
    if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
      print("videourl: ", videoUrl)
      let data = NSData(contentsOf: videoUrl as URL)!
      print("File size before compression: \(Double(data.length / 1048576)) mb")
      compressWithSessionStatusFunc(videoUrl)
    } else {
      print("Something went wrong in  video")
    }
    currentVC?.dismiss(animated: true, completion: nil)
  }
  fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
    compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
      guard let session = exportSession else { return }
      switch session.status {
      case .unknown: break
      case .waiting: break
      case .exporting: break
      case .completed:
        guard let compressedData = NSData(contentsOf: compressedURL) else { return }
        print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
        DispatchQueue.main.async { self.videoPickedBlock?(compressedURL as NSURL) }
      case .failed: break
      case .cancelled: break
      default: break
      }
    }
  }
  func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
      handler(nil)
      return
    }
    exportSession.outputURL = outputURL
    exportSession.outputFileType = AVFileType.mov
    exportSession.shouldOptimizeForNetworkUse = true
    exportSession.exportAsynchronously { () -> Void in
      handler(exportSession)
    }
  }
}

// MARK: - Helper methodes inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}

