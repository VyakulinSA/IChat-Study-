//
//  ProfileViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 22.02.2021.
//

import Foundation
import UIKit
import SDWebImage

//P114. Создаем новый экран
class ProfileViewController: UIViewController {
    
    //объявляем.инициализируем элементы экрана
    let containerView = UIView()
    let imageView = UIImageView(image: #imageLiteral(resourceName: "human2"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Peter Ben", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "You have the opportunity to chat with the best man in the world", font: .systemFont(ofSize: 16, weight: .light))
    let myTextField = InsertableTextField()
    
    //P203. Создаем инициализатор для класса, чтобы инициализировать значения при создании объекта класса
    private let user: MUser
    
    init(user: MUser) {
        self.user = user
        self.nameLabel.text = user.username
        self.aboutMeLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeElements()
        setupConstraints()
    }
    
    //создадим функцию отключения translatesAutoresizingMaskIntoConstraints, чтобы в setupConstraints не городить код
    private func customizeElements() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0 //делаем для лейбла возможность увеличиваться на несколько строк в зависимости от текста
        
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
        
        //добавим действие для кнопки
        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    @objc private func sendMessage() {
        //P204. реализуем отправку сообщения
        //проверяем что сообщение есть
        guard let message = myTextField.text, message != "" else { return }
        //делаем чтобы экран сворачивался, когда мы отправляем сообщение
        dismiss(animated: true) {
            //создадим сервис для оправки запроса чата и сообщения в firebase см пункт 205
            //P210. Отправляем данные в БД
            FirestoreService.shared.createWaitingChat(message: message, receiver: self.user) { (result) in
                switch result{
                case .success():
                    //используем функцию, чтобы получить самый верхний экран и на нем отобразить allert (т.к. на этом мы не можем отобразить, потому что он закроется)
                    UIApplication.getTopViewController()?.showAllert(with: "Успешно", and: "Ваше сообщение для \(self.user.username) отправлено.")
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAllert(with: "Ошибка", and: error.localizedDescription)
                }
            }

            
        }
    }
}

extension ProfileViewController {
    
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(myTextField)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
        

    }
    
    
}
//
//
//
//
////MARK: SwiftUI
////Импортируем SwiftUI библиотеку
//import SwiftUI
////создаем структуру
//struct ProfileVCProvider: PreviewProvider {
//    static var previews: some View {
//            ContainerView().edgesIgnoringSafeArea(.all)
//    }
//    
//    struct ContainerView: UIViewControllerRepresentable {
//        //создадим объект класса, который хотим показывать в Canvas
//        let profileVC = ProfileViewController()
//        //меняем input параметры в соответствии с образцом
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ProfileVCProvider.ContainerView>) -> ProfileViewController {
//            return profileVC
//        }
//        //не пишем никакого кода
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        }
//    }
//}
