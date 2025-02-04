// Copyright © 2023 Mapbox. All rights reserved.

import UIKit
import MapboxSearch
import MapKit

final class PlaceAutocompleteResultViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var mapView: MKMapView!
    
    private var result: PlaceAutocomplete.Result!
    private var resultComponents: [(name: String, value: String)] = []
    
    static func instantiate(with result: PlaceAutocomplete.Result) -> PlaceAutocompleteResultViewController {
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: .main
        )

        let viewController = storyboard.instantiateViewController(
            withIdentifier: "PlaceAutocompleteResultViewController"
        ) as? PlaceAutocompleteResultViewController
        
        guard let viewController = viewController else {
            preconditionFailure()
        }
        
        viewController.result = result
        viewController.resultComponents = result.toComponents()
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepare()
    }
}

// MARK: - TableView data source
extension PlaceAutocompleteResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        result == nil ? .zero : resultComponents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "result-cell"
        
        let tableViewCell: UITableViewCell
        if let cachedTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            tableViewCell = cachedTableViewCell
        } else {
            tableViewCell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        let component = resultComponents[indexPath.row]

        tableViewCell.textLabel?.text = component.name
        tableViewCell.detailTextLabel?.text = component.value
        tableViewCell.detailTextLabel?.textColor = UIColor.darkGray
        
        return tableViewCell
    }
}

// MARK: - Private
private extension PlaceAutocompleteResultViewController {
    func prepare() {
        title = "Address"

        updateScreenData()
    }
    
    func updateScreenData() {
        showAnnotation()
        showSuggestionRegion()
        
        tableView.reloadData()
    }
    
    func showAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = result.coordinate
        annotation.title = result.name

        mapView.addAnnotation(annotation)
    }
    
    func showSuggestionRegion() {
        guard result != nil else { return }
        
        let region = MKCoordinateRegion(
            center: result.coordinate,
            span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Private
private extension PlaceAutocomplete.Result {
    func toComponents() -> [((name: String, value: String))] {
        var components = [
            (name: "Name", value: name),
            (name: "Type", value: "\(type == .POI ? "POI" : "Address")")
        ]
        
        if let address = address, let formattedAddress = address.formattedAddress(style: .short) {
            components.append(
                (name: "Address", value: formattedAddress)
            )
        }
        
        if let phone = phone {
            components.append(
                (name: "Phone", value: phone)
            )
        }
        
        if let reviewsCount = reviewCount {
            components.append(
                (name: "Reviews Count", value: "\(reviewsCount)")
            )
        }
        
        if let avgRating = averageRating {
            components.append(
                (name: "Rating", value: "\(avgRating)")
            )
        }
        
        if !categories.isEmpty {
            let categories = categories.count > 2 ? Array(categories.dropFirst(2)) : categories
            
            components.append(
                (name: "Categories", value: categories.joined(separator: ","))
            )
        }
        
        return components
    }
}
