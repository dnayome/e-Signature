//
//  ViewController.swift
//  Signature
//
//  Created by nayome.devapriya on 10/06/17.
//  Copyright © 2017 Exilant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var lastPoint = CGPoint()
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, brush: CGFloat = 10.0, opacity: CGFloat = 1.0
    var mouseSwiped = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IBActions
    @IBAction func pencilPressed(_ sender: Any) {
        red = 0.0/255.0
        blue = 0.0/255.0
        green = 0.0/255.0
    }

    @IBAction func eraserPressed(_ sender: Any) {
        red = 255.0/255.0
        blue = 255.0/255.0
        green = 255.0/255.0
        
    }
    
    @IBAction func reset(_ sender: Any) {
        self.mainImageView.image = nil
    }
    
    @IBAction func save(_ sender: Any) {
        UIAlertController.notifyUser(Constants.AlertMessage , message: Constants.AlertConfirm, alertButtonTitles: [Constants.ConfirmLabel, Constants.CancelLabel], alertButtonStyles: [.default, .default], vc: self) { (indexOfTappedButton) in
            if (indexOfTappedButton == 0) {
                UIGraphicsBeginImageContextWithOptions(self.mainImageView.bounds.size, false, 0.0)
                self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.mainImageView.frame.size.width, height: self.mainImageView.frame.size.width))
                let saveImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                UIImageWriteToSavedPhotosAlbum(saveImage!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)) , nil)
            }
            
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        guard error == nil else {
            //Error saving image
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseSwiped = false
        let touch: UITouch = touches.first!
        lastPoint = touch.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseSwiped = true
        let touch: UITouch = touches.first!
        let currentPoint: CGPoint = touch.location(in: self.view)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        //Draw a line from previous point to curent point
        context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
        context.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
        context.setLineCap(.round)
        
        //Set brush size, opacity, and color
        context.setLineWidth(brush)
        context.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context.setBlendMode(.normal)
        context.strokePath()

        self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }
            context.setLineCap(.round)
            context.setLineWidth(brush)
            context.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.strokePath()
            context.flush()
            self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
        }
        
        UIGraphicsBeginImageContext(self.mainImageView.frame.size)
        self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height), blendMode: .normal , alpha: 1.0)
        self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height), blendMode: .normal , alpha: opacity)
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.tempImageView.image = nil
        UIGraphicsEndImageContext()
    }
}

extension UIAlertController {
    static func notifyUser(_ title: String, message: String, alertButtonTitles: [String], alertButtonStyles: [UIAlertActionStyle], vc: UIViewController, completion: @escaping (Int)->Void) -> Void
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        for title in alertButtonTitles {
            let actionObj = UIAlertAction(title: title, style: alertButtonStyles[alertButtonTitles.index(of: title)!], handler: { (action) in
                completion(alertButtonTitles.index(of: action.title!)!)
            })
            alert.addAction(actionObj)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}

