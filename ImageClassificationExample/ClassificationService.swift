//
//  ClassificationService.swift
//  ImageClassificationExample
//
//  Created by Hoye Lam on 14/09/2022.
//

import Foundation
import Vision
import UIKit

protocol ClassificationServiceProviding {
    var classificationsResultPub: Published<String>.Publisher { get }
    func updateClassifications(for image: UIImage)
}

final class ClassificationService: ClassificationServiceProviding {
    
    @Published private var classifications: String = ""
    var classificationsResultPub: Published<String>.Publisher { $classifications }
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    
    // MARK: - Image Classification
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        /// Clear old classifications
        self.classifications = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the variable with the results of the classification.
    /// - Tag: ProcessClassifications
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                // do nothing
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(5)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "(%.2f) %@\n", classification.confidence, classification.identifier)
                }
                
                self.classifications = descriptions.joined(separator: " ")
            }
        }
    }
}


///
/// https://developer.apple.com/documentation/imageio/cgimagepropertyorientation
///
extension CGImagePropertyOrientation {
    /**
     Converts a `UIImageOrientation` to a corresponding
     `CGImagePropertyOrientation`. The cases for each
     orientation are represented by different raw values.
     
     - Tag: ConvertOrientation
     */
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

