//
//  HomeVC.swift
//  ImageGrid
//
//  Created by Vaibhav Khatri on 30/04/24.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var imageURLs: [URL] = []
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    private static let diskCacheDirectory: URL = {
        let cacheDirectories = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectory = cacheDirectories[0].appendingPathComponent("ImageCache")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        return cacheDirectory
    }()
    private let baseURL = "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100"
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchImages()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 10
        
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        let itemWidth = (screenWidth - 4 * padding) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView.collectionViewLayout = layout
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: "ImageViewCell")
    }
}

//MARK: - Fetch Image and Parse JSON
extension HomeVC{
    private func fetchImages() {
        guard !isLoading else { return }
        isLoading = true
        
        let url = URL(string: baseURL)!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.isLoading = false }
            
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error fetching images: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard response.statusCode == 200 else {
                print("Error fetching images: Status code \(response.statusCode)")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                self.parseJSON(json)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func parseJSON(_ json: [[String: Any]]) {
        for item in json {
            if let thumbnail = item["thumbnail"] as? [String: Any], let key = thumbnail["key"] as? String,
               let domain = thumbnail["domain"] as? String, let basePath = thumbnail["basePath"] as? String {
                let imageURLString = "\(domain)/\(basePath)/0/\(key)"
                if let imageURL = URL(string: imageURLString) {
                    imageURLs.append(imageURL)
                }
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

//MARK: - CollectionView Datasource
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
        let imageURL = imageURLs[indexPath.item]
        cell.loadImage(from: imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let padding: CGFloat = 10
        let itemWidth = (collectionViewWidth - 4 * padding) / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

//MARK: - Image Chaching, Image Path and File URL
extension HomeVC {
    static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Adjust as needed
        cache.totalCostLimit = 1024 * 1024 * 100 // Adjust as needed
        return cache
    }()
    
    static func imageFilePath(for key: String) -> String {
        return diskCacheDirectory.appendingPathComponent(key).path
    }
    
    static func imageFileURL(for key: String) -> URL {
        return diskCacheDirectory.appendingPathComponent(key)
    }
}
