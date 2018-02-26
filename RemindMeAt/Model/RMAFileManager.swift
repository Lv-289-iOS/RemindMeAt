//
//  RMAFileManager.swift
//  RemindMeAt
//
//  Created by Ostin Ostwald on 2/19/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation
import UIKit

class RMAFileManager {
    var imageString = ""
    
    func loadImageFromPath(imageURL: String) -> UIImage {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        var pathURL: URL!
        pathURL = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(imageURL).jpg"))
        
        if let newPathUrl = pathURL {
            print("path for loading is \(newPathUrl)")
            do {
                let imageData = try Data(contentsOf: pathURL)
                return UIImage(data: imageData)!
            } catch {
                print(error.localizedDescription)
            }
        }
        return UIImage(named: "linux.jpg")!
    }
    func loadImageUrl(imageURL: String) -> URL {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        var pathURL: URL!
        pathURL = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(imageURL).jpg"))
        return pathURL
    }

    func addToUrl(_ photo: UIImage, create: String) {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let imgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(create).jpg"))
        print("path for adding is \(imgPath)")
        do {
            try UIImageJPEGRepresentation(photo, 1.0)?.write(to: imgPath, options: .atomic)
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
