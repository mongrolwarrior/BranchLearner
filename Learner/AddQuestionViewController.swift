//
//  AddQuestionViewController.swift
//  Learner
//
//  Created by Andrew Amos on 15/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddQuestionViewController: UIViewController {
    
    @IBOutlet weak var questionTV: UITextView!
    var managedContext: NSManagedObjectContext!
    @IBOutlet weak var answerTV: UITextView!
    @IBOutlet weak var qImageTF: UITextField!
    @IBOutlet weak var aImageTF: UITextField!
    @IBOutlet weak var qSoundTF: UITextField!
    @IBOutlet weak var aSoundTF: UITextField!
    
    @IBAction func addQuestion(sender: AnyObject) {
        let idRequest = NSFetchRequest(entityName: "Questions")
        let idSortDescriptor = NSSortDescriptor(key: "qid", ascending: false)
        idRequest.sortDescriptors = [idSortDescriptor]
        
        var newID = 0
        
        do {
            let questions = try managedContext.executeFetchRequest(idRequest) as! [Questions]
            if !questions.isEmpty {
                if !(questions[0].qid == nil) {
                    newID = questions[0].qid!.integerValue + 1
                }
            }
        } catch _ as NSError {
            print("getRequest error")
        }
        
        
        
        let entity = NSEntityDescription.entityForName("Questions", inManagedObjectContext: managedContext)
        let questionToAdd = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        if !questionTV.text.isEmpty {
            questionToAdd.setValue(questionTV.text, forKey: "question")
        }
        if !answerTV.text.isEmpty {
            questionToAdd.setValue(answerTV.text, forKey: "answer")
        }
        questionToAdd.setValue(newID, forKey: "qid")
        questionToAdd.setValue(0, forKey: "current")
        questionToAdd.setValue(NSDate(), forKey: "datecreated")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't save \(error), \(error.userInfo)")
        }

    }
    
    @IBAction func cancelQuestion(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
/*

@NSManaged var answer: String?
@NSManaged var aPicture: NSData?
@NSManaged var aPictureName: String?
@NSManaged var aSound: String?
@NSManaged var correction: NSNumber?
@NSManaged var current: NSNumber?
@NSManaged var datecreated: NSDate?
@NSManaged var lastanswered: NSDate?
@NSManaged var nextdue: NSDate?
@NSManaged var qid: NSNumber?
@NSManaged var qPicture: NSData?
@NSManaged var qPictureName: String?
@NSManaged var qSound: String?
@NSManaged var question: String?
*/