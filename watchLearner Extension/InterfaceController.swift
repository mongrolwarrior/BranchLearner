//
//  InterfaceController.swift
//  watchLearner Extension
//
//  Created by Andrew Amos on 9/11/2015.
//  Copyright © 2015 slylie. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var answerIsHidden = true
    var session: WCSession!
    var currentQid: NSNumber?
    var soundToPlay: String?
    
    @IBOutlet var showAnswerButton: WKInterfaceButton!
    @IBOutlet var questionLabel: WKInterfaceLabel!
    @IBOutlet var answerLabel: WKInterfaceLabel!
    @IBOutlet var questionImage: WKInterfaceImage!
    @IBOutlet var answerImage: WKInterfaceImage!
    
    @IBOutlet var nextDueDate: WKInterfaceLabel!
    @IBOutlet var nextDueTimer: WKInterfaceTimer!
    
    @IBOutlet var lastAnsweredLabel: WKInterfaceLabel!
    @IBOutlet var nextDueLabel: WKInterfaceLabel!
    @IBOutlet var playSoundButton: WKInterfaceButton!
    
    var player: WKAudioFilePlayer!
    
    func sendAnswerToiPhone(accuracy: Bool) {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        var answerData: [String: AnyObject] = ["messageType": "sendAnswer"]
        answerData["accuracy"] = accuracy
        
        if self.currentQid != nil {
            answerData["qid"] = currentQid
        }

        session.sendMessage(answerData, replyHandler: {(reply: [String : AnyObject]) -> Void in
            if let nextDue = reply["nextdue"] as? String
            {
                self.setNextDueDisplay(nextDue)
            }
            }, errorHandler:
            {
                (error ) -> Void in
                // catch any errors here
            }
        )
        getQuestionFromiPhone()
    }
    
    @IBAction func playSound() {
        if soundToPlay != nil {
            let myBundle = NSBundle.mainBundle()
            var soundMinusMP3 = soundToPlay!
            let stringRange = soundMinusMP3.startIndex.advancedBy(soundMinusMP3.characters.count - 4)..<soundMinusMP3.endIndex
            soundMinusMP3.removeRange(stringRange)
            let soundFile = myBundle.URLForResource(soundMinusMP3, withExtension: "mp3")
            print(soundMinusMP3)
            
            let options: [NSObject: AnyObject] = [WKMediaPlayerControllerOptionsAutoplayKey : true]
            presentMediaPlayerControllerWithURL(soundFile!, options: options) { (didEndPlay: Bool, endTime: NSTimeInterval, error: NSError?) -> Void in
            }
        }
    }
    
    @IBAction func onCorrectAnswer() {
        answerLabel.setHidden(true)
        sendAnswerToiPhone(true)
    }
    
    @IBAction func onIncorrectAnswer() {
        answerLabel.setHidden(true)
        sendAnswerToiPhone(false)
    }
    
    @IBAction func showAnswerButtonAction() {
        if answerIsHidden {
            showAnswerButton.setTitle("Show Question")
            answerLabel.setHidden(false)
            answerImage.setHidden(false)
        } else {
            showAnswerButton.setTitle("Show Answer")
            answerLabel.setHidden(true)
            answerImage.setHidden(true)
        }
        answerIsHidden = !answerIsHidden
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    func getQuestionFromiPhone() {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if WCSession.defaultSession().reachable {
            let applicationData = ["messageType": "getQuestion"]
            WCSession.defaultSession().sendMessage(applicationData, replyHandler: {(reply: [String : AnyObject]) -> Void in
                if let question = reply["question"] as? String,
                    let answer = reply["answer"] as? String,
                    let qImage = reply["qImage"] as? String,
                    let aImage = reply["aImage"] as? String,
                    let lastAnsweredText = reply["lastanswered"] as? String,
                    let nextDueText = reply["nextdue"] as? String,
                    let qid = reply["qid"] as? NSNumber,
                    let aSound = reply["asound"] as? String,
                    let qSound = reply["qsound"] as? String
                {
                    if  !aSound.isEmpty {
                        self.soundToPlay = aSound
                        
                    }
                    if !qSound.isEmpty {
                        self.soundToPlay = qSound
                    }
                    if reply["qid"] != nil {
                        if (self.currentQid == nil || !(self.currentQid!.intValue == qid.intValue)) {
                            self.setDisplay(question, answer: answer, qImage: qImage, aImage: aImage, lastAnswered: lastAnsweredText, nextDue: nextDueText, qSound: qSound, aSound: aSound)
                            self.currentQid = qid
                        }
                    }
                }
                }, errorHandler:
                {
                    (error ) -> Void in
                    // catch any errors here
                }
            )
        } else {
            self.getQuestionFromiPhone()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.getQuestionFromiPhone()
    }
    
    func setDisplay(question: String, answer: String, qImage: String, aImage: String, lastAnswered: String, nextDue: String, qSound: String, aSound: String) {
        questionImage.setImage(nil)
        questionImage.setHidden(true)
        answerImage.setImage(nil)
        answerImage.setHidden(true)
        playSoundButton.setHidden(true)
        answerLabel.setText("")
        if !question.isEmpty {
            self.questionLabel.setHidden(false)
            self.questionLabel.setText(question)
        } else {
            self.questionLabel.setHidden(true)
        }
        if !answer.isEmpty {
            self.answerLabel.setText(answer)
        }
        if !qImage.isEmpty {
            var qImageNew = qImage.stringByReplacingOccurrencesOfString(".svg", withString: "")
            qImageNew = qImageNew.stringByReplacingOccurrencesOfString(".gif", withString: "")
            questionImage.setImageNamed(qImageNew)
            questionImage.setHidden(false)
        }
        if !aImage.isEmpty {
            var aImageNew = aImage.stringByReplacingOccurrencesOfString(".svg", withString: "")
            aImageNew = aImageNew.stringByReplacingOccurrencesOfString(".gif", withString: "")
            answerImage.setImageNamed(aImageNew)
            answerImage.setHidden(true)
        }
        if !lastAnswered.isEmpty {
            lastAnsweredLabel.setText(lastAnswered)
        }
        if !nextDue.isEmpty {
            nextDueLabel.setText(nextDue)
        }
        if !qSound.isEmpty {
            playSoundButton.setHidden(false)
            soundToPlay = qSound
        }
        if !aSound.isEmpty {
            playSoundButton.setHidden(false)
            soundToPlay = aSound
        }
        self.answerLabel.setHidden(true)
        answerIsHidden = true
    }
    
    func setNextDueDisplay(nextDue: String) {
        self.nextDueDate.setHidden(false)
        self.nextDueDate.setText(nextDue)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
