//
//  ContentViewModel.swift
//  ImageClassificationExample
//
//  Created by Hoye Lam on 14/09/2022.
//

import Combine
import UIKit

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var displayImagePicker: Bool = false
    
    @Published var importedImage: UIImage? = nil
    
    @Published var classifications: String = ""
    
    let service: ClassificationServiceProviding
    
    private var subscribers: [AnyCancellable] = []
    
    init(
        image: UIImage? = nil,
        service: ClassificationServiceProviding = ClassificationService()
    ) {
        self.importedImage = image
        self.service = service
        
        self.subscribe()
        self.onChangeImage()
    }
    
    func subscribe() {
        self.service.classificationsResultPub
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newClassifications in
                self?.classifications = newClassifications
            }
            .store(in: &subscribers)
    }
    
    func onChangeImage() {
        guard let image = importedImage else { return }
        service.updateClassifications(for: image)
    }
}
