//
//  GradientView.swift
//  iChat
//
//  Created by Вякулин Сергей on 15.02.2021.
//

import Foundation
import UIKit

//P75. Создадим gradientView для красивого цвета
class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    //Скопировал enum из готового проекта, т.к. он нам поможет реализовать различные цвета
    enum Point {
        case topLeading
        case leading
        case bottomLeading
        case top
        case center
        case bottom
        case topTrailing
        case trailing
        case bottomTrailing

        var point: CGPoint {
            switch self {
            case .topLeading:
                return CGPoint(x: 0, y: 0)
            case .leading:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeading:
                return CGPoint(x: 0, y: 1.0)
            case .top:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottom:
                return CGPoint(x: 0.5, y: 1.0)
            case .topTrailing:
                return CGPoint(x: 1.0, y: 0.0)
            case .trailing:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomTrailing:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    
    //Объявляем цвета
    @IBInspectable private var startColor: UIColor? {
        didSet {
            //в дидсет прописываем. что при изменении цвета, вызываем функцию для настройки цветов градиента
            setupGradientColors(startColor: startColor, endColor: endColor)
        }
    }
    
    @IBInspectable private var endColor: UIColor? {
        didSet {
            //в дидсет прописываем. что при изменении цвета, вызываем функцию для настройки цветов градиента
            setupGradientColors(startColor: startColor, endColor: endColor)
        }
    }
    
    //P79. Создадим инициализатор для инициализации через код
    init(from startPoint: Point, to endPoint: Point, startColor: UIColor?, endColor: UIColor?){
        self.init()
        setupGradient(from: startPoint, to: endPoint, startColor: startColor, endColor: endColor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //задаем размеры, чтобы они не были равны 0,а растягивались на всю view
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    
    //P76. Создадим функцию для настрйоки цвета
    private func setupGradient(from startPoint: Point, to endPoint: Point, startColor: UIColor?, endColor: UIColor?){
        self.layer.addSublayer(gradientLayer)
        setupGradientColors(startColor: startColor, endColor: endColor) //прописываем цвета
        //задаем позиции для первого и последнего цвета
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
    }
    
    //P77. Настраиваем цвета в отдельной функции, для того, чтобы динамически можно было менять цвета через didSet
    private func setupGradientColors(startColor: UIColor?, endColor: UIColor?) {
        //если цвета передаются
        if let startColor = startColor, let endColor = endColor {
            //настраиваем цвета градиента
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    //инициализатор через кодер, нужен для того, чтобы инициализировать значения из storyBoard
    //именно coder отвечает за взаимодействие с interfaceDuilder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //P78. вызываем настройку
        setupGradient(from: .leading, to: .trailing, startColor: startColor, endColor: endColor)
    }
    
    
}
