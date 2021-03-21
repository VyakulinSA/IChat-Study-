//
//  ChatRequestViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 23.02.2021.
//

import Foundation
import UIKit


//P121. Отрисуем еще один экран
class ChatRequestViewController: UIViewController {
    
    //объявляем.инициализируем элементы экрана
    let containerView = UIView()
    let imageView = UIImageView(image: #imageLiteral(resourceName: "human5"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Mary Jane", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "I want you, my spider man", font: .systemFont(ofSize: 16, weight: .light))
    let acceptButton = UIButton(title: "ACCEPT", titleColor: .white, backgtoundColor: .black, font: .laoSangamMN20(), corrnerRadius: 10)
    let denyButton = UIButton(title: "Deny", titleColor: #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1), backgtoundColor: .mainWhite(), font: .laoSangamMN20(), corrnerRadius: 10)
    
    //P223.Создаем свойство для делегата
    weak var delegate: WaitingChatsNavigation?
    
    //P218. Создаем инициализатор который может из полученного нового ожидающего чата, инициализировать экран
    private var chat: MChat
    
    init(chat: MChat){
        self.chat = chat
        self.nameLabel.text = chat.friendUsername
        self.imageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
//        self.aboutMeLabel.text = chat.lastMessageContent
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainWhite()
        
        customizeElements()
        setupConstraints()
    }
    
    private func customizeElements() {
        //Настраиваем кнопки
        denyButton.layer.borderWidth = 1.2 //настраиваем отображение границ
        denyButton.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1) //настраиваем цвет
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0
        
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
        
//        acceptButton.applayGradients(cornerRadius: 10) //чтобы у кнопки появидся градиент, нужно его устанавливать через метод viewWillLayoutSubviews см. Ниже
        
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(deny), for: .touchUpInside)
    }
    
    //P122. нужно устанавливать градиент до отрисовывания layout чтобы установить градиент, в противном сулчае не отрисуется
    //ВАЖНО - в остановленном Canvas не отображается, проверять в симуляторе или сделать Play в Canvas
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.acceptButton.applayGradients(cornerRadius: 10)
    }
    
    @objc private func accept() {
        dismiss(animated: true) {
            //P224.1. реализуем методы делегата
            self.delegate?.chatToActive(chat: self.chat)
        }
    }
    
    @objc private func deny() {
        //P221. Реализуем отмену ожидающего чата (удаляем ожидающий чат у пользователя в БД)
        //закрываем экран
        dismiss(animated: true) {
            //P224. реализуем методы делегата
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }
}


extension ChatRequestViewController{
    
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        
        //        containerView.addSubview(acceptButton)
        //        containerView.addSubview(denyButton)
        
        //добавляем кнопки через стэк
        let buttonsStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 7)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.distribution = .fillEqually
        
        containerView.addSubview(buttonsStackView)
        

        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        
//        NSLayoutConstraint.activate([
//            acceptButton.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 20),
//            acceptButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
//            acceptButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -10),
//        ])
//
//        NSLayoutConstraint.activate([
//            denyButton.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 20),
//            denyButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 10),
//            denyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
//        ])
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 56)
        ])

    }
}







////MARK: SwiftUI
////Импортируем SwiftUI библиотеку
//import SwiftUI
////создаем структуру
//struct ChatRequestVCProvider: PreviewProvider {
//    static var previews: some View {
//            ContainerView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainerView: UIViewControllerRepresentable {
//        //создадим объект класса, который хотим показывать в Canvas
//        let chatReqVC = ChatRequestViewController()
//        //меняем input параметры в соответствии с образцом
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ChatRequestVCProvider.ContainerView>) -> ChatRequestViewController {
//            return chatReqVC
//        }
//        //не пишем никакого кода
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        }
//    }
//}
