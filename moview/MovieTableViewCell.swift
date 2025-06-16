//
//  MovieTableViewCell.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit

// MARK: - MovieTableViewCell
// Film listesindeki her bir film hücresini temsil eden özel tablo hücresi
// Film başlığı, yılı, posteri ve IMDB puanı için görünüm elemanları içerir
class MovieTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet var movieTitleLabel: UILabel!      // Film başlığı etiketi
    @IBOutlet var movieYearLabel: UILabel!       // Film yılı etiketi
    @IBOutlet var moviePosterImageView: UIImageView! // Film posteri görüntüsü
    @IBOutlet var ratingLabel: UILabel!          // IMDB puanı etiketi
    @IBOutlet var ratingContainerView: UIView!   // Puan container'ı
    
    // MARK: - Properties
    private let cornerRadius: CGFloat = 8
    private let shadowRadius: CGFloat = 4
    private let shadowOpacity: Float = 0.2
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Poster görüntüsü ayarları
        moviePosterImageView.layer.cornerRadius = cornerRadius
        moviePosterImageView.clipsToBounds = true
        moviePosterImageView.contentMode = .scaleAspectFill
        
        // Başlık etiketi ayarları
        movieTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        movieTitleLabel.numberOfLines = 2
        
        // Yıl etiketi ayarları
        movieYearLabel.font = UIFont.systemFont(ofSize: 14)
        movieYearLabel.textColor = .gray
        
        // Puan container ayarları
        ratingContainerView.layer.cornerRadius = cornerRadius
        ratingContainerView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
        
        // Puan etiketi ayarları
        ratingLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        ratingLabel.textColor = .darkGray
        
        // Hücre seçim rengi
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    // MARK: - Static Properties
    // Hücre tanımlayıcısı
    static let identifier: String = "MovieTableViewCell"
    
    // MARK: - Static Methods
    // Hücrenin XIB dosyasından yüklenmesi için gerekli NIB nesnesini döndürür
    static func nib() -> UINib {
        return UINib(nibName: "MovieTableViewCell", bundle: nil)
    }
    
    // MARK: - Configuration
    // Hücreyi verilen film modeli ile yapılandırır
    func configure(with model: Movie) {
        self.movieTitleLabel.text = model.Title
        self.movieYearLabel.text = model.Year
        
        // Film posteri varsa yükle
        if let url = URL(string: model.Poster) {
            // Önbelleğe alma ve yükleme işlemi
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.moviePosterImageView.image = image
                    }
                }
            }.resume()
        }
        
        // IMDB puanını göster (eğer varsa)
        if let rating = model.imdbRating {
            ratingLabel.text = "⭐️ \(rating)"
            ratingContainerView.isHidden = false
        } else {
            ratingContainerView.isHidden = true
        }
    }
    
    // MARK: - Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Seçim animasyonu
        UIView.animate(withDuration: 0.2) {
            self.transform = selected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
    }
}
