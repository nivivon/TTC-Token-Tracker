//
//  SetupViewController.swift
//  TTC Token Tracker
//
//  Created by Niv Yahel on 2014-09-24.
//  Copyright (c) 2014 Niv Yahel. All rights reserved.
//

import UIKit
import MapKit

class SetupViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet var questionsContainer : UIView!
    @IBOutlet var questionLabelScroller: UIScrollView!
    @IBOutlet var currentQuestionScroller: UIScrollView!
    @IBOutlet var progressLineView : UIView!
    @IBOutlet var questionNumberView: UIView!
    @IBOutlet var totalQuestionsLabel: UILabel!
    @IBOutlet var answerTextField: UITextField!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var finishedButton: UIButton!
    
    let textFieldQuestions:[(key: String, question: String)] = [("name","What is your name?"), ("tokens","How many tokens?")]
    let mapQuestions:[(key: String, question: String)] = [("home","What is your home address?"), ("work","What is your work address?")]
    var questions:[(key: String, question: String)] = []
    
    var currentQuestion: Int = 0
    var MAP_QUESTIONS_INDEX: Int = 0
    
    enum ScrollerType {
        case LABELS
        case INDICATORS
    }
    
    func updateTotalQuestionsLabel() {
        totalQuestionsLabel.text = String(questions.count)
    }
    
    func setupScroller(TYPE: ScrollerType) {
        var y : Float = 0.0
        var scroller: UIScrollView
        switch TYPE {
            case ScrollerType.LABELS:
                scroller = questionLabelScroller
            case ScrollerType.INDICATORS:
                scroller = currentQuestionScroller
        }
        let labelSize: CGSize = scroller.frame.size
        let ZERO_OFFSET = 1
        for var i = 0; i < questions.count; i++ {
            let newLabel = UILabel(frame: CGRect(x: 0, y: Double(y), width: Double(labelSize.width), height: Double(labelSize.height)))
            y += Float(labelSize.height)
            var newText: String
            switch TYPE {
                case ScrollerType.LABELS:
                    newText = questions[i].question
                case ScrollerType.INDICATORS:
                    newText = String(i + ZERO_OFFSET)
            }
            newLabel.text = newText
            scroller.addSubview(newLabel)
        }
        let scrollViewWidth: Float = Float(labelSize.width)
        let scrollViewHeight: Float = y + Float(labelSize.height)
        let scrollViewSize: CGSize = CGSizeMake(CGFloat(scrollViewWidth),CGFloat(scrollViewHeight))
        scroller.contentSize = scrollViewSize
    }
    
    func setupQuestionsUIElements() {
        updateTotalQuestionsLabel()
        setupScroller(ScrollerType.LABELS)
        setupScroller(ScrollerType.INDICATORS)
    }
    
    func saveCurrentAnswer(currentQuestion: Int, currentAnswer: String) {
        if (currentQuestion <= MAP_QUESTIONS_INDEX) {
            let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let ZERO_OFFSET: Int = 1
            userDefaults.setObject(currentAnswer, forKey: questions[(currentQuestion-ZERO_OFFSET)].key)
            userDefaults.synchronize()
        }
    }
    
    func saveCoordinate(currentQuestion: Int, coordinate: CLLocationCoordinate2D) {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var identifier: String = ""
        if (currentQuestion == MAP_QUESTIONS_INDEX + 1) {
            identifier = "home"
        }
        else {
            identifier = "work"
        }
        
        var storedDict: NSDictionary = ["latitude": coordinate.latitude,
                            "longitude": coordinate.longitude] as NSDictionary
        userDefaults.setObject(storedDict, forKey: identifier)
        userDefaults.synchronize()
    }
    
    func moveScroller(TYPE: ScrollerType, questionNumber: Int) {
        var scroller: UIScrollView
        switch TYPE {
            case ScrollerType.LABELS:
                scroller = questionLabelScroller
            case ScrollerType.INDICATORS:
                scroller = currentQuestionScroller
        }
        let viewSize: CGSize = scroller.frame.size
        let newY : Float = Float(viewSize.height) * Float(questionNumber)
        scroller.scrollRectToVisible(CGRect(x: 0.0, y: Double(newY), width: Double(viewSize.width), height: Double(viewSize.height)), animated: true)
    }
    
    func fadeOutTextField() {
        UIView.animateWithDuration(0.5, animations: {
            self.answerTextField.alpha = 0
        })
    }
    
    func fadeOutQuestionsContainer() {
        UIView.animateWithDuration(0.5, animations: {
            self.questionsContainer.alpha = 0
        })
    }
    
    func moveQuestionNumberViewDown() {
        let IPHONE_HEIGHT: Int = 568
        let KEYBOARD_HEIGHT: Int = 216
        let DESIRED_PADDING: Int = 4
        let newY: Int = IPHONE_HEIGHT - Int(questionNumberView.frame.height) - DESIRED_PADDING - KEYBOARD_HEIGHT
        UIView.animateWithDuration(0.5, animations: {
            var newQuestionNumberViewFrame: CGRect = self.questionNumberView.frame
            newQuestionNumberViewFrame.origin.y = CGFloat(newY)
            self.questionNumberView.frame = newQuestionNumberViewFrame
        })
    }
    
    func showMap() {
        let zoomLevel: CLLocationDegrees = 0.005
        UIView.animateWithDuration(0.5, animations: {
            self.mapView.alpha = 1
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "SetupToPortal") {
            let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "setup")
            userDefaults.synchronize()
        }
    }
    
    func promptToFinish() {
        UIView.animateWithDuration(0.5, animations: {
            self.finishedButton.alpha = 1
        })
    }
    
    @IBAction func showFinish() {
        fadeOutQuestionsContainer()
        self.performSegueWithIdentifier("SetupToPortal", sender: self)
    }
    
    func updateIndicator(questionNumber: Int) {
        let indicatorContainer: UIView! = progressLineView.superview
        let maxWidth: Float = Float(indicatorContainer.frame.size.width)
        UIView.animateWithDuration(0.5, animations: {
            if (self.currentQuestion == 1) {
                self.progressLineView.alpha = 1
            }
            var newIndicatorFrame: CGRect = self.progressLineView.frame
            var progressPercentage: Float = Float(self.currentQuestion) / Float(self.questions.count)
            var newWidth: Float = progressPercentage * maxWidth
            newIndicatorFrame.size.width = CGFloat(newWidth)
            self.progressLineView.frame = newIndicatorFrame
            if (questionNumber == self.MAP_QUESTIONS_INDEX) {
                self.moveQuestionNumberViewDown()
            }
            
        }, completion: { finished in
            if (questionNumber == self.MAP_QUESTIONS_INDEX) {
                self.showMap()
            }
            if (questionNumber == self.questions.count) {
                self.promptToFinish()
            }
        })
    }
    
    func scrollToQuestion(questionNumber: Int) {
        if (questionNumber < questions.count) {
            moveScroller(ScrollerType.LABELS, questionNumber: questionNumber)
            moveScroller(ScrollerType.INDICATORS, questionNumber: questionNumber)
        }
        updateIndicator(questionNumber)
    }
    
    func addLocationAnnotationToMap(locationItem: MKMapItem) {
        let locationCoordinate: CLLocationCoordinate2D = locationItem.placemark.location.coordinate
        let locationAnnotation: MKPointAnnotation = MKPointAnnotation()
        locationAnnotation.coordinate = locationCoordinate
        locationAnnotation.title = locationItem.name
        self.mapView.addAnnotation(locationAnnotation)
        let insets: CGFloat = 10.0
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    func showAnswerOnMapAndSave(currentAnswer: String) {
        var mapSearchRequest: MKLocalSearchRequest = MKLocalSearchRequest()
        mapSearchRequest.naturalLanguageQuery = currentAnswer
        mapSearchRequest.region = mapView.region
        
        let mapSearch: MKLocalSearch = MKLocalSearch(request: mapSearchRequest)
        mapSearch.startWithCompletionHandler({ (response: MKLocalSearchResponse!, error: NSError!) in
            if (error != nil) {
                NSLog("search error: %@",error)
            }
            
            if (response.mapItems.count == 0) {
                NSLog("No results")
            }
            else {
                let locationItem: MKMapItem = response.mapItems[0] as MKMapItem
                self.addLocationAnnotationToMap(locationItem)
                self.saveCoordinate(self.currentQuestion, coordinate: locationItem.placemark.location.coordinate)
                
            }
        })
    }
    
    func clearAnswerTextField() {
        answerTextField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (currentQuestion < questions.count) {
            currentQuestion++
            let currentAnswer: String = textField.text
            if (currentQuestion > MAP_QUESTIONS_INDEX) {
                showAnswerOnMapAndSave(currentAnswer)
            }
            else {
                saveCurrentAnswer(currentQuestion, currentAnswer: currentAnswer)
            }
            clearAnswerTextField()
            scrollToQuestion(currentQuestion)
            if (currentQuestion == questions.count) {
                textField.resignFirstResponder()
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questions = textFieldQuestions + mapQuestions
        MAP_QUESTIONS_INDEX = textFieldQuestions.count
        setupQuestionsUIElements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

