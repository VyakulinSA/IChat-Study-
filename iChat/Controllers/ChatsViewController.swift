//
//  ChatsViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 20.03.2021.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

//P234. Через podfile добавляем библиотеку MessageKit
//P235. Создаем новый контроллер для отображения чата

//класс подписываем под тип MessagesViewController
class ChatsViewController: MessagesViewController {
    
    private var messages: [Mmessage] = []
    //P252. Добавим слушателя сообщений в БД, для отображения и обновления массива сообщений
    private var messageListener: ListenerRegistration?
    
    //P236. создаем инициализатор для класса
    private let user: MUser
    private let chat: MChat
    
    internal init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        //отразаем в заголовке имя юзера с которым ведем переписку
        title = chat.friendUsername
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //P241. Делаем настройку TF при загрузке страницы
        configureMessageInputBar()
        
        //P249. Сдвигаем сообщения к границе экрана, после удаления аватарки
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        
        
        //P248. Задаем цвет фона
        messagesCollectionView.backgroundColor = .mainWhite()
        //P247. мы реализовали расширения и подписали под делегатов, теперь указываем, кто методы этих делегатов будет исполнять
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        //P254. Инициализируем слушателя
        messageListener = ListenerService.shared.messagesObserve(chat: chat, completion: { (result) in
            switch result {
            case .success(var message):
                //P261. дорабатываем слушателя, чтобы он мог отображать картинку или текст в зависимости от наличия сслыки на изображение
                if let url = message.downloadURL {
                    //P262. реализуем метод downloadImage в StorageService
                    StorageService.shared.downloadImage(url: url) { [weak self] (result) in
                        //проверка на то, что мы можем двигаться дольше только тогда когда смогли получить self (т.к. изображение может прогружаться долга)
                        guard let self = self else {return}
                        switch result {
                        case .success(let image):
                            //в сообщение кладем изображение
                            message.image = image
                            //отображаем на экране
                            self.insertNewMessage(message: message)
                        case .failure(let error):
                            self.showAllert(with: "Ошибка!", and: error.localizedDescription)
                        }
                    }
                } else {
                    //отображаем на экране
                    self.insertNewMessage(message: message)
                }
            case .failure(let error):
                self.showAllert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
    }
    
    //P244. Функция отображения нового сообщения на экране
    private func insertNewMessage(message: Mmessage) {
        //проверяем что такого сообщения еще не было
        guard !messages.contains(message) else {return}
        messages.append(message)
        //в пункте 245 указываем как необходимо сортировать (по дате)
        messages.sort()
        
        //при добавлении сообщения, проверяем не выходит ли он за рамки экрана, и если что двигаем вверх
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        messagesCollectionView.reloadData()
        if shouldScrollToBottom {
            //делаем в параллельном потоке, чтобы не поплыл интерфейс
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToLastItem()
            }
        }
    }
    
    
    
    //P257. метод действия при нажатии на кнопку
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    //P259. метод для отправки фото
    private func sendPhoto(image: UIImage) {
        //P260. в StorageService реализуем метод по отправке фото в БД
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { (result) in
            switch result {
            case .success(let url):
                var message = Mmessage(user: self.user, image: image)
                message.downloadURL = url
                FirestoreService.shared.sendMessage(chat: self.chat, message: message) { (reuslt) in
                    switch result {
                    case .success:
                        self.messagesCollectionView.scrollToLastItem()
                    case .failure(_):
                        self.showAllert(with: "Ошибка!", and: "Изображение не было доставлено")
                    }
                }
            case .failure(let error):
                self.showAllert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    //P240. Конфигурируем TextField экрана сообщений в наш кастомный TextField
    //MARK: configureMessageInputBar
    func configureMessageInputBar() {
        //копирую из тестового проекта, настройка производится по каждому разу универсально
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        //P256. добавим в инициализацию
        configureCameraIcon()
        
    }
    //копируем из тестового проекта
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal) //присваиваем изображение для кнопки
        messageInputBar.sendButton.applayGradients(cornerRadius: 10)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -38
    }
    
    //P255. создадим метод конфигурации изображения для кнопки выбора фото
    func configureCameraIcon(){
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1)
        let cameraImage = UIImage(systemName: "camera")
        cameraItem.image = cameraImage
        
        cameraItem.addTarget(self, action: #selector(cameraButtonPressed), for: .primaryActionTriggered)
        
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    
}


//P237. добавляем расширение для работы с чатами
// MARK: - MessagesDataSource
extension ChatsViewController: MessagesDataSource{
    
    //метод в который мы должны внести свои данные, чтобы библиотека понимала от кого сообщение, и распологала соответственно сообщения слева или справа и визуальные различия
    func currentSender() -> SenderType {
        return senderType(senderId: user.id, displayName: user.username)
    }
    
    //метод для работы с конкретным сообщением из массива сообщений
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    //метод для отображения дат между разными днями сообщений
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //отображаем дату только после каждого четвертого сообщения
        if indexPath.item % 4 == 0 {
            return NSAttributedString(
            string: MessageKitDateFormatter.shared.string(from: message.sentDate),
            attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        } else {
            return nil
        }
    }
    
    
}


//P242. Производим настройку стиля сообщений на экране
// MARK: - MessagesLayoutDelegate
extension ChatsViewController: MessagesLayoutDelegate{
    //для того чтобы определить позицию последнего сообщений на экране чата (расстояние доя TextField) реализуем метод из протокола MessagesLayoutDelegate
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        //позвращаем отступ снизу на 8
        return CGSize(width: 0, height: 8)
    }
    
    //для более корректного отображения даты, надо увеличить расстояние между сообщениями для каждого 4го
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.item % 4 == 0 {
            return 30
        } else {
            return 0
        }
    }
}

//P243. добавляем расширение для кастомизации представления сообщений на экране
// MARK: - MessagesDisplayDelegate
extension ChatsViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // isFromCurrentSender - функция определяющая от какого юзера пришло сообщение (возвращает true если это current и false если sender)
        return isFromCurrentSender(message: message) ? .white : #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2392156863, alpha: 1) : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //делаем так, чтобы аватарка не отображалась
        avatarView.isHidden = true
        
    }
    //размер аватарки равен 0
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    //метод определяющий стиль сообщений (самый важный)
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}

//P246. добавляем расширение для inputBar
// MARK: - MessageInputBarDelegate
extension ChatsViewController: InputBarAccessoryViewDelegate {
    //реализуем метод, в котором указываем, что делать по нажатию на кнопку отправить
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //создаем сообщение
        let message = Mmessage(user: user, content: text)
        
        //P251. добавляем сообщение в БД
        FirestoreService.shared.sendMessage(chat: chat, message: message) { (result) in
            switch result {
            case .success():
                //смещаем все сообщения на размер вновь добавленного
                self.messagesCollectionView.scrollToLastItem()
                //очищаем TExtField
                inputBar.inputTextView.text = ""
            case .failure(let error):
                self.showAllert(with: "Ошибка!", and: error.localizedDescription)
            }
        }


    }
}

//P258. расширение для работы с picker фото
extension ChatsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        
        sendPhoto(image: image)
    }
}

extension UIScrollView {
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
      let scrollViewHeight = bounds.height
      let scrollContentSizeHeight = contentSize.height
      let bottomInset = contentInset.bottom
      let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
      return scrollViewBottomOffset
    }
}

