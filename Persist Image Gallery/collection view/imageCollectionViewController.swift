//
//  imageCollectionViewController.swift
//  Image Gallery
//
//  Created by Apple Macbook on 17/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class imageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    //MARK: - gestures and loading from document
    
    fileprivate func setSelfAsDelegate() {
        collectionView?.dragInteractionEnabled = true
        collectionView?.dropDelegate = self
        collectionView?.dragDelegate = self
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
    fileprivate func loadDataFromDocument() {
        document?.open{success in
            if success {
                self.collectionView?.performBatchUpdates({
                    self.title = self.document?.localizedName
                    self.imageGallery = self.document?.imageGallery ?? ImageGallery()
                    for i in self.imageGallery.addresses.indices {
                        self.collectionView?.insertItems(at: [IndexPath(item: i, section: 0)])
                    }
                })
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelfAsDelegate()
        if URLCache.shared.memoryCapacity != Consts.cache.memoryCapacity {
            URLCache.shared = Consts.cache
        }
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch)))
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        loadDataFromDocument()
    }
    
    fileprivate func adjustCellWidthToScale(_ pinchRecognizer: UIPinchGestureRecognizer) {
        let newCellWidth = pinchRecognizer.scale*cellWidth
        if newCellWidth < view.bounds.width, newCellWidth > Consts.cellMinWidth {
            cellWidth = newCellWidth
        }
    }
    
    @objc func pinch(sender: Any) {
        if let pinchRecognizer = sender as? UIPinchGestureRecognizer {
            switch pinchRecognizer.state {
            case .changed, .ended, .began:
                adjustCellWidthToScale(pinchRecognizer)
                pinchRecognizer.scale = 1.0
                //resizes the cells
                collectionView?.collectionViewLayout.invalidateLayout()
            default:
                break
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let image = (collectionView.cellForItem(at: indexPath) as! imageCollectionViewCell).imageView.image {
            performSegue(withIdentifier: Consts.segueIdentifier, sender: image)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImageViewController {
            destination.image = sender as! UIImage
        }
    }
    
    //MARK: - Persistence

    @IBAction func close(_ sender: UIBarButtonItem) {
        if imageGallery.addresses.count != 0 {
            self.document?.thumbnail = (collectionView?.cellForItem(at: Consts.originIndexPath) as? imageCollectionViewCell)?.imageView.image
        }
        dismiss(animated: true){
            self.document?.close()
        }
    }
    var document: ImageGalleryDocument?
    
    func save() {
        document?.imageGallery = self.imageGallery
        document?.updateChangeCount(.done)
    }
    
    //MARK: - DRAG
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let image = (collectionView?.cellForItem(at: indexPath) as? imageCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            //dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
    }
    //MARK: - Drop
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return (session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)) ||
        session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? Consts.originIndexPath
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                performLocalDragDrop(collectionView, sourceIndexPath, destinationIndexPath)
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                performExternalDrop(coordinator, item, destinationIndexPath)
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }
    fileprivate func performLocalDragDrop(_ collectionView: UICollectionView, _ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) {
        collectionView.performBatchUpdates({
            let address = imageGallery.addresses.remove(at: sourceIndexPath.item)
            imageGallery.addresses.insert(address, at: destinationIndexPath.item)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        })
    }
    
    fileprivate func showAlert() {
        let alert = UIAlertController(title: "couldn't drop image", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        self.present(alert, animated: true)
    }
    
    fileprivate func performExternalDrop(_ coordinator: UICollectionViewDropCoordinator, _ item: UICollectionViewDropItem, _ destinationIndexPath: IndexPath) {
        //external item has dragged
        let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: Consts.placeHolderCellIdentifier))
        var url: URL?
        var aspectRatio: Double = 1
        
        item.dragItem.itemProvider.loadObject(ofClass: URL.self) {provider, _ in
            url = provider
        }
        item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) {provider, _ in
            DispatchQueue.main.async {
                if let image = provider as? UIImage, let imageUrl = url{
                    aspectRatio = Double(image.size.height / image.size.width)
                    placeHolderContext.commitInsertion(){ insertionIndexPath in
                        self.imageGallery.addresses.insert(Address(aspectRatio: aspectRatio, url: imageUrl) , at: insertionIndexPath.item)
                    }
                } else {
                    placeHolderContext.deletePlaceholder()
                    self.showAlert()
                }
            }
        }
    }
    //MARK: - DATA SOURCE
    var imageGallery: ImageGallery = ImageGallery() {
        didSet{
            save()
        }
    }
    var cellWidth: CGFloat = Consts.cellStartWidth
    fileprivate func setImageViewImage(image: UIImage, forCell cell: imageCollectionViewCell) {
        DispatchQueue.main.async {
            cell.imageView.image = image
            cell.spinner.stopAnimating()
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: Consts.imageCellIdentifier, for: indexPath) as! imageCollectionViewCell)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            let oldAddress = self?.imageGallery.addresses[indexPath.item] //later we make sure the user haven't druged the current cell in                    the meanwhile
            let url: URL = self!.imageGallery.addresses[indexPath.item].url
            let request = URLRequest(url: url)
            if let data = URLCache.shared.cachedResponse(for: request)?.data, let image = UIImage(data: data), oldAddress == self?.imageGallery.addresses[indexPath.item] {
                self?.setImageViewImage(image: image, forCell: cell)
            }
            else if let data = try? Data(contentsOf: url),let image = UIImage(data: data), oldAddress == self?.imageGallery.addresses[indexPath.item]{
                self?.setImageViewImage(image: image, forCell: cell)
                URLCache.shared.storeCachedResponse(CachedURLResponse(response: URLResponse(), data: data), for: request)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.reuseIdentifier == Consts.imageCellIdentifier {
            return CGSize(width: cellWidth, height: cellWidth * CGFloat(imageGallery.addresses[indexPath.item].aspectRatio))
        }
        else {
            return placeHolderCellSize
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.addresses.count
    }
    var placeHolderCellSize: CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

