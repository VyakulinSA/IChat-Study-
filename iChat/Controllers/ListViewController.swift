//
//  ListViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 10.02.2021.
//

//P42. Начинаем работу с CollectionView
import Foundation
import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {
    
    //P57. Создаем массив активных чатов, которые будет отражать фэйковую дату через декодирование JSON
//    let activeChats = Bundle.main.decode([MChat].self, from: "activeChats.json")
    var activeChats = [MChat]()
    //P61.1. Добавляем итемы для второй секции
//    let waitingChats = Bundle.main.decode([MChat].self, from: "waitingChats.json")
    var waitingChats = [MChat]()
    
    //P211. Создаем слушателя firebase для ожидающих чатов
    private var waitingChatListener: ListenerRegistration?
    
    //P231. Создаем слушателя для активных чатов
    private var activeChatsListener: ListenerRegistration?

    //P54. СОздаем объект DataSourse
    //Нам нужны хэшируемые секции
    enum Section: Int, CaseIterable {
        //ВАЖНО: в каком порятке идут кейсы, в том они и отображаются на экране (потому что это enum и он итерируемый у первого элемента индекс 0 и не как иначе)
        case  waitingChats, activeChats //P61.0. добавляем кейс еще одной секции к перечислению
        //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс и настроим его ниже на подобии других секций
        
        //P90. Добавляем метод, который будет возвращать название заголовка в зависимости от секции
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
            }
        }
    }
    //инициализируем объект DiffableDataSource с дженериками(обязательными) идентификатор секции и идентификатор айтема
    var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?
    
    //P43. Создаем CollectionView
    var collectionView: UICollectionView!
    
    //P161.2 Добавляем инициализатор и свойство класса, чтобы передавать на него информацию о пользователе (имя например) и дургую информацию
    private let currentUser: MUser
    
    init(currentUser: MUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        //делаем title(заголовок) экрана (наверху)
        title = currentUser.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //P212. Создаем деинициализатор для слушателя
    deinit {
        waitingChatListener?.remove()
        //P233. Удаляем слушателя активных чатов при deinit
        activeChatsListener?.remove()
    }
    
//MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupSearchBar()
        //P59. вызываем функции diffableDataSource при загрузке страницы
        createDataSource()
        reloadData() //ВАЖНО - указывать в конце, типо перезагрука после всей прогрузки
        
        
        
        //P215. Запускаем слушателя при загрузке экрана
        waitingChatListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats, completion: { (result) in
            switch result{
            case .success(let chats):
                //P217. Добавляем функционал, чтобы при появлении нового ожидающего чата, у другого пользователя всплывало окно с запросом
                //если массив не равен пустому и кол-во чатов изменилось, то вызываем окно
                if self.waitingChats != [], self.waitingChats.count <= chats.count {
                    let chatRequestVC = ChatRequestViewController(chat: chats.last!)
                    //P227.1. Указываем что делегатом контроллера запроса является текущий класс
                    chatRequestVC.delegate = self
                    //вызываем отображение на экране
                    self.present(chatRequestVC, animated: true, completion: nil)
                }
                
                //присваиваем обновленные данные в наш массив и перезагружаем дату
                self.waitingChats = chats
                self.createDataSource()
                self.reloadData()
                
            case .failure(let error):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        })
        
        //P232. Запускаем слушателя при загрузке экрана
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: activeChats, completion: { (result) in
            switch result{
            case .success(let chats):
                //присваиваем обновленные данные в наш массив и перезагружаем дату
                self.activeChats = chats
                self.createDataSource()
                self.reloadData()
                
            case .failure(let error):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        })

    }
    
    //P49. Функция для добавления и настройки SearchBar на экране (не забываем добавить функцию в viewDidLoad()
    private func setupSearchBar() {
        //ВЫзываем в нашем контроллере navigationBar и изменяем в нем цвет и убираем полоску разделителя
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage() //убираем полоску расзделителя, путем присвоения пустого изображения
        let searchController = UISearchController(searchResultsController: nil) //инициализируем serachController
        navigationItem.searchController = searchController //добавляем на контроллер
        navigationItem.hidesSearchBarWhenScrolling = false //не скрывать при скролинге
        searchController.hidesNavigationBarDuringPresentation = false //не скрывать при поиске
        searchController.obscuresBackgroundDuringPresentation = false
        //P50. Создадим делегата, чтобы при поиске он выполнял какие то действия
        searchController.searchBar.delegate = self
    }
    
    //P44. настройка CollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight] //прописываем авторесайзинг по ширине и высоте
        collectionView.backgroundColor = .mainWhite()
        
        view.addSubview(collectionView)
        
        //P82. Создаем заголовки (header)
        //P83. Создаем кастомное view в отдельном файле см. SectionHeader.swift
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        //P74. Заменили регистрацию ячейки в соответствии с новым классом для ячейки
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId) //регистрируем ячейку на collectionView
        //P62. Регистрируем еще один вид ячейки (для второй секции)
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId2") //регистрируем ячейку на collectionView
        //P81. Заменили регистрацию ячейки в соответствии с новым классом для ячейки
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        
        //P220. объявляем делегатом текущий класс, для использования расширения ниже
        collectionView.delegate = self
        
    }
    
    //P58. Создаем функцию для отображения информации в ячейке
    //целесообразно вызывать функцию reloadData там где мы конфигурируем DataSource - смотри выше
    private func reloadData() {
        //создаем snapShot - наблюдатель за изменениями
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
       //добавляем snapShots в нужные секции
        //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс в пересичление и настроим его ниже в DataSource на подобии других секций
        snapshot.appendSections([.waitingChats, .activeChats])
        //добавляем айтемы в секции
        snapshot.appendItems(waitingChats,toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .activeChats) //activeChats - в данном случае массив с чатам
        //регистрируем в DataSource
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    

}

//P45. подписываем под делегата и датасорс CollectionView - Удален Extension(так как с CompositionLayout используется diffableDataSource с другой реализацией)

//MARK: DataSource
extension ListViewController{
    
    //P55. Реализуем функцию для работы с diffableDataSource
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            //cellProvider - возвращает, CollectionView, indexPath и еще один параметр(_) который содержит инфо о том, что будет содержаться в ячейке
            //получаем секцию
            guard let section = Section(rawValue: indexPath.section) else {fatalError("error")}
            //в зависимости от секции создаем ячейку
            //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс в перечислении и настроим его на подобии других секций
            switch section {
            case .activeChats:
                //создаем и возвращаем ячейку
                //P74.1. Заменили конфигурацию ячейки
//                return self.configure(cellType: ActiveChatCell.self, with: chat, for: indexPath)
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
            //P63. Создаем еще один кейс для второго вида секции
            case .waitingChats:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId2", for: indexPath)
//                cell.backgroundColor = .systemRed
//                return cell
                //P81. Заменили конфигурацию ячейки
//                return self.configure(cellType: WaitingChatCell.self, with: chat, for: indexPath)
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
            }
        })
        
        //P89. Настраиваем dataSource для отображения заголовков
        dataSource?.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in
            //кастим заголовок до нужного нам класса
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {fatalError("cannot create new sectionHeader")}
            //получаем секцию, в которой происходит запрос заголовка, чтобы потом передать название в заголовок
            guard let section = Section(rawValue: indexPath.row) else { fatalError("unnown section kind")}
            //конфигурируем заголовок (текст, цвет, шрифт)
            sectionHeader.configure(text: section.description(), font: .laoSangamMN20(), textColor: #colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1))
            
            return sectionHeader
        }
    }
}

//MARK: SetupLayout
extension ListViewController{
    //P53. Начинаем работу с CompositionLayout
    //создаем обычную функцию которая возвращает обычный layout - UICollectionViewLayout
    private func createCompositionLayout() -> UICollectionViewLayout {
        //инициализируем UICollectionViewCompositionalLayout - с замыканием sectionProvider
        //sextionIndex - индекс секции которую настраиваем
        //layoutEnvironment -
        let layout = UICollectionViewCompositionalLayout { [self] (sextionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            //Все что ниже переносим в отдельную функцию
//            //section -> group -> items -> size
//            //сначала настраиваем размеры для item - потом настраиваем group - потом настраиваем секции
//            //P53.1. создадим item + размеры
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//            //P53.2. создадим group
//            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(84))
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//            //настраиваем отступы секции
//            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
//            //P53.3. создадим section
//            let section = NSCollectionLayoutSection(group: group)
//            //настраиваем отступы секции
//            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
//            return section
            
            //P67. Делаем свич для настройки CompositionLayout, в зависимости от секции
            //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс в перечислении и настроим его на подобии других секций
            guard let section = Section(rawValue: sextionIndex) else {fatalError("error")}
            switch section {
            case .activeChats:
                return self.createActiveChats()
            case .waitingChats:
                return self.createWaitingChats()
            }
        }
        
        //P91. Добавляем конфигурацию для Layout
        let config = UICollectionViewCompositionalLayoutConfiguration() //инициализируем конфигурацию
        config.interSectionSpacing = 20 //настраиваем расстояние между секциями
        layout.configuration = config //присваиваем конфигурацию для Layout
        
        
        return layout
    }
    
    //P68. Создадим отдельную функцию для создания CompositionLayout для Второй секции
    private func createWaitingChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        //когда реализуем через insets то отступы берутся за счет размера группы (см. groupSize)
//        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous //ВАЖНО, чтобы item распологались горизонтально, надо указать параметры прокрутки
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20) //top - указывается до заголовка
        //когда реализуем отступы через interGroupSpacing то они просто отсупают друг от друга, расширяя секцию
        section.interGroupSpacing = 20 //делаем растояние между группами внутри секции
        
        //P87. вызываем функцию для конфигурирования заголовка ожидающих чатов
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    //P66. Создадим отдельную функцию для создания CompositionLayout для первой секции
    private func createActiveChats() -> NSCollectionLayoutSection {
        //section -> group -> items -> size
        //сначала настраиваем размеры для item - потом настраиваем group - потом настраиваем секции
        //P53.1. создадим item + размеры
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        //P53.2. создадим group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        //настраиваем отступы секции
        //когда реализуем через insets то отступы берутся за счет размера группы (см. groupSize)
//        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        //P53.3. создадим section
        let section = NSCollectionLayoutSection(group: group)
        //настраиваем отступы секции
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        //когда реализуем отступы через interGroupSpacing то они просто отсупают друг от друга, расширяя секцию
        section.interGroupSpacing = 8
        
        //P88. вызываем функцию для конфигурирования заголовка активных чатов
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    //P85. Создадим функцию для настройки заголовков Header
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        //P86. Настраиваем отображение заголовка
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader =  NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
}

//MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    //P50. что делать, когда пользователь вводит что то в поиск
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

//P219. Делаем расширение, чтобы была возможность нажать на ожидающий чат и открывался экран с запросом на общение ( в котором мы можем отклонить и согласовать)
extension ListViewController: UICollectionViewDelegate{
    //вызываем метод didSelectItemAt, который описывает действие при нажатии на ячейку коллекции
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else {return}
        guard let section = Section(rawValue: indexPath.section) else {return}
        switch section {
        case .waitingChats:
            let chatRequestVC = ChatRequestViewController(chat: chat)
            //P227. Указываем что делегатом контроллера запроса является текущий класс
            chatRequestVC.delegate = self
            self.present(chatRequestVC, animated: true, completion: nil)
        case .activeChats:
            //P239. отображаем контроллер чата при нажатии на активный чат
            let chatsVS = ChatsViewController(user: currentUser, chat: chat)
            //вызываем навигейшн контроллер и толкаем наш экран на контроллер с чатами
            navigationController?.pushViewController(chatsVS, animated: true)
            
        }
    }
}

//P225. добавляем расширение и подписываем под протокол WaitingChatsNavigation для реализации функционала в данном классе по удалению из БД информации об ожидающих чатах
extension ListViewController: WaitingChatsNavigation {
    func removeWaitingChat(chat: MChat) {
        //вызываем метод удаления, который реализовали в пункте 226
        FirestoreService.shared.deleteWaitingChat(chat: chat) { (result) in
            switch result{
            case .success():
                self.showAllert(with: "Успешно!", and: "Чат с \(chat.friendUsername) удален")
            case .failure(let error):
                self.showAllert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    func chatToActive(chat: MChat) {
        //P229. реализуем метод делегата по переносу ожидающего  чата в активный
        FirestoreService.shared.changeToActive(chat: chat) { (result) in
            switch result {
            case .success():
                self.showAllert(with: "Успешно!", and: "Приятного общения с \(chat.friendUsername).")
            case .failure(let error):
                self.showAllert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    
}

//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct ListVСProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let tabBarVC = MainTabBarController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<ListVСProvider.ContainerView>) -> MainTabBarController {
            return tabBarVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
