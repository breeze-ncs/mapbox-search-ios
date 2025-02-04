// Copyright © 2023 Mapbox. All rights reserved.

import UIKit
import MapboxSearch

final class PlaceAutocompleteMainViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var messageLabel: UILabel!
    
    private lazy var placeAutocomplete = PlaceAutocomplete()
    
    private var cachedSuggestions: [PlaceAutocomplete.Suggestion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
}

// MARK: - UISearchResultsUpdating
extension PlaceAutocompleteMainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text
        else {
            cachedSuggestions = []
            
            reloadData()
            return
        }
        
        placeAutocomplete.suggestions(
            for: text,
            filterBy: .init(types: [.POI])
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let suggestions):
                self.cachedSuggestions = suggestions
                self.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PlaceAutocompleteMainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cachedSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "suggestion-tableview-cell"
        
        let tableViewCell: UITableViewCell
        if let cachedTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            tableViewCell = cachedTableViewCell
        } else {
            tableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let suggestion = cachedSuggestions[indexPath.row]

        tableViewCell.textLabel?.text = suggestion.name
        tableViewCell.accessoryType = .disclosureIndicator

        tableViewCell.detailTextLabel?.text = suggestion.description
        tableViewCell.detailTextLabel?.textColor = UIColor.darkGray
        tableViewCell.detailTextLabel?.numberOfLines = 2
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = cachedSuggestions[indexPath.row].result()
        let resultVC = PlaceAutocompleteResultViewController.instantiate(with: result)
        
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

// MARK: - Private
private extension PlaceAutocompleteMainViewController {
    func reloadData() {
        messageLabel.isHidden = !cachedSuggestions.isEmpty
        tableView.isHidden = cachedSuggestions.isEmpty

        tableView.reloadData()
    }
    
    func configureUI() {
        configureSearchController()
        configureTableView()
        configureMessageLabel()
    }
    
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.returnKeyType = .done

        navigationItem.searchController = searchController
    }
    
    func configureMessageLabel() {
        messageLabel.text = "Start typing to get autocomplete suggestions"
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = true
    }
}
