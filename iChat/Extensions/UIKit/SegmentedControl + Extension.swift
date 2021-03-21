//
//  SegmentedControl + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 09.02.2021.
//

import Foundation
import  UIKit

extension UISegmentedControl {
    
    convenience init(first: String, second: String){
        self.init()
        self.insertSegment(withTitle: first, at: 0, animated: true)
        self.insertSegment(withTitle: second, at: 1, animated: true)
        self.selectedSegmentIndex = 0 //указываем какой элемент будет автоматически выбран
    }
}
