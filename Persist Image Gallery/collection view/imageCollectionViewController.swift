//
//  imageCollectionViewController.swift
//  Image Gallery
//
//  Created by Apple Macbook on 17/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class imageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    fileprivate func setSelfAsDelegate() {
        collectionView.dragInteractionEnabled = true
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelfAsDelegate()
        collectionView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinch)))
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
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
                collectionView.collectionViewLayout.invalidateLayout()
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
        dismiss(animated: true){
            self.document?.close()
        }
    }
    var document: ImageGalleryDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open{success in
            if success {
                self.collectionView.performBatchUpdates({
                    self.title = self.document?.localizedName
                    self.imageGallery = self.document?.imageGallery ?? ImageGallery()
                    for i in self.imageGallery.addresses.indices {
                        self.collectionView.insertItems(at: [IndexPath(item: i, section: 0)])
                    }
                })
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
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
        if let image = (collectionView.cellForItem(at: indexPath) as? imageCollectionViewCell)?.imageView.image {
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
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                performLocalDragDrop(collectionView, sourceIndexPath, destinationIndexPath)
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                performExternalDragDrop(coordinator, item, destinationIndexPath)
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
    
    fileprivate func performExternalDragDrop(_ coordinator: UICollectionViewDropCoordinator, _ item: UICollectionViewDropItem, _ destinationIndexPath: IndexPath) {
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
    var cellWidth: CGFloat = 200
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: Consts.imageCellIdentifier, for: indexPath) as! imageCollectionViewCell)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            let oldAdress = self?.imageGallery.addresses[indexPath.item]
            if let data = try? Data(contentsOf: self!.imageGallery.addresses[indexPath.item].url),let image = UIImage(data: data), oldAdress == self?.imageGallery.addresses[indexPath.item]{
                DispatchQueue.main.async {
                    cell.imageView.image = image
                    cell.spinner.stopAnimating()
                }
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

