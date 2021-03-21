//
//  UIImage + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 07.03.2021.
//

import Foundation
import UIKit

//P185. Создадим расширение класса и кастомную функцию для уменьшения изображения, чтобы хорошо хранить в БД
extension UIImage {
    
    //логика ниже не требуется для записи, это скачанный со стаковерфло пример, такие вещи обычно гуглятся
    var scaledToSafeUploadSize: UIImage? {
      let maxImageSideLength: CGFloat = 480
      
      let largerSide: CGFloat = max(size.width, size.height)
      let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
      let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
      
      return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
      defer {
        UIGraphicsEndImageContext()
      }
      
      UIGraphicsBeginImageContextWithOptions(size, true, 0)
      draw(in: CGRect(origin: .zero, size: size))

      return UIGraphicsGetImageFromCurrentImageContext()
    }
}
