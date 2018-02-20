//
//  RMAFileManager.swift
//  RemindMeAt
//
//  Created by Ostin Ostwald on 2/19/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation
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
    
    func loadImageFromPath(imageURL: String) -> UIImage? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        var pathURL: URL!
        pathURL = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(imageURL).jpg"))
        
        print("loaded from: \(pathURL)")
        
        do {
            let imageData = try Data(contentsOf: pathURL)
            return UIImage(data: imageData)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func addToUrl(_ photo: UIImage, create: Date) -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        let imgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(create).jpg"))
        imageString = String(describing: imgPath)
        print("loaded in: \(imageString)")
        do{
            try UIImageJPEGRepresentation(photo, 1.0)?.write(to: imgPath, options: .atomic)
        } catch let error {
            print(error.localizedDescription)
        }
        return imageString
        
        
        
    }
    
}
