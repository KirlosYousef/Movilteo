//
//  ImagesService.swift
//  Movilteo
//
//  Created by Kirlos Yousef on 2020. 08. 16..
//

import Foundation
import UIKit

class ImagesService{
    
    static let shared = ImagesService()
    
    /// Stores the image locally.
    func saveImage(posterURL: URL, movieID id: String){
        
        var image = UIImage()
        
        let url = posterURL
        if let data = try? Data(contentsOf: url) as Data?{
            image = UIImage(data: data)!
        }
        guard let data = image.jpeg(.lowest) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            if UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString!).appendingPathComponent(String(id)).path) == nil {
                
                try data.write(to: directory.appendingPathComponent("\(id).png")!)
            }
        } catch {
            
            print(error.localizedDescription)
            return
        }
    }
    
    /// Looks for the requested image locally first. if not found, will use the posterURL.
    func getSavedImage(withID movieID: Int, posterURL: URL) -> UIImage? {
        
        // First look for the image locally.
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            
            if let image = UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(String(movieID)).path){
                return image
            } else {
                // if not found, try to use the poster url to get the image.
                return getImageFromUrl(posterURL: posterURL)
            }
        } else {
            return getImageFromUrl(posterURL: posterURL)
        }
    }
    
    private func getImageFromUrl(posterURL: URL) -> UIImage{
        
        if let data = try? Data(contentsOf: posterURL) as Data?{
            
            return UIImage(data: data)!
        } else {
            
            // Otherwise return "no picture".
            return #imageLiteral(resourceName: "No_Picture")
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
