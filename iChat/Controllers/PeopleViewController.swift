//
//  PeopleViewController.swift
//  iChat
//
//  Created by Вякулин Сергей on 10.02.2021.
//

import Foundation
import UIKit
import FirebaseAuth
//P193. импортируем библиотеку необходимую для настройки слушателя изменений в БД
import FirebaseFirestore

class PeopleViewController: UIViewController {
    
    //P92. Начинаем работу с экраном People - создаем массив элементов, отражаемых на странице (пока fakeData)
//    let users = Bundle.main.decode([MUser].self, from: "users.json")
    var users = [MUser]()
    
    //P194. Создаем свойство которое будет следить за изменением информации в БД
    private var usersListener: ListenerRegistration?
    
    //P94. Инициализируем CollectionView
    var collectionView: UICollectionView!
    //P96. Инициализируем Datasource
    var dataSource: UICollectionViewDiffableDataSource<Section, MUser>!
    
    //P95. Создаем секции DataSourse
    //Нам нужны хэшируемые секции (Даже если она одна, делаем перечисление, для возможности расширения потом)
    enum Section: Int, CaseIterable {
        //ВАЖНО: в каком порядке идут кейсы, в том они и отображаются на экране (потому что это enum и он итерируемый у первого элемента индекс 0 и не как иначе)
        //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс и настроим его ниже на подобии других секций
        case  users
        //Добавляем метод, который будет возвращать название заголовка в зависимости от секции
        func description(usersCount: Int) -> String {
            switch self {
            case .users:
                return "\(usersCount) people nearby"
            }
        }
    }
    
    //P161.1 Добавляем инициализатор и свойство класса, чтобы передавать на него информацию о пользователе (имя например) и дургую информацию
    private let currentUser: MUser
    
    init(currentUser: MUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        //делаем title(заголовок) экрана (наверху)
        title = currentUser.username
    }
    
    //P195. Создадим деинициализатор, который при срабатывании удаляет нашего слушателя БД, типо больше не надо в реальном времени обновлять данные
    deinit {
        usersListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .mainWhite()
        
        //P103. Не забываем указать все методы при загрузке страницы
        setupSearchBar()
        setupCollectionView()
        createDataSourse()
//        reloadData(with: nil)
        //P158. добавляем кнопку выхода на контроллер, чтобы момжно было разлогиниться
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))
        
        //P198. инициализируем слушателя БД ( с помощью нашего кастомного сервиса)
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            //из замыкания получаем результат
            switch result {
            case .success(let users):
                //присваиваем обновленные данные в наш массив и перезагружаем дату
                self.users = users
                self.createDataSourse()
                self.reloadData(with: nil)
            case .failure(let error):
                self.showAllert(with: "Ошибка", and: error.localizedDescription)
            }
        })
        
        
    }
    
    
    //P158.1 добавляем действие при нажатии
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure want to sin out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    //P97. настройка CollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight] //прописываем авторесайзинг по ширине и высоте
        collectionView.backgroundColor = .mainWhite()
        
        view.addSubview(collectionView)
        
        //Создаем заголовки (header)
        //Создаем кастомное view в отдельном файле см. SectionHeader.swift
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        //регистрируем ячейку
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        //P105. Меняем регистрацию на кастомную ячейку
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        
        collectionView.delegate = self
    }
    
    //P51. Функция для добавления и настройки SearchBar на экране (не забываем добавить функцию в viewDidLoad()
    private func setupSearchBar() {
        //ВЫзываем в нашем контроллере navigationBar и изменяем в нем цвет и убираем полоску разделителя
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage() //убираем полоску расзделителя, путем присвоения пустого изображения
        let searchController = UISearchController(searchResultsController: nil) //инициализируем serachController
        navigationItem.searchController = searchController //добавляем на контроллер
        navigationItem.hidesSearchBarWhenScrolling = false //не скрывать при скролинге
        searchController.hidesNavigationBarDuringPresentation = false //не скрывать при поиске
        searchController.obscuresBackgroundDuringPresentation = false
        //P52. Создадим делегата, чтобы при поиске он выполнял какие то действия
        searchController.searchBar.delegate = self
    }

    //MARK: ReloadData
    //P100. Создаем функцию для отображения информации в ячейке
    //целесообразно вызывать функцию reloadData там где мы конфигурируем DataSource - смотри выше
    //P111. Модифицируем функцию reloadData, чтобы можно было проводить поиск по людям и обновлять данные на экране
    //P111.1. добавляем свойство для передачи значения
    private func reloadData(with searchText: String?) {
        //P111.2. создаем фильтрованный массив
        let filtered = users.filter { (user) -> Bool in
            user.contains(filter: searchText) //возвращает true или false при наличии части имени в массиве
        }
        //создаем snapShot - наблюдатель за изменениями
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        //добавляем snapShots в нужные секции
        //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс в пересичление и настроим его ниже в DataSource на подобии других секций
        snapshot.appendSections([.users])
        //добавляем айтемы в секции
        snapshot.appendItems(filtered,toSection: .users)
        //регистрируем в DataSource
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

extension PeopleViewController {
    //P98. Начинаем работу с CompositionLayout
    private func createCompositionLayout() -> UICollectionViewLayout {
        //инициализируем UICollectionViewCompositionalLayout - с замыканием sectionProvider
        //sextionIndex - индекс секции которую настраиваем
        //layoutEnvironment -
        let layout = UICollectionViewCompositionalLayout { [self] (sextionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            //Делаем свич для настройки CompositionLayout, в зависимости от секции
            //ВАЖНО: Если хотим еще одну секцию, просто добавим кейс в перечислении и настроим его на подобии других секций
            guard let section = Section(rawValue: sextionIndex) else {fatalError("error")}
            switch section {
            case .users:
                return createUsersSection()
            }
        }
        
//        //Добавляем конфигурацию для Layout
//        let config = UICollectionViewCompositionalLayoutConfiguration() //инициализируем конфигурацию
//      config.interSectionSpacing = 20 //настраиваем расстояние между секциями
//        layout.configuration = config //присваиваем конфигурацию для Layout
        return layout
    }
    
    //P101. Создадим отдельную функцию для создания CompositionLayout
    private func createUsersSection() -> NSCollectionLayoutSection {
        //section -> group -> items -> size
        //сначала настраиваем размеры для item - потом настраиваем group - потом настраиваем секции
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6)) //указываем высоту равную 0.6 от ширины, чтобы поместить фотографию и лэйбл в одной ячейке
        //ВАЖНО указывая .horizontal - мы с другим инициализатором задаем параметры, сколько в группе размещать ячеек и как и какие
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        //Указываем расстояние между итемами внутри секции
        group.interItemSpacing = .fixed(15)

        let section = NSCollectionLayoutSection(group: group)
        //настраиваем отступы секции
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 15, bottom: 0, trailing: 15)
        //когда реализуем отступы через interGroupSpacing то они просто отсупают друг от друга, расширяя секцию
        section.interGroupSpacing = 15
        
        //вызываем функцию для конфигурирования заголовка активных чатов
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    //P102. Создадим функцию для настройки заголовков Header
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        //Настраиваем отображение заголовка
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader =  NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
}

//P99. настраиваем dataSource
extension PeopleViewController {
    private func createDataSourse() {
        dataSource = UICollectionViewDiffableDataSource<Section, MUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {fatalError("error")}
            
            switch section {
            case .users:
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
//                cell.backgroundColor = .systemBlue
                //P106. Меняем инициализацию простой ячейки на кастомную
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        
        //Настраиваем dataSource для отображения заголовков
        dataSource?.supplementaryViewProvider = { [self]
            (collectionView, kind, indexPath) in
            //кастим заголовок до нужного нам класса
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {fatalError("cannot create new sectionHeader")}
            //получаем секцию, в которой происходит запрос заголовка, чтобы потом передать название в заголовок
            guard let section = Section(rawValue: indexPath.row) else { fatalError("unnown section kind")}
            
            //пытаемся достучаться до snapshot, чтобы получить информацию о количестве юзеров в массивк
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            //конфигурируем заголовок (текст, цвет, шрифт)
            sectionHeader.configure(text: section.description(usersCount: items.count), font: .systemFont(ofSize: 36, weight: .light), textColor: .label)
            
            return sectionHeader
        }
    }
}

extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //P113. Для осуществления изменений на экране при поиске, вызываем reloadData и передаем туда поисковой запрос
        reloadData(with: searchText)
    }
}

//MARK: UICollectionViewDelegate
//P202. добавляем расширение, для работы с отправкой сообщения пользователю и отправка запрос разрешить чат с ним
//extension PeopleViewController: UICollectionViewDelegate {
//    //подписываем под делегата, чтобы можно было реализовать нажатие на элемент коллекции
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //сначала получаем юзера на которого нажади
//        guard let user = self.dataSource.itemIdentifier(for: indexPath) else {return}
//        //достаем класс profilrViewController - страничка на которой мы пишем текст пользователю
//        //создаем инициализатор для него, чтобы сразу заполнять все данные на экране смотри пункт 203
//        let profileVC = ProfileViewController(user: user)
//        //отображаем экран
//        present(profileVC, animated: true, completion: nil)
//
//    }
//}

///Test
extension PeopleViewController: UICollectionViewDelegate {
    //подписываем под делегата, чтобы можно было реализовать нажатие на элемент коллекции
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else {return}
        //проверяем если есть уже активный чат с человеком, то переходим сразу в чат
        FirestoreService.shared.haveActiveChats(user: user) { (result) in
            switch result {
            case .success(let chat):
                let chatsVS = ChatsViewController(user: self.currentUser, chat: chat)
                self.navigationController?.pushViewController(chatsVS, animated: true)
            case .failure(_):
                let profileVC = ProfileViewController(user: user)
                self.present(profileVC, animated: true, completion: nil)
            }
        }
    }
}

///Test




//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct PeopleVСProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let tabBarVC = MainTabBarController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<PeopleVСProvider.ContainerView>) -> MainTabBarController {
            return tabBarVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
