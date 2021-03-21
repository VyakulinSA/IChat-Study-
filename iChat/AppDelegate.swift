//
//  AppDelegate.swift
//  iChat
//
//  Created by Вякулин Сергей on 31.01.2021.
//

import UIKit
//P123.001. импортируем модуль
import Firebase
//P123.002. собираем проект cmd+B

//P162. Подключение кнопки авторизации через гугл -> Устанавливаем нужный pod(см. документацию) + импортируем модуль
import GoogleSignIn
//P163. В настройках приложения - info - URL Types - добавляем значение и вставляем туда ключ из файла GoogleService-Info.plist

//P177.импортируем FirebaseStorage
import FirebaseStorage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //P123.003. подключаем fireBase
        FirebaseApp.configure()
        //P164.Из документации firebase вставляем строку
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        return true
    }
    
    //P165. Добавляем следущий метод из документации
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

