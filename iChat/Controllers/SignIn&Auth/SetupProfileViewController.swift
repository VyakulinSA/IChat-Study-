//
//  SetupProfileViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 09.02.2021.
//
//P30. Создаем экран настройки профиля (аналогично всем предыдущим экранам)
import Foundation
import UIKit
//P151.1 импортируем авторизацию firebase
import FirebaseAuth
import SDWebImage

class SetupProfileViewController: UIViewController {
    //P39. инициализируем view с фотографией и кнопкой
    //P180. Добавляем свойство хранения фото пользователя
    let fullImageView = AddPhotoView()
    //P40. создадим элементы которые будут размещаться на View
    let welcomeLabel = UILabel(text: "Set up profile", font: .avenir26())
    
    let fullNameLabel = UILabel(text: "Full name", font: .avenir20())
    let aboutMeLabel = UILabel(text: "About me", font: .avenir20())
    let sexLabel = UILabel(text: "Sex", font: .avenir20())
    
    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())
    //P40.1. создаем кастомный segmentedControl (см. SegmentedControl + Extension.swift)
    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    
    let goToChatsButtton = UIButton(title: "Go to chats!", titleColor: .white, backgtoundColor: .buttonDark())
    
    //P151. инициаизируем пользователя, Тк переход на данный экран осуществляется только у зарегистрированног опользователя
    private var currentUser: User
    //добавляем инициализатор
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        //P172. Добавляем в инициализатор, возможность предзаполнения данных ,если входим через гугл
        if let username = currentUser.displayName {
            fullNameTextField.text = username
        }
        if let photoURL = currentUser.photoURL {
            fullImageView.circleImageView.sd_setImage(with: photoURL, completed: nil)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        setupConstraints()
        
        //P152. добавим наблюдателя за нажатием кнопки
        goToChatsButtton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
        //P190. Добавляем действие для кнопки + по добавлению изображения
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    
    //P191. Описание действия для кнопки добавления изображения
    @objc private func plusButtonTapped() {
        //достаем объект для работы с добавлением изображений
        let imagePickerController = UIImagePickerController()
        //делегатом будет данный класс, и в расширении мы пишем логику работы делегата и что будет наш picker делать при выборе фотки
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //P153. создадим селектор действия для кнопки
    @objc private func goToChatsButtonTapped() {
        //сохраняяем в БД информацию + переходим на экран
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                email: currentUser.email!,
                                                username: fullNameTextField.text,
                                                avatarImage: fullImageView.circleImageView.image,
                                                description: aboutMeTextField.text,
                                                sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { (result) in
            switch result{
            case .success(let muser):
                self.showAllert(with: "Успешно!", and: "Приятного общения") {
                    //P159. добавляем переход на главный экран после заполнения всех полей профиля
//                    self.present(MainTabBarController(currentUser: muser), animated: true, completion: nil)
                    //P160. Переделываем показ MainTabBarController так, чтобы он разворачивался на весь экран, а не модально поверх предыдущих
                    let mainTabBar = MainTabBarController(currentUser: muser) //инициализируем таббар контроллер
                    mainTabBar.modalPresentationStyle = .fullScreen //делаем его на весь экран
                    self.present(mainTabBar, animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
}

//MARK: setupConstraints
extension SetupProfileViewController {
    //P41. закрепим констрейнтами кастомное все элементы на экране
    private func setupConstraints() {
        //добавляем элементы в стэки
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel,fullNameTextField], axis: .vertical, spacing: 0)
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel,aboutMeTextField], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel,sexSegmentedControl], axis: .vertical, spacing: 10)
        //стеки складываем в один стэк + кнопка
        let stackView = UIStackView(arrangedSubviews: [fullNameStackView,aboutMeStackView,sexStackView, goToChatsButtton], axis: .vertical, spacing: 40)
        //устанавливаем размер кнопки, чтобы не сжималась
        goToChatsButtton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        //отключаем ресайзинги
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        //добавляем элементы на view
        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(stackView)
        
        //устанавливаем и активируем констрейнты
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fullImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: fullImageView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

//MARK: - UIImagePickerControllerDelegate
//P192. Добавим расширение для класса , чтобы была возможность реализовать делегат UIImagePickerView
extension SetupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //после выбора изображения, закрываем picker
        picker.dismiss(animated: true, completion: nil)
        //получаем изображение из массива изображений UIImagePickerController
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        fullImageView.circleImageView.image = image
    }
}


//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct SetupProfileVСProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let setupProfileVC = SetupProfileViewController(currentUser: Auth.auth().currentUser!)
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<SetupProfileVСProvider.ContainerView>) -> SetupProfileViewController {
            return setupProfileVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
