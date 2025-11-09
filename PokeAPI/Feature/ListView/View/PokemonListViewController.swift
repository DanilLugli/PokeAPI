//
//  PokemonListViewController.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/9/25.
//

import UIKit
internal import Combine

class PokemonListViewController: UIViewController {

    private let tableView = UITableView()
    private var viewModel = PokemonListViewModel(api: APIManager())
    private var cancellables = Set<AnyCancellable>()
    private var canTriggerPagination = true
    
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController

        setupNavigationTitle()
        setupTableView()
        bindViewModel()
        setupSearch()

        viewModel.loadInitial()
    }
    
    private func setupNavigationTitle() {
        navigationItem.titleView = nil
        navigationItem.searchController = searchController
        
        let headerView = UIView()
        let imageView = UIImageView(image: UIImage(named: "PokemonBox"))
        imageView.contentMode = .scaleAspectFit

        headerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            imageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        tableView.tableHeaderView = headerView
        headerView.frame.size.height = 60
    }

    private func setupTableView() {
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .init(top: 0, left: 100, bottom: 0, right: 0)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {

        Publishers.CombineLatest(
            viewModel.$pokemons,
            viewModel.$searchText
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _, _ in
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                self?.tableView.tableFooterView = isLoading ? self?.loadingFooter : nil
            }
            .store(in: &cancellables)
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    private var loadingFooter: UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footer.center
        spinner.startAnimating()
        footer.addSubview(spinner)
        return footer
    }
}

extension PokemonListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredPokemons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as? PokemonCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.filteredPokemons[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        print("TEST offsetY: \(offsetY)")
        print("TEST contentHeight: \(contentHeight)")
        print("TEST frameHeight: \(frameHeight)")

        guard offsetY >= contentHeight - frameHeight else { return }
        guard canTriggerPagination else { return }
        guard !viewModel.isLoading else { return }
        canTriggerPagination = false

        if let last = viewModel.filteredPokemons.last {
            viewModel.loadNextPageCheckSearchActive(currentItem: last)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("TEST: Call ViewController")
            self.canTriggerPagination = true
        }
    }
}

extension PokemonListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
