//
//  ViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 31.01.2021.
//

import UIKit
//P166. импортируем библиотеку
import GoogleSignIn

class AuthViewController: UIViewController {
    
//P14. Создадим Логотип для размещения на экране с помощью convinience init
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    
    
//P13. Создадим лэйблы для размещения на экране с помощью convinience init
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Alerady onboard?")
    
//P11. Создаем 3 кнопку с помощью convinience init у расширения и кастомного цвета (все настройки кнопки берем из предоставленного от дизайнера sketh файла. где указаны желаемые цвета и размеры)
    let googleButton = UIButton(title: "Google", titleColor: .black, backgtoundColor: .white, isShdow: true)
//P7. Создаем 1 кнопку с помощью convinience init у расширения и кастомного шрифта
    let emailButton = UIButton(title: "Email", titleColor: .white, backgtoundColor: .buttonDark())
//P9. Создаем 2 кнопку с помощью convinience init у расширения и кастомного цвета
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgtoundColor: .white, isShdow: true)
    
    //P126. Создадим объекты класса контроллера на который будем осуществлять переход
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //P32. Устанавливаем лого на кнопку гугл
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        //P123. Создаем таргеты для нажатия кнопок
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        //P144. Указываем что делегатом контроллеров будет данный класс
        loginVC.delegate = self
        signUpVC.delegate = self
        
        //P169. указываем, кто будет исполнять методы делегата, чтобы работала авторизация через google кнопку
        GIDSignIn.sharedInstance()?.delegate = self
        //P170. добавляем действие на кнопку
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
    }
    
    //P171. Создаем действие кнопки googleButton
    @objc private func googleButtonTapped() {
        //в соответствии с документацией firebase реализуем 2 метода, чтобы выходило окно авторизации в гугл
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    //P124. Создаем действия для нажатия на кнопки emailButton
    @objc private func emailButtonTapped() {
        print(#function)
        //P125. Реализуем переход на другой экран при нажатии кнопки email
        present(signUpVC, animated: true, completion: nil)
    }
    
    @objc private func loginButtonTapped() {
        print(#function)
        //P125. Реализуем переход на другой экран при нажатии кнопки email
        present(loginVC, animated: true, completion: nil)
    }

}



//MARK: - setupConstraints
//создаем расширение класса, в котором бцдем настраивать view, чтобы не нагружать основной класс
extension AuthViewController {
    //P16. См. файл ButtonFromView
    //P17. Создаем Constraints и функции устанвоки view на экран
    private func setupConstraints() {
        //начинаем сверху вниз
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        //создаем объекты кастомных stackView
        let googleView = ButtonFromView(label: googleLabel, button: googleButton)
        let emailView = ButtonFromView(label: emailLabel, button: emailButton)
        let loginView = ButtonFromView(label: alreadyOnboardLabel, button: loginButton)
        
        //P18. См. файл StackView + Extension.swift
        //помещаем кастомные стэквью в один общий стэк
        let stackView = UIStackView(arrangedSubviews: [googleView,emailView,loginView], axis: .vertical, spacing: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        let stackView = UIStackView(arrangedSubviews: [googleView,emailView,loginView])m
//        stackView.axis = .vertical //расположение
//        stackView.spacing = 40 //расстояние между элементами внутри
        
        //помещаем элементы на view
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        //создаем привязки (Constraints)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
}


//P143. Подписываем AuthViewController под протокол делегата, важно, что именно этот контроллер подписываем
//ВАЖНО: не забываем во viewDidLoad указать, что данный класс является делегатом
extension AuthViewController: AuthNavigatingDelegate {
    //реализуем функции делегата
    func toLoginVC() {
        present(loginVC, animated: true, completion: nil)
    }
    func toSignUpVC() {
        present(signUpVC, animated: true, completion: nil)
    }
}

//MARK:GIDSignInDelegate
//P168. Делаем расширение класса. для работы с гугл авторизацией
extension AuthViewController: GIDSignInDelegate {
    //реализуем стандартный метод
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        AuthService.shared.googleLogin(user: user, error: error) { (result) in
            switch result {
            case .success(let user):
                //проверяем заполненность профиль, и в зависимости от этого переходим на нужный нам экран
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result{
                    case .success(let muser):
                        //P176. дорабатываем переход с помощью расширения и функции в p175 (UIApplication.getTopViewController()?)
                        UIApplication.getTopViewController()?.showAllert(with: "Успешно", and: "Вы авторизованы") {
                            let mainTabbar = MainTabBarController(currentUser: muser)
                            mainTabbar.modalPresentationStyle = .fullScreen
                            UIApplication.getTopViewController()?.present(mainTabbar, animated: true, completion: nil)
                        }
                    case .failure(_):
                        UIApplication.getTopViewController()?.showAllert(with: "Успешно", and: "Вы зарегистрированы") {
                            UIApplication.getTopViewController()?.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(_):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    
}



//MARK: SwiftUI
//P3. (ВАЖНО: данный код, можно переносить из файла в файл, для подключения SwiftUI к UIKit) Стандартно UIKit не может работать через Canvas с экраном как при работе через SwiftUI. Ддля того, чтобы это стало возможно, нужно переконвертировать UIKit через SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct AuthVCProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let viewController = AuthViewController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<AuthVCProvider.ContainerView>) -> AuthViewController {
            return viewController
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}



