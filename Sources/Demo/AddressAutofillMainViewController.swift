// Copyright © 2022 Mapbox. All rights reserved.

import UIKit
import MapboxSearch

final class AddressAutofillMainViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var messageLabel: UILabel!
    
    private lazy var addressAutofill = AddressAutofill()
    
    private var cachedSuggestions: [AddressAutofill.Suggestion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
}

// MARK: - UISearchResultsUpdating
extension AddressAutofillMainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text,
            let query = AddressAutofill.Query(value: text)
        else {
            cachedSuggestions = []
            
            reloadData()
            return
        }
        
        addressAutofill.suggestions(for: query) { [weak self] result in
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
extension AddressAutofillMainViewController: UITableViewDataSource, UITableViewDelegate {
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

        tableViewCell.detailTextLabel?.text = suggestion.formattedAddress
        tableViewCell.detailTextLabel?.textColor = UIColor.darkGray
        tableViewCell.detailTextLabel?.numberOfLines = 2
        
        return tableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = cachedSuggestions[indexPath.row].result()
        let resultVC = AddressAutofillResultViewController.instantiate(with: result)
        
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

// MARK: - Private
private extension AddressAutofillMainViewController {
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
        searchController.searchBar.placeholder = "Type your address"
        searchController.searchBar.returnKeyType = .done

        navigationItem.searchController = searchController
    }
    
    func configureMessageLabel() {
        messageLabel.text = "Type at least \(AddressAutofill.Query.Requirements.queryLength) symbols to get Address Autofill suggestions"
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = true
    }
}
