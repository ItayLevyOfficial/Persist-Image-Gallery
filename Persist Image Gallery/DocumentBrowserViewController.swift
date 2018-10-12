//
//  DocumentBrowserViewController.swift
//  Persist Image Gallery
//
//  Created by Apple Macbook on 10/10/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        //if UIDevice.current.userInterfaceIdiom == .pad {
            // create a blank document in our Application Support directory
            // this template will be copied to Documents directory for new docs
            // see didRequestDocumentCreationWithHandler delegate method
            template = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
                ).appendingPathComponent("Untitled.json")
            // CHANGE MADE AFTER LECTURE 14
            // the above change to the name of our blank template
            // combined with the addition of an emojiart file type
            // in Exported UTIs in Project Settings for Target's Info tab
            // and changing the Document Type in that tab to edu.stanford.cs193p.emojiart
            // makes it so documents can now be opened in our app from the Files app!
            if template != nil {
                // if we can't create the template
                // don't enable the Create Document button in the UI
                allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())
            }
       // }
        //TESTING
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    var template: URL?
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // just call the passed-in handler with our template
        // we .copy it to make new documents
        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        if let imageGalleryVC = documentVC.contents as? imageCollectionViewController {
            imageGalleryVC.document = ImageGalleryDocument(fileURL: documentURL)
        }
        present(documentVC, animated: true)
    }
    var defaultGallery: ImageGallery{
        var ig = ImageGallery()
        let defaultImageURL = URL(string: "https://wallpaperbrowse.com/media/images/IMG_144869.jpg")!.imageURL
        let defaultAddress = Address(aspectRatio: 1,url: defaultImageURL)
        let defaultAddress2 = Address(aspectRatio: 2,url: defaultImageURL)
        ig.addresses = [defaultAddress,defaultAddress2,defaultAddress,defaultAddress2]
        return ig
    }
}

