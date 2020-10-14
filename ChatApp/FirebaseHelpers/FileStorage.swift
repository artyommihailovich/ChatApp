//
//  FileStorage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/8/20.
//

import Foundation
import Firebase
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    
    //MARK: - Images

    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        let storageReference = storage.reference(forURL: kFILEREFERENCE).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.7)
        var task: StorageUploadTask!
        
        task = storageReference.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading image \(error?.localizedDescription)")
                return
            }
            
            storageReference.downloadURL { (url, error) in
                
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadURL.absoluteString)
            }
        })
        
        //How much % of image uploading UI
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistAtPath(path: imageFileName) {
            // get it locally
           print("We have a local file")
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("Could not convert at image!")
                completion(UIImage(named: "avatar"))
            }
        } else {
            // download from firebase
            print("Let's get file from firebase!")
            
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        // Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    } else {
                        print("No document in database!")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Save locally
    
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        
        fileData.write(to: docUrl, atomically: true)
    }
}


    //MARK: - Helpers

    func fileInDocumentDirectory(fileName: String) -> String {
        
        return getDocumentsURL().appendingPathComponent(fileName).path
        
    }

    func getDocumentsURL() -> URL {
        
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    func fileExistAtPath(path: String) -> Bool {

        return FileManager.default.fileExists(atPath: fileInDocumentDirectory(fileName: path))
    }

    
