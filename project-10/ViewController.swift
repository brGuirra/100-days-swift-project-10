//
//  ViewController.swift
//  project-10
//
//  Created by Bruno Guirra on 18/02/22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell.")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let person = people[index]
        
        let ac = UIAlertController(title: "Edit person", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renamePerson(person)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePerson(index: index)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            configurePopover(popoverController: popoverController)
        }
        
        present(ac, animated: true)
    }
    
    @objc func addNewPerson() {
        let ac = UIAlertController(title: "Add picture", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Choose from your library", style: .default) { [weak self] _ in
            self?.pickPhoto(useCamera: false)
        })
        
        ac.addAction(UIAlertAction(title: "Take a photo", style: .default) { [weak self] _ in
            self?.pickPhoto(useCamera: true)
        })
        
        if let popoverController = ac.popoverPresentationController {
            configurePopover(popoverController: popoverController)
        }
        
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let isSourceTypeAvailable = UIImagePickerController.isSourceTypeAvailable(picker.sourceType)
        
        if isSourceTypeAvailable {
            guard let image = info[.editedImage] as? UIImage else { return }
            
            let imageName = UUID().uuidString
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            
            // Writes the image data to disk
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
            
            let person = Person(name: "Unkown", image: imageName)
            people.append(person)
            
            collectionView.reloadData()
            
            dismiss(animated: true)
        }
    }
    
    // Get the Documents directory path
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func renamePerson(_ person: Person) {
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        
        // Capitalize the firs letter on the text field
        ac.addTextField { textField in
            textField.autocapitalizationType = .words
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            
            person.name = newName
            
            self?.collectionView.reloadData()
        })
        
        if let popoverController = ac.popoverPresentationController {
            configurePopover(popoverController: popoverController)
        }
        
        present(ac, animated: true)
}
    
    func deletePerson(index: Int) {
        people.remove(at: index)
        collectionView.reloadData()
    }
    
    func configurePopover(popoverController: UIPopoverPresentationController) {
        popoverController.sourceView = self.view
        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        // Remove the arrow of the popover to center
        // its content on the view
        popoverController.permittedArrowDirections = []
    }
    
    func pickPhoto(useCamera: Bool) {
        let picker = UIImagePickerController()
        // Allows user to cropt the picture they select
        picker.allowsEditing = true
        picker.delegate = self
        
        if useCamera {
            picker.sourceType = .camera
        }
        
        present(picker, animated: true)
    }
}

