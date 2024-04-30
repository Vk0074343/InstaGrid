//
//  ImageViewCell.swift
//  ImageGrid
//
//  Created by Vaibhav Khatri on 30/04/24.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage(from url: URL) {
        let cacheKey = url.absoluteString as NSString
        
        if let cachedImage = HomeVC.imageCache.object(forKey: url.absoluteString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        if let cachedImage = UIImage(contentsOfFile: HomeVC.imageFilePath(for: cacheKey as String)) {
            imageView.image = cachedImage
            HomeVC.imageCache.setObject(cachedImage, forKey: cacheKey)
            return
        }
        
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image.centerCroppedToSize(self.contentView.bounds.size)
                }
                
                HomeVC.imageCache.setObject(image, forKey: cacheKey)
                
                if let data = image.jpegData(compressionQuality: 1.0) {
                    try? data.write(to: HomeVC.imageFileURL(for: cacheKey as String))
                }
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
