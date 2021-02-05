//
//  PhotoViewController.swift
//  PermissionsSwift
//
//  Created by Jayxiang on 2020/7/7.
//  Copyright © 2020 hyd-cjx. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet var saveImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func intoPhotoClick(_ sender: Any) {
        Permissions.isAutoPresent = true
        Permissions.getPhotoPermissions { (authorized) in
            if authorized {
                let imagePickerController: UIImagePickerController = UIImagePickerController()
                imagePickerController.allowsEditing = false;
                imagePickerController.delegate = self;
                imagePickerController.sourceType = .photoLibrary;
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func saveClick(_ sender: Any) {
        if #available(iOS 14, *) {
            Permissions.getPhotoPermissions(level: .addOnly) { (authorized) in
                if authorized {
                    self.saveImageToPhoto()
                }
            }
        } else {
            Permissions.getPhotoPermissions { (authorized) in
                if authorized {
                    self.saveImageToPhoto()
                }
            }
        }
    }
    func saveImageToPhoto() {
        // 保存图片方式1
        UIImageWriteToSavedPhotosAlbum(self.saveImage.image!, self, #selector(save(image:didFinishSavingWithError:contextInfo:)), nil)
        // 保存图片方式2
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAsset(from: self.saveImage.image!)
//        }) { (success, error) in
//            guard error != nil else { return }
//            print("保存成功")
//        }
    }
    @objc func save(image:UIImage, didFinishSavingWithError:NSError?,contextInfo:AnyObject) {
        if didFinishSavingWithError != nil {
            print("保存失败")
        } else {
            print("保存成功")
        }
    }
}
// MARK: - UIImagePickerControllerDelegate
extension PhotoViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        selectImage.image = image
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
