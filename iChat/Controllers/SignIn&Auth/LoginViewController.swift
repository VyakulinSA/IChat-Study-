//
//  LoginViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 06.02.2021.
//

//P26. Создаем экран с логированием по примеры предыдущих экранов
import Foundation
import UIKit
import GoogleSignIn

class LoginViewController: UIViewController{
    //P28. Создаем элементы которые будут отображаться на View
    let welcomLabel = UILabel(text: "Welcome back!", font: .avenir26())
    
    let loginWithLabel = UILabel(text: "Login with")
    let orLabel = UILabel(text: "or")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    
    let googleButton = UIButton(title: "Google", titleColor: .black, backgtoundColor: .white, isShdow: true)
    
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField  = OneLineTextField(font: .avenir20())
    
    let loginButton = UIButton(title: "Login", titleColor: .white, backgtoundColor: .buttonDark())
    
    let signUpButton: UIButton = {
        //Так как кнопка инициализированно простым init, то докручиваем ее параметры внутри замыкания
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()

    //P141.1 Создадим свойство для подписывания делегата
    weak var delegate: AuthNavigatingDelegate?

    //P27. Создаем viewDidLoad дял загрузки страницы
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        //P33. Устанавливаем лого на кнопку гугл
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        //P123.2. Создаем наблюдателя действий для кнопки
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        //P139.1 добавим наблюдателя действие для дополнительной кнопки
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        //P173. добавим наблюдателя за нажатием на кнопку
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
    }
    
    //P174. Действие при нажатии
    @objc private func googleButtonTapped() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    //P124.2. создадим действия при нажатии на кнопку
    @objc private func loginButtonTapped() {
        print(#function)
        //P133. Вызываем метод логирования, передаем введенные пользователем данные, работаем с результатом
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAllert(with: "Успешно", and: "Вы авторизованы!") {
                    //P157. Добавляем проверку на заполненность полей и соответствующий переход на нужный экран при логировании
                    FirestoreService.shared.getUserData(user: user) { (result) in
                        switch result {
                        case .success(let muser):
                            //при нажатии кнопки OK в Allert, т.к замыкание передается - осуществляем переход на другой экран
                            //в зависимости от заполненности профиля, будем переходить на тот или иной эран (регистрация/основной экран)
//                            self.present(MainTabBarController(currentUser: muser), animated: true, completion: nil)
                            //P160.1 Переделываем показ MainTabBarController так, чтобы он разворачивался на весь экран, а не модально поверх предыдущих
                            let mainTabBar = MainTabBarController(currentUser: muser) //инициализируем таббар контроллер
                            mainTabBar.modalPresentationStyle = .fullScreen //делаем его на весь экран
                            self.present(mainTabBar, animated: true, completion: nil)
                        case .failure(_):
                            self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let error):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    //P142.1 добавим действие перехода на кнопку
    @objc private func signUpButtonTapped() {
        //при дополнительном переходе с уже открытого экрана, чтобы не создавать партянку экранов, сначала закрываем предыдущий(ну или текущий в котором вызываем)
        //так как данный экран закрывается, мы передаем управление делегату, и тот уже открывает другой экран со своими методами
        dismiss(animated: true) {
            //после срабатывания dismiss вызываем метод делегата(вызываем на экране который не скрыт) по открытию другого экрана
            self.delegate?.toSignUpVC()
        }
    }
}

//MARK: - setupConstraints
extension LoginViewController {
    //P29. Настройка констрейнтов
    private func setupConstraints() {
        
        //создаем объекты кастомных stackView
        let loginWithView = ButtonFromView(label: loginWithLabel, button: googleButton)
        
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel,emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel,passwordTextField], axis: .vertical, spacing: 0)
        
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [loginWithView, orLabel,emailStackView, passwordStackView, loginButton], axis: .vertical, spacing: 40)
        
        //создаем отдельный стек который будет распологаться ниже
        signUpButton.contentHorizontalAlignment = .leading //смещаем к левой границе
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel,signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        //отключаем авторесайзы у всех стэквью и welcomeLabel
        welcomLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //добавляем стэки на view
        view.addSubview(welcomLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        //настраиваем констрейнты внутри view
        NSLayoutConstraint.activate([
            welcomLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomLabel.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            
        ]) 
    }
}

//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct LoginVCProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let loginVC = LoginViewController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<LoginVCProvider.ContainerView>) -> LoginViewController {
            return loginVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}


