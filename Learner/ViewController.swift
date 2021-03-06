    //
//  ViewController.swift
//  Learner
//
//  Created by Andrew Amos on 7/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var managedContext: NSManagedObjectContext!
 //   var currentQuestions = [NSManagedObject]()
    var currentQuestion: Questions!
    var questionPicture: Bool = false
    
    lazy var earliestActiveQuestionPredicate: NSPredicate = {
        var predicate = NSPredicate(format: "current = YES AND lastanswered<= %@", NSDate(timeIntervalSinceNow: -3600))
        return predicate
        
    }()
    
    lazy var inactiveQuestionPredicate: NSPredicate = {
        var predicate = NSPredicate(format: "current = NO")
        return predicate
        
    }()

    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let app = UIApplication.sharedApplication()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: app)
        
        self.updateCurrentQuestion()
        self.setQuestion()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationWillEnterForeground(sender: AnyObject) {        
        self.updateCurrentQuestion()
        self.setQuestion()
    }
    
    func questionAnswered(notification: NSNotification) {
        self.updateCurrentQuestion()
        self.setQuestion()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let aSelector : Selector = "toggleAnswer:"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        let bSelector : Selector = "askDeleteQuestion:"
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: bSelector)
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        
        let cSelector : Selector = "displayAnswer:"
        let twoTapGesture = UITapGestureRecognizer(target: self, action: cSelector)
        twoTapGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoTapGesture)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "addQuestion:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        //let NewQuestionTriggered = NSNotification(name: "newQuestionTriggered", object: "object")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "questionAnswered:", name: "questionAnswered", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Documents directory
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        return documentsFolderPath
    }
    
    // File in Documents directory
    func fileInDocumentsDirectory(filename: String) -> String {
        return documentsDirectory().stringByAppendingPathComponent(filename)
    }
    
    func toggleAnswer(sender: AnyObject) {
        if currentQuestion.aPictureName != nil {
            if !currentQuestion.aPictureName!.isEmpty {
                questionImageView.image = UIImage(named: currentQuestion.aPictureName!)
                questionImageView.hidden = !questionImageView.hidden
            }
        }
        if currentQuestion.answer != nil {
            if !currentQuestion.answer!.isEmpty {
                if answerLabel.text == "" {
                    answerLabel.text = currentQuestion.answer!
                    answerLabel.hidden = false
                } else {
                    answerLabel.text = ""
                    answerLabel.hidden = true
                }
            }
        }
    }
    
    func setQuestion() {
        answerLabel.text = ""
        questionLabel.text = ""
        
        if currentQuestion.question != nil {
            if !currentQuestion.question!.isEmpty {
                questionLabel.text = currentQuestion.question!
            }
        }
        
        questionImageView.image = nil
        questionImageView.hidden = true
        if currentQuestion.qPictureName != nil {
            if !currentQuestion.qPictureName!.isEmpty {
                questionImageView.hidden = false
                questionImageView.image = UIImage(named: currentQuestion.qPictureName!)
                print(currentQuestion.qPictureName!)
            }
        }
    
        if currentQuestion.aPictureName != nil {
            if !currentQuestion.aPictureName!.isEmpty {
                questionImageView.hidden = true
                questionImageView.image = UIImage(contentsOfFile: fileInDocumentsDirectory(currentQuestion.aPictureName!))
            }
        }
    }
  
    func updateCurrentQuestion() {
        var questions = [Questions]()
        let request = NSFetchRequest(entityName: "Questions")
        request.predicate = earliestActiveQuestionPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "nextdue", ascending: true)]
        do {
            questions = try managedContext.executeFetchRequest(request) as! [Questions]
        } catch _ as NSError {
            print("getRequest error")
        }
        print(questions[0].question)
        currentQuestion = questions[0]
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                self.recordAnswer(false)
            case UISwipeGestureRecognizerDirection.Down:
                self.recordAnswer(true)
            default:
                break
            }
        }
    }
    
    func addToAnswerLog(correct: Bool) {
        let entity = NSEntityDescription.entityForName("AnswerLog", inManagedObjectContext: managedContext)
        let answerLog = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        answerLog.setValue(currentQuestion.qid, forKey: "qid")
        answerLog.setValue(NSDate(), forKey: "dateanswered")
        answerLog.setValue(correct, forKey: "accuracy")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't save \(error), \(error.userInfo)")
        }
    }
    
    func changeNextDue(nextDue: NSDate) {
        do {
            currentQuestion.nextdue = nextDue
            currentQuestion.lastanswered = NSDate()
            try managedContext.save()
        } catch _ as NSError {
            print("getRequest error")
        }
    }
    
    func askDeleteQuestion(sender: AnyObject) {
        let alertController = UIAlertController(title: "Delete Question", message: "Are you sure you want to delete this question?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print(action)
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Delete question", style: .Destructive) { (action) in
            self.deleteQuestion()
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    func deleteQuestion()
    {
        let request = NSFetchRequest(entityName: "Questions")
        request.predicate =  NSPredicate(format: "qid=%@", currentQuestion.qid!)
        do {
            var questions = [NSManagedObject]()
            questions = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
            let questionToDelete = questions[0] as NSManagedObject
            managedContext.deleteObject(questionToDelete)
            try managedContext.save()
        } catch _ as NSError {
            print("deleteQuestion error")
        }
        self.updateCurrentQuestion()
        self.setQuestion()
    }
    
    func triggerNewQuestion()
    {
        var questions = [Questions]()
        let request = NSFetchRequest(entityName: "Questions")
        request.predicate = inactiveQuestionPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "qid", ascending: false)]
        do {
            questions = try managedContext.executeFetchRequest(request) as! [Questions]
            if questions.isEmpty {
                self.updateCurrentQuestion()
            } else {
                currentQuestion = questions[0]
                currentQuestion.current = true
                currentQuestion.nextdue = NSDate()
                currentQuestion.lastanswered = NSDate()
            }
            self.setQuestion()
        } catch _ as NSError {
            print("getRequest error")
        }
    }
    
    func recordAnswer(accuracy: Bool) {
        answerLabel.hidden = true
        let correctionConstant = currentQuestion.correction ?? 0.0  // "Nil coalescing operator" assigns the left hand side if the conditional is not nil, or the right hand side
        var dateLatency: NSTimeInterval = currentQuestion.nextdue!.timeIntervalSinceNow
        
        if let dateTime = currentQuestion.lastanswered?.timeIntervalSinceNow {
            if accuracy {
                changeNextDue(NSDate(timeIntervalSinceNow:fmax((2.0-correctionConstant.doubleValue), 1.1) *  fabs(dateTime)))
            } else {
                changeNextDue(NSDate(timeIntervalSinceNow:fabs(dateTime)*0.1))
            }
        } else {
            changeNextDue(NSDate(timeIntervalSinceNow: 600))
        }
        
        do {
            if !accuracy {
                currentQuestion.correction = NSNumber(double: (currentQuestion.correction?.doubleValue)! + 0.04)
            }
        }
        
        self.addToAnswerLog(accuracy)
        
        if dateLatency < -18000 {
            dateLatency = 300.0
        } else if dateLatency < 0 {
            dateLatency = 600 + dateLatency/60
        } else if dateLatency < 12 {
            dateLatency = 600 + dateLatency
        } else {
            dateLatency = 1800
            triggerNewQuestion()
        }
        scheduleLocal(self, timeToSend: dateLatency)
        self.updateCurrentQuestion()
        setQuestion()
    }
    
    func scheduleLocal(sender: AnyObject, timeToSend: NSTimeInterval) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: timeToSend)
        notification.alertBody = "Answer question"
        notification.alertAction = "Answer question"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func addQuestion(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController = storyboard.instantiateViewControllerWithIdentifier("AddQuestionViewController") as! AddQuestionViewController
        contentViewController.managedContext = self.managedContext
        
        contentViewController.modalPresentationStyle = UIModalPresentationStyle.Popover // 2
        let detailPopover: UIPopoverPresentationController = contentViewController.popoverPresentationController!
        
        detailPopover.sourceView = answerLabel
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
        detailPopover.delegate = self
        presentViewController(contentViewController, animated: true, completion:nil) // 4
    }
    
    func displayAnswer(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController = storyboard.instantiateViewControllerWithIdentifier("ModalController") as! ModalController
        
        contentViewController.modalPresentationStyle = UIModalPresentationStyle.Popover // 2
        contentViewController.answerText = answerLabel.text!
        let detailPopover: UIPopoverPresentationController = contentViewController.popoverPresentationController!
        
        detailPopover.sourceView = questionLabel
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Any
        detailPopover.delegate = self
        presentViewController(contentViewController, animated: true, completion:nil) // 4
    }
    
    // #pragma mark - UIAdaptivePresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController( controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        
        return navController
    }
}

