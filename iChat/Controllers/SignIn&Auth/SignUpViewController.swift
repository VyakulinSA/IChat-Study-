//
//  SignUpViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 06.02.2021.
//

//P19. Создаем второй экран
import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    //P21. Создаем элементы которые будут отображаться на View
    let welcomLabel = UILabel(text: "Good to see you!", font: .avenir26())
    
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let confirmPasswordLabel = UILabel(text: "Confirm password")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    //P23. см OneLineTextField.swift
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField  = OneLineTextField(font: .avenir20())
    let confirmPasswordTextField  = OneLineTextField(font: .avenir20())
    
    let signUpButton = UIButton(title: "Sign Up", titleColor: .white, backgtoundColor: .buttonDark(), corrnerRadius: 4)
    let loginButton: UIButton = {
        //P22. Так как кнопка инициализированно простым init, то докручиваем ее параметры внутри замыкания
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    //P141. Создадим свойство для подписывания делегата
    weak var delegate: AuthNavigatingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        //P25. подключение констрейнтов
        setupConstraints()
        
        //P123.1. Создаем наблюдателя действий для кнопки
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        //P139. добавим наблюдателя действие для дополнительной кнопки
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    //P124.1. создадим действия при нажатии на кнопку
    @objc private func signUpButtonTapped() {
        print(#function)
        //P130. Вызываем метод регистрации пользователя, передаем введенный пользователем данные (логин, пароль)
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text) { (result) in
            //в сбегающем замыкании получаем result, с которым будем работать через switch
            switch result {
            case .success(let user):
                //в случае успеха вызываем функцию генерации allert (см. P131)
                self.showAllert(with: "Успешно", and: "Вы зарегистрированы!") {
                    //при нажатии кнопки OK в Allert, т.к замыкание передается именно в него - осуществляем переход на другой экран
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            case .failure(let error):
                //в случае неудачи вызываем функцию генерации allert (см. P131)
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    //P142. добавим действие перехода на кнопку
    @objc private func loginButtonTapped() {
        //при дополнительном переходе с уже открытого экрана, чтобы не создавать партянку экранов, сначала закрываем предыдущий(ну или текущий в котором вызываем)
        //так как данный экран закрывается, мы передаем управление делегату, и тот уже открывает другой экран со своими методами
        dismiss(animated: true) {
            //после срабатывания dismiss вызываем метод делегата по открытию другого экрана
            self.delegate?.toLoginVC()
        }
    }
    
    
}

//MARK: - setupConstraints
extension SignUpViewController {
    //P24. Настройка констрейнтов
    private func setupConstraints() {
        //создаем стэки лэйбл + текстфилд
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel,emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel,passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel,confirmPasswordTextField], axis: .vertical, spacing: 0)
        //задаем размер кнопки и отключаем авторесайзинг
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        //добавляем все в один большой стэк
        let stackView = UIStackView(arrangedSubviews: [
                                        emailStackView,
                                        passwordStackView,
                                        confirmPasswordStackView,
                                        signUpButton],
                                    axis: .vertical,
                                    spacing: 40)
        //создаем отдельный стек который будет распологаться ниже
        loginButton.contentHorizontalAlignment = .leading //смещаем к левой границе
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnboardLabel,loginButton], axis: .horizontal, spacing: 10)
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
            stackView.topAnchor.constraint(equalTo: welcomLabel.bottomAnchor, constant: 160),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 60),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
            
        ])

        
        
        
    }
}

//MARK: SwiftUI
//P20.Копируем код для работы в canvas
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct SignUpVCProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let signUpVC = SignUpViewController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<SignUpVCProvider.ContainerView>) -> SignUpViewController {
            return signUpVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
