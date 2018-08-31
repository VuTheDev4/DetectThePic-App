//
//  ViewController.swift
//  DetectThePic
//
//  Created by Vu Duong on 8/31/18.
//  Copyright © 2018 Vu Duong. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var restNetModel = Resnet50()
    var results = [VNClassificationObservation]()
    var pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        pickerController.delegate = self
        
        if let image = imageView.image{
            processPicture(image: image)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processPicture(image: image)
        }
        pickerController.dismiss(animated: true, completion: nil)
    }
    
    func processPicture(image: UIImage) {
        if let model = try? VNCoreMLModel(for: restNetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let results = request.results as? [VNClassificationObservation] {
                    //show amount of results
                    self.results = Array(results.prefix(10))
                    self.tableView.reloadData()
//                    for result in results {
////                        print("egg : 14.27%")
//                        print("\(result.identifier): \(result.confidence * 50)%")
//                    }
                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        let name = result.identifier.prefix(20)
        
        cell.textLabel?.text = "\(name): \(Int(result.confidence * 100))%"
        return cell
        
    }
 
    @IBAction func galleryBtnPressed(_ sender: Any) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
}

