//
//  ImageCollectionViewController.swift
//  ImageLoader
//
//  Created by PradheepNarendran on 18/04/24.
//

import UIKit

// Constants for layout
let numberOfColumns: CGFloat = 3
let spacing: CGFloat = 2

// View Controller responsible for displaying images in a collection view
class ImageGridViewController: UIViewController {
  // Outlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var offlineBanner: UIView!
  @IBOutlet weak var offlineView: UIView!
  
  // View Model
  var viewModel = ImageGridViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Register custom collection view cell
    self.collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
    
    // Configure collection view layout
    let v = DynamicFlowLayout()
    self.collectionView.collectionViewLayout = v
    
    // Adjust layout spacing
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = spacing
      layout.minimumInteritemSpacing = spacing
      layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    // Register for network change notification
    NotificationCenter.default.addObserver(self, selector: #selector(self.networkChange), name: .networkNotification, object: nil)
    
    // Fetch initial data
    viewModel.fetchData()
            
    // Callback to handle data update in ViewModel
    viewModel.onDataUpdate = { [weak self] response in
      // Handle response
      switch response {
      // Update UI based on success or failure
      case .success:
        if let self {
          DispatchQueue.main.async {
            self.offlineView.isHidden = true
            self.offlineBanner.isHidden = true
            if self.viewModel.images.count > 30 {
              self.collectionView.insertItems(at: self.viewModel.indexPaths)
            } else {
              self.collectionView.reloadData()
            }
          }
        }
      case .failure:
        if let self {
          DispatchQueue.main.async {
            if self.viewModel.images.count == 0 {
              self.offlineView.isHidden = false
            }
            self.offlineBanner.isHidden = false
            self.viewModel.isLoading = false
          }
        }
      }
    }
  }
  
  // Function to handle network change notification
  @objc func networkChange() {
    // Handle network change
    // Fetch data or show offline banner based on connectivity
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      Reachability.shared.isConnectedToNetwork(completion: {[weak self] isConnected in
        if isConnected {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self?.viewModel.fetchData()
          }
        } else {
          DispatchQueue.main.async {
            self?.offlineBanner.isHidden = false
          }
        }
      })
    }
  }    
  
  // Function to render image asynchronously
  func renderImageAsync(for indexPath: IndexPath) {
    // Fetch image from URL and render it in the collection view cell
    guard let url = URL(string: self.viewModel.images[indexPath.item].urls.regular) else { return }
    
    let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
    if let cachedImage = viewModel.cache.object(forKey: "image_\(indexPath.item)" as NSString) {
      if let cell {
        self.renderVisibleCell(cell: cell, indexPath: indexPath, image: cachedImage)
      }
      if cell?.imageView.image == UIImage(systemName: "photo.on.rectangle.angled"){
        fetchImage(indexPath: indexPath, url: url)
      }
    } else {
      fetchImage(indexPath: indexPath, url: url)
    }
    
  }
  
  // Method to perform async call to fetch image(s)
  func fetchImage(indexPath: IndexPath, url: URL){
    Task {
      let result = await ImageViewModel(imageModel: ImageDataModel(imageURL: url)).loadImage(indexPath: indexPath)
      DispatchQueue.main.async {
        // Check if the cell is still intended to display the same image
        if let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
          // Only update the cell's image if it's still intended for the same index path
          if let resultUW = result, let image = resultUW.0, cell.imageView.image == UIImage(systemName: "photo.on.rectangle.angled") {
            self.viewModel.cache.setObject(image, forKey: "image_\(resultUW.2.item)" as NSString)
            self.renderVisibleCell(cell: cell, indexPath: resultUW.2, image: image)
            cell.isImageLoaded = true
            self.viewModel.images[resultUW.2.item].isImageLoaded = true
          }
        }
      }
    }
  }
  
  func renderVisibleCell(cell: ImageCollectionViewCell, indexPath: IndexPath, image: UIImage){
    if self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
      cell.imageView.image = image
      cell.setNeedsLayout()
    }
  }
}

// Extension to conform to UICollectionViewDelegate and UICollectionViewDataSource protocols
extension ImageGridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  
  // UICollectionViewDataSource methods
  // Function to configure and return collection view cells
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Configure and return custom collection view cell
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
    guard let url = URL(string: viewModel.images[indexPath.row].urls.regular) else { return UICollectionViewCell()}
    renderImageAsync(for: indexPath)
    cell.backgroundColor = .black
    return cell
  }
  
  // Function to return number of sections in collection view
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  // Function to return number of items in a section
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.images.count
  }
  
  // Function to return inset for section in collection view layout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }
  
  // Function to handle cell display in collection view
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // Load more data when user scrolls to end
    let lastItem = viewModel.images.count - 1
    if indexPath.row == lastItem && !viewModel.isLoading {
      // Load more data when the user scrolls to the end and data is not currently being loaded
      viewModel.fetchData()
    }
  }
  
  // Function to handle cell selection
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Handle cell selection
    print(self.viewModel.images[indexPath.item].urls.regular)
  }
  
  
  // Function to handle scroll view end dragging
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    // Load images for visible cells asynchronously
    let visibleOnes = self.collectionView.indexPathsForVisibleItems
    let notLoaded = visibleOnes.filter({(self.collectionView.cellForItem(at: $0) as? ImageCollectionViewCell)?.imageView.image == UIImage(systemName: "photo.on.rectangle.angled")})
    for indexPath in notLoaded {
      if let url = URL(string: viewModel.images[indexPath.row].urls.regular) {
        fetchImage(indexPath: indexPath, url: url)
      }
    }
  }
}

// Extension to provide utility method for generating index paths
extension UICollectionView {
  // Generate array of index paths from given range and section
  func indexPaths(from range: ClosedRange<Int>, inSection section: Int = 0) -> [IndexPath] {
    return range.map { IndexPath(item: $0, section: section) }
  }
}


// UICollectionViewFlowLayout subclass to achieve dynamic cell sizing
class DynamicFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
      // Calculate item size based on available width and number of columns
      
        guard let collectionView = collectionView else { return }        
        let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing * (numberOfColumns - 1)
        let itemWidth = availableWidth / numberOfColumns
        itemSize = CGSize(width: itemWidth, height: itemWidth) // Square cells
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true // Invalidate layout on bounds change (e.g., device rotation)
    }
}
