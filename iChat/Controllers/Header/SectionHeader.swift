//
//  SectionHeader.swift
//  iChat
//
//  Created by Вякулин Сергей on 16.02.2021.
//

import Foundation
import UIKit

//P84. Создади кастомный UICollectionReusableView для заголовка
class SectionHeader: UICollectionReusableView {
    static let reuseId = "SectionHeader"
    
    let title = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        title.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.topAnchor.constraint(equalTo: self.topAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(text: String, font: UIFont?, textColor: UIColor) {
        title.textColor = textColor
        title.font = font
        title.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
