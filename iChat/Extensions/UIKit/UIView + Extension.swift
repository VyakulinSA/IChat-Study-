//
//  UIView + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 22.02.2021.
//

import Foundation
import UIKit


//P118. создаем расширение для покраски кнопки и смайлика внутри textField
extension UIView {
    
    func applayGradients(cornerRadius: CGFloat) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), endColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = cornerRadius
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        
    }
}
