//
//  FileStorage.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 13/03/24.
//

import Firebase
import FirebaseStorage
import ProgressHUD
import Factory

class FileStorage {
    @Injected(\.storage) static var storage
    
    // MARK: - Images
    class func uploadImage(
        _ image: UIImage,
        directory: String,
        completion: @escaping (_ documentLink: String?) -> Void
    ) {
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        }
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            guard let progress = snapshot.progress else {
                return
            }
            
            let progressUploaded = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.progress(CGFloat(progressUploaded))
        }
    }
    
    class func downloadImage(
        imageUrl: String,
        completion: @escaping (_ image: UIImage) -> Void
    ) {
        let imageFileName: String = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            // Get it locally
            if let contentsOfFile = UIImage(
                contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)
            ) {
                completion(contentsOfFile)
            } else {
                print("could not generate image")
                completion(UIImage(named: "avatar") ?? UIImage())
            }
        } else {
            // Download
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        // Save it locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        let imageToReturn = UIImage(data: data! as Data)
                        
                        DispatchQueue.main.async {
                            completion(imageToReturn ?? UIImage())
                        }
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(UIImage(named: "avatar") ?? UIImage())
                        }
                    }
                }
            } else {
                print("no image in database")
                completion(UIImage(named: "avatar") ?? UIImage())
            }
        }
        
    }
    
    // MARK: - Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName)
        fileData.write(to: docUrl, atomically: true)
    }
}


// Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).last ?? URL(fileURLWithPath: "")
}

func fileExistsAtPath(path: String) -> Bool {
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: filePath)
}
