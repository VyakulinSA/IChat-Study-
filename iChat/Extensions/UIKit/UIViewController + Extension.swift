//
//  UIViewController + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 22.02.2021.
//

import Foundation
import UIKit

//P107. Для того, чтобы не дублировать код функции в нескольких экранах, вынесем ее в расширение
extension UIViewController {
    
    //P73. Создадим функцию конфигруации ячейки, чтобы он отабражалась в SwiftUI и можно было ее настраивать через функцию в дальнейшем
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else {fatalError("Unable to deque")}
        cell.configure(with: value)
        return cell
    }
    
    //P131. Создаем отдельную функцию, которая будет генерить alert по нужным нам параметрам + выполнять действия по нажатию кнопки ОК
    func showAllert(with title: String, and message: String, completion: @escaping () -> Void = {}) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            //в данном случае, мы позволяем замыканию сбежать, и выполнить его уже там, где будем вызывать данную функцию, тем самым настроив действие на кнопке ОК
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
