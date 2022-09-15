//
//  ContentView.swift
//  ImageClassificationExample
//
//  Created by Hoye Lam on 14/09/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            if let image = viewModel.importedImage {
                VStack(alignment: .leading) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .padding()
                        .onTapGesture {
                            viewModel.displayImagePicker.toggle()
                        }
                        
                    ScrollView {
                        Text(viewModel.classifications)
                            .bold()
                            .padding()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "photo.fill")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    
                    Button {
                        viewModel.displayImagePicker.toggle()
                    } label: {
                        Text("Pick an image")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding()
            }
        }
        .onChange(of: viewModel.importedImage) { _ in viewModel.onChangeImage() }
        .sheet(isPresented: $viewModel.displayImagePicker) {
            ImagePicker(image: $viewModel.importedImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            
            ContentView(
                viewModel:
                    ContentViewModel(
                        image: UIImage(named: "PhotoPlaceholder")!
                    )
            )
        }
    }
}
