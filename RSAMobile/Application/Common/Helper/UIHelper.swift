//
//  UIHelper.swift
//  RSAMobile
//
//  Created by LinhTY on 4/19/17.
//  Copyright © 2017 TCSVN. All rights reserved.
//

import Foundation

extension UIImageView {
    func makeRoundBorder(borderWidth : CGFloat, borderColor : UIColor = .white) {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true;
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
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
    
    var png: Data? { return UIImagePNGRepresentation(self) }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    func makeBlurImage() -> UIImage? {
        let imageToBlur = CIImage(image: self)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        blurfilter?.setValue(NSNumber.init(value: 5.0), forKey:kCIInputRadiusKey)
        if let resultImage = blurfilter?.outputImage {
            let rect = (imageToBlur?.extent)!
            let cgImage = CIContext(options: nil).createCGImage(resultImage, from: rect)
            let outImage = UIImage(cgImage: cgImage!)
            
            // Try to render image to not cause UI frozen
            outImage.draw(in: rect)
            
            return outImage
        }
        
        return nil
    }
    
    func cropToSize(_ targetSize : CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!

    }
    
}


extension UIButton {
    func makeHalfRoundMask(_ borderWidth : CGFloat, isVertical: Bool = false) {
        var radius = isVertical == true ? self.frame.size.height/2 : self.frame.size.width / 2
        radius -= borderWidth
        
        let circlePath = UIBezierPath.init(arcCenter: CGPoint(x: radius + borderWidth, y: 0), radius: radius, startAngle: 0.0, endAngle: CGFloat(Double.pi), clockwise: true)
        let circleShape = CAShapeLayer()
        circleShape.path = circlePath.cgPath
        self.layer.mask = circleShape
 
    }
}

var gAvatarImage : UIImage? = nil
var gIsDownloadingAvatar : Bool = false
let notificationAvatarImageFinishDownload = "avatarImageFinishDownload"
var gBlurAvatarImage : UIImage? = nil
var gIsCreateBlurAvatar : Bool = false
let notificationBlurAvatarImageCreated = "blurAvatarImageDownloaded"

extension UIViewController {
    func getAvatarImage() -> UIImage? {
        
        let url = UserHelper().getUserAvatar() ?? " "
        let urlBlur = UserHelper().getUserAvatarBlur() ?? " "

        // get image from cache
        gAvatarImage = RequestService.shareInstance.imageCache.object(forKey: url as NSString) as? UIImage
        gBlurAvatarImage = RequestService.shareInstance.imageCache.object(forKey: urlBlur as NSString) as? UIImage
        // if image is not cached then download again
        if (gAvatarImage != nil) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: gAvatarImage)
            if (gBlurAvatarImage != nil) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: gBlurAvatarImage)
            }else{
                self.loadBlurImageFromImage(gAvatarImage)
            }
            return gAvatarImage
        }
        if (url != " ") {
            self.downAvatarImage(path: url)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: UIImage(named: "bg"))
        return UIImage(named: "avatar")
    }
    
    fileprivate func downAvatarImage(path : String) {
        if !gIsDownloadingAvatar {
            let  fullPath = URLBase + path
            if let pictureURL = URL(string: fullPath) {
                gIsDownloadingAvatar = true
                RequestService.shareInstance.getDataFromUrl(keyForDictTask: ServerConfigure.Path.downloadAvatar, url: pictureURL) { (data, response, error)  in
                    guard let data = data, error == nil else {
                        gIsDownloadingAvatar = false    // Remove flags
                        return
                    }
                    
                    if let image = UIImage(data: data) {
                        // Check here, we only download at the first time open app, so if gAvatarImage has change, don't update image
                        if gAvatarImage == nil {
                            self.updateAvatar(image)
                        }
                    }
                    
                    gIsDownloadingAvatar = false    // Remove flags
                }
                
            }
        }
    }
    
    func updateAvatar (_ image: UIImage?) {
        gAvatarImage = image?.cropToSize(CGSize(width: UIParameter.AvatarSize, height: UIParameter.AvatarSize))
        // cache avatar image
        if (gAvatarImage != nil) && (UserHelper().getUserAvatar() != nil) {
            RequestService.shareInstance.imageCache.setObject(gAvatarImage!, forKey: UserHelper().getUserAvatar()! as NSString )
        }
        // Waiting for creating blur image finish
        while gIsCreateBlurAvatar == true {
            RunLoop.current.run(mode: .defaultRunLoopMode, before: Date.distantFuture)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationAvatarImageFinishDownload), object: gAvatarImage)
        self.loadBlurImageFromImage(gAvatarImage)
    }

    func loadBlurImageFromImage (_ image : UIImage?) {
        if image != nil, !gIsCreateBlurAvatar {
            gIsCreateBlurAvatar = true
            DispatchQueue.global(qos: .background).async {
                if let blurImg = image?.makeBlurImage() {
                    gBlurAvatarImage = blurImg
                    gIsCreateBlurAvatar = false
                    if (gBlurAvatarImage != nil) && (UserHelper().getUserAvatarBlur() != nil){
                        //Cache blur avatar image
                        RequestService.shareInstance.imageCache.setObject(gAvatarImage!, forKey: UserHelper().getUserAvatarBlur()! as NSString)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: blurImg)
                }
            }
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:notificationBlurAvatarImageCreated), object: UIImage(named: "bg"))
        }
    }
}
