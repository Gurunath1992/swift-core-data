//
//  ViewController.swift
//  SwiftCoreData
//
//  Created by Gurunath Sripad on 4/7/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView : UITableView!
    
    var items:[Person]?
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchPeople()
        relationshipDemo()
    }
    
    func relationshipDemo() {
        
        let family = Family(context:self.context)
        family.name = "ABC"
        let person = Person(context: self.context)
        person.name = "Maggie"
        person.family = family
        
        let person2 = Person(context:self.context)
        person.name = " top ramen"
        family.addToPeople(person2)
        do {
            try self.context.save()
        } catch {
            print(error)
        }
    }
    
    func fetchPeople() {
        do {
            let request = Person.fetchRequest()
            let predicate = NSPredicate.init(format: "name CONTAINS %@","hi")
            let sortDescriptor = NSSortDescriptor.init(key:"name", ascending:true)
            request.sortDescriptors = [sortDescriptor]
            request.predicate = predicate
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error)
        }

    }
    
    @IBAction func addPerson(_ sender: Any) {
        let alertController = UIAlertController.init(title:"Add", message:"Enter name",preferredStyle:.alert)
        alertController.addTextField(configurationHandler:nil)
        let alertAction = UIAlertAction.init(title:"Add", style: .default) { _ in
            let textField = alertController.textFields![0]
            let newPerson = Person(context:self.context)
            newPerson.name = textField.text
            newPerson.age = 40
            newPerson.gender = "MALE"
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            self.fetchPeople()
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = self.items![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier:"PersonCell")!
        cell.textLabel!.text = person.name
        return cell
    }
}

extension ViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("hi")
//    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath) {
        let person = self.items![indexPath.row]
        let alertController = UIAlertController.init(title:"Edit", message: "Change name", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.text = person.name
        })
        let action = UIAlertAction.init(title:"edit", style: .default) { _ in
            let textField = alertController.textFields![0]
            person.name = textField.text
            do {
                try self.context.save()
            }
            catch {
                print(error)
            }
            self.fetchPeople()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView( _ tableView:UITableView, trailingSwipeActionsConfigurationForRowAt indexPath:IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style:.destructive, title:"Delete") { (action, view, completionHandler) in
            let person = self.items![indexPath.row]
            self.context.delete(person)
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            self.fetchPeople()
        }
        return UISwipeActionsConfiguration.init(actions: [action])
    }
}

