//
//  SceneDelegate.swift
//  iChat
//
//  Created by Вякулин Сергей on 31.01.2021.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //P1. Удаляем все упоминания storyBoard - В основном файле проекта, в разделе Target удаляем Main Interface, удаляем сам файл storyboard в проекте, удаляем ключ с упоминанием main.storyboard в info.plist - Application Scene Manifest
        //P2. Производим настройку отображения начального контроллера для того, чтобы мы могли указать какой контроллер у нас основной и верстать его через код
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
//        window?.rootViewController = AuthViewController() //здесь можно сенять наименование, чтобы запускать разные экраны в симуляторе
        
        //P156. Добавляем проверку на заполненность полей профиля юзера и соответствующий переход на нужный контроллер при загрузке приложения в самом начале
        if let user = Auth.auth().currentUser {
            //проверяем заполненность полей
            FirestoreService.shared.getUserData(user: user) { (result) in
                switch result {
                case .success(let muser):
//                    self.window?.rootViewController = MainTabBarController(currentUser: muser)
                    //P160.2 Переделываем показ MainTabBarController так, чтобы он разворачивался на весь экран, а не модально поверх предыдущих
                    let mainTabBar = MainTabBarController(currentUser: muser) //инициализируем таббар контроллер
                    mainTabBar.modalPresentationStyle = .fullScreen //делаем его на весь экран
                    self.window?.rootViewController = mainTabBar
                case .failure(_):
                    self.window?.rootViewController = AuthViewController()
                }
            }
        } else {
            window?.rootViewController = AuthViewController()
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

