//
//  MainTabBarController.swift
//  iChat
//
//  Created by Вякулин Сергей on 10.02.2021.
//

import Foundation
import UIKit

//P46. создаем кастомный таббар в котором будет располагаться collectionView и другие экраны если понадобятся
class MainTabBarController: UITabBarController {
    
    //P161. Добавляем инициализатор и свойство класса, чтобы передавать на него информацию о пользователе (имя например) и дургую информацию
    private let currentUser: MUser
    //в инициализаторе сдлеаем дефолтное значение, чтобы у нас не ругался во всех местах где мы отрисовываем через SwiftUI
    init(currentUser: MUser = MUser(username: "username",
                                    avatarStringURL: "noAvatar",
                                    email: "email",
                                    description: "desc",
                                    sex: "sex",
                                    id: "id")) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //инициализируем объекты контроллеров, которые будет распологать на tabBar
        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        
        tabBar.tintColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1) //цвет значков и текста на tabBar
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium) //делаем конфигурацию - символ жирнее (возможно относится только к символам Apple)
        
        let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig)! //при инициализации используем конфигурацию изображения созданную выше
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)!
        
        //P48. добавляем контроллеры на TabBar
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversation", image: convImage),
        ]
        
    }
    
    //P47. Создаем метод который будет генерить контроллеры для таббара + сразу устанавливать подписи и изображения
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController) //один из контроллеров который будет распологаться на tabBar
        navigationVC.tabBarItem.title = title //подпись
        navigationVC.tabBarItem.image = image //изображение
        return navigationVC
    }
}
