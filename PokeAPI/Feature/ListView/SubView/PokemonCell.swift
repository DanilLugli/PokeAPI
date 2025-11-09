//
//  PokemonCell.swift
//  PokeAPI
//
//  Created by Danil Lugli on 11/9/25.
//



import UIKit

class PokemonCell: UITableViewCell {
    
    private let imageContainer = UIView()
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
        
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageContainer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        pokemonImage.translatesAutoresizingMaskIntoConstraints = false
        pokemonImage.contentMode = .scaleAspectFit
        pokemonImage.clipsToBounds = true
        
        imageContainer.addSubview(pokemonImage)
        
        NSLayoutConstraint.activate([
            pokemonImage.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            pokemonImage.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            pokemonImage.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
            pokemonImage.heightAnchor.constraint(lessThanOrEqualToConstant: 70)
        ])
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        typeStack.axis = .horizontal
        typeStack.spacing = 6
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        let infoStack = UIStackView(arrangedSubviews: [
            nameLabel,
            typeStack,
            descriptionLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.alignment = .leading
        
        let hStack = UIStackView(arrangedSubviews: [imageContainer, infoStack])
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .top
        
        let mainStack = UIStackView(arrangedSubviews: [hStack, divider])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with model: DataModel) {
        
        nameLabel.text = model.name
        
        typeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for type in model.types {
            let label = PaddingLabel()
            label.text = type.capitalized
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .label
            label.backgroundColor = UIColor.systemGray5
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
            label.textAlignment = .center
            typeStack.addArrangedSubview(label)
        }
        
        descriptionLabel.text = model.abilities
        
        if let url = URL(string: model.imageURL) {
            downloadImage(url: url)
        }
    }
    
    private func downloadImage(url: URL) {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        pokemonImage.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: pokemonImage.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: pokemonImage.centerYAnchor)
        ])
        spinner.startAnimating()
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    self.pokemonImage.image = UIImage(data: data)
                }
            } else {
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                }
            }
        }.resume()
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
}

class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
