//
//  PhotoEditingViewController.swift
//  inphotoExtension
//
//  Created by liuding on 2018/11/26.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    let processor = ImageProcessor()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        imageView.image = input!.displaySizeImage
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            let archiveData =  try? NSKeyedArchiver.archivedData(withRootObject: "inphoto", requiringSecureCoding: false)
            
            if let data = archiveData {
                let identifier = "com.eastree.inphoto"
                let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: "1.0", data: data)
                output.adjustmentData = adjustmentData
            }
            
            if let imageURL = self.input?.fullSizeImageURL {
                var image = UIImage(contentsOfFile: imageURL.path)!
                image = self.processor.processImage(image)
                
//                Metadata.updateImage(on: imageURL, to: output.renderedContentURL, with: [:])
                
             
                let renderedJPEGData = image.jpegData(compressionQuality: 0.1)
                try? renderedJPEGData?.write(to: output.renderedContentURL)
            }
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
