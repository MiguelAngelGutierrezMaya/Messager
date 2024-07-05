//
//  EditProfileTableViewController.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 24/02/24.
//

import UIKit
//import Gallery
import YPImagePicker
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: - Vars
    //    var gallery: GalleryController!
    var picker: YPImagePicker?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        configureTextField()
        setupPicker()
        // avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    // MARK: - TableViewDelegate
    override func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editProfileToStatusSeg", sender: self)
        }
    }
    
    // MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: Any) {
        //        showImageGallery()
        showPicker()
    }
    
    // MARK: - UpdateUI
    private func showUserInfo() {
        if let user = User.currentUser {
            usernameTextField.text = user.username
            statusLabel.text = user.status
            
            if !user.avatarLink.isEmpty {
                // Load the image
                FileStorage.downloadImage(
                    imageUrl: user.avatarLink
                ) { image in
                    self.avatarImageView.image = image.circleMasked
                }
            }
        }
    }
    
    // MARK: - Configure
    private func configureTextField() {
        usernameTextField.delegate = self
        usernameTextField.clearButtonMode = .whileEditing
    }
    
    func setupPicker() {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.screens = [.library]
        
        config.library.maxNumberOfItems = 1
        
        picker = YPImagePicker(configuration: config)
    }
    
    // MARK: - Gallery
    private func showImageGallery() {
        //        gallery = GalleryController()
        //        gallery.delegate = self
        //
        //        Config.tabsToShow = [.imageTab, .cameraTab]
        //        Config.Camera.imageLimit = 1
        //        Config.initialTab = .imageTab
        
        //        self.present(gallery, animated: true, completion: nil)
    }
    
    func showPicker() {
        
        guard let picker = picker else { return }
        
        picker.didFinishPicking { (items: [YPMediaItem], cancelled: Bool) in
            if cancelled {
                print("Picker was canceled")
            }
            
            if items.count > 0 {
                let item: YPMediaItem? = items.first
                
                switch item {
                case .photo(let photo):
                    //this is just an example to show in imageView
                    DispatchQueue.main.async {
                        self.uploadAvatarImage(photo.image) { imageUrl in
                            if (!(imageUrl ?? "").isEmpty) {
                                self.avatarImageView.image = photo.image.circleMasked
                            }
                        }
                    }
                case .video(let video):
                    //if you need to access videos as well
                    print(video)
                case .none:
                    print("none")
                }
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Upload Image
    private func uploadAvatarImage(_ image: UIImage, completion: @escaping (_ url: String?) -> Void) {
        let fileDirectory: String = "Avatars/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
            
            let imageCompressed: NSData = image.jpegData(compressionQuality: 0.8)! as NSData
            
            FileStorage.saveFileLocally(
                fileData: imageCompressed,
                fileName: User.currentId
            )
            
            completion(avatarLink)
        }
    }
}

extension EditProfileTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            if !(textField.text?.isEmpty ?? true) {
                if var user = User.currentUser {
                    user.username = textField.text ?? ""
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFirestore(user)
                }
            }
            
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
}

//extension EditProfileTableViewController: GalleryControllerDelegate {
//    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
//        if images.count > 0 {
//            images.first!.resolve { (image) in
//
//                if let image = image {
//                    // TODO: upload image
//
//                    self.avatarImageView.image = image.circleMasked
//                } else {
//                    ProgressHUD.showError("Couldn't select image!")
//                }
//            }
//        }
//
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//
//    func galleryControllerDidCancel(_ controller: GalleryController) {
//        controller.dismiss(animated: true, completion: nil)
//    }
//}
