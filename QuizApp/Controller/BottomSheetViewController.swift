//
//  BottomSheetViewController.swift
//  Convertor_IOS
//
//  Created by Hamza on 19/12/2021.
//

import UIKit

protocol BottomShetProtocol {
    func nextBtnTapped()
}
class BottomSheetViewController: UIViewController {
    

    var bottomShetProtocol:BottomShetProtocol!
    var isCorrect = false
    var correctOptionText:String = ""
    
    @IBOutlet weak var correctOPtionLabel: UILabel!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var roundedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var button:UIButton!
    @IBOutlet weak var safeAreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roundedViewHeight.constant = 0
        correctOPtionLabel.isHidden = true
        
        if isCorrect == false{
            titleLabel.text = "Correct Option:"
            correctOPtionLabel.text = correctOptionText
            correctOPtionLabel.isHidden = false
            titleLabel.textColor = UIColor(named: "wrongBtnColor")!
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            button.backgroundColor = UIColor(named: "wrongBtnColor")!
            correctOPtionLabel.textColor = UIColor(named: "wrongBtnColor")!
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isCorrect == true{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.roundedViewHeight.constant = 120
                self.view.layoutIfNeeded()
            })
            roundedView.backgroundColor = UIColor(named: "correctOptionBackgroundColor")
            safeAreView.backgroundColor = UIColor(named: "correctOptionBackgroundColor")
        }else{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.roundedViewHeight.constant = 140
                self.view.layoutIfNeeded()
            })
            roundedView.backgroundColor = UIColor(named: "wrongOptionBackgroundColor")
            safeAreView.backgroundColor = UIColor(named: "wrongOptionBackgroundColor")
        }
        
        
       
    }
    
    @IBAction func btnTapped(_ sender:UIButton){
        self.dismiss(animated: false, completion: nil)
        bottomShetProtocol.nextBtnTapped()
    }
    
}


extension UIView {
func roundCorners(corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
}
}
