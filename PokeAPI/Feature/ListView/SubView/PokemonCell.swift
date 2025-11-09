//
//  PokemonCell.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/9/25.
//



import UIKit

class PokemonCell: UITableViewCell {

    private let pokemonImage = UIImageView()
    private let nameLabel = UILabel()
    private let typeStack = UIStackView()
    private let descriptionLabel = UILabel()
    private let divider = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        pokemonImage.contentMode = .scaleAspectFill
        pokemonImage.clipsToBounds = true

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        typeStack.axis = .horizontal
        typeStack.spacing = 6

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        let mainStack = UIStackView(arrangedSubviews: [
            createHorizontalStack(),
            divider
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func createHorizontalStack() -> UIStackView {
        let leftStack = UIStackView(arrangedSubviews: [pokemonImage])
        leftStack.axis = .vertical
        leftStack.alignment = .leading

        pokemonImage.widthAnchor.constraint(equalToConstant: 90).isActive = true
        pokemonImage.heightAnchor.constraint(equalToConstant: 90).isActive = true

        let infoStack = UIStackView(arrangedSubviews: [
            nameLabel,
            typeStack,
            descriptionLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .leading

        let hStack = UIStackView(arrangedSubviews: [leftStack, infoStack])
        hStack.axis = .horizontal
        hStack.spacing = 16
        return hStack
    }

    func configure(with model: DataModel) {

        nameLabel.text = model.name

        typeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in model.types {
            let label = UILabel()
            label.text = type.capitalized
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .label
            label.backgroundColor = UIColor.systemGray5
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.textAlignment = .center
            label.heightAnchor.constraint(equalToConstant: 22).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
            typeStack.addArrangedSubview(label)
        }

        descriptionLabel.text = model.abilities

        if let url = URL(string: model.imageURL) {
            downloadImage(url: url)
        }
    }

    private func downloadImage(url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.pokemonImage.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
