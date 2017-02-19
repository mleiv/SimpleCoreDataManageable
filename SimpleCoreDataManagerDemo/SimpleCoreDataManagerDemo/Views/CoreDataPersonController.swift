//
//  CoreDataPersonController.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

class CoreDataPersonController: UIViewController {

    var isNew: Bool { return person == nil }
    var person: Person?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var professionField: UITextField!
    @IBOutlet weak var organizationField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSpinner(inView: view)
        deleteButton.isHidden = isNew
        setFieldValues(person: self.person)
        stopSpinner(inView: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func savePerson(_ sender: UIButton) {
        let name = nameField.text ?? "Person"
        startSpinner(inView: view, title: "Saving \(name)")
        if let person = self.person ?? Person.create(),
            nameField?.text?.isEmpty == false {
            _ = person.saveChanges { (person: Person) in
                // perform any changes in correct context
                self.saveFieldValues(person: person)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
                self?.stopSpinner(inView: self?.view)
                _ = self?.navigationController?.popViewController(animated: true)
            }
        } else {
            showMessage("Please enter a name before saving.", handler: { [weak self] _ in
                self?.stopSpinner(inView: self?.view)
            })
        }
    }

    @IBAction func deletePerson(_ sender: UIButton) {
        let name = person?.name ?? "Person"
        startSpinner(inView: view, title: "Deleting \(name)")
        _ = person?.delete()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) { [weak self] in
            self?.stopSpinner(inView: self?.view)
            _ = self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func setFieldValues(person: Person?) {
        nameField.text = person?.name
        professionField.text = person?.profession
        organizationField.text = person?.organization
        notesField.text = person?.notes
    }
    
    func saveFieldValues(person: Person?) {
        person?.name = nameField.text ?? ""
        person?.profession = professionField.text
        person?.organization = organizationField.text
        person?.notes = notesField.text
    }
    
    func showMessage(_ message: String, handler: @escaping ((UIAlertAction) -> Void) = { _ in }) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: handler))
        self.present(alertController, animated: true) {}
    }
}

extension CoreDataPersonController: Spinnerable {}
