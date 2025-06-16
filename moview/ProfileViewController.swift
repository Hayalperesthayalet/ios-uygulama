//
//  ProfileViewController.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - ProfileViewController
// Kullanıcı profilini ve ayarlarını yöneten görünüm kontrolcüsü
class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet weak var emailLabel: UILabel!        // Kullanıcı e-posta adresi
    @IBOutlet weak var watchlistCountLabel: UILabel! // İzleme listesi sayısı
    @IBOutlet weak var commentCountLabel: UILabel!  // Yorum sayısı
    @IBOutlet weak var profileImageView: UIImageView! // Profil resmi
    @IBOutlet weak var nameLabel: UILabel!         // Kullanıcı adı
    @IBOutlet weak var statsContainerView: UIView! // İstatistikler konteyneri
    @IBOutlet weak var settingsButton: UIButton!   // Ayarlar butonu
    @IBOutlet weak var logoutButton: UIButton!     // Çıkış butonu
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! // Yükleme göstergesi
    
    // MARK: - Properties
    private var watchlistCount = 0
    private var commentCount = 0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Profil resmi ayarları
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5
        
        // İsim etiketi ayarları
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        
        // E-posta etiketi ayarları
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .secondaryLabel
        
        // İstatistik konteyneri ayarları
        statsContainerView.layer.cornerRadius = 12
        statsContainerView.backgroundColor = .systemBackground
        statsContainerView.layer.shadowColor = UIColor.black.cgColor
        statsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsContainerView.layer.shadowRadius = 4
        statsContainerView.layer.shadowOpacity = 0.1
        
        // İstatistik etiketleri ayarları
        watchlistCountLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        commentCountLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        // Buton ayarları
        settingsButton.layer.cornerRadius = 8
        settingsButton.backgroundColor = .systemBlue
        settingsButton.setTitleColor(.white, for: .normal)
        
        logoutButton.layer.cornerRadius = 8
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        
        // Yükleme göstergesi
        loadingIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Data Loading
    // Kullanıcı verilerini yükler
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        loadingIndicator.startAnimating()
        
        // Kullanıcı bilgilerini göster
        emailLabel.text = user.email
        nameLabel.text = user.displayName ?? "Kullanıcı"
        
        // Profil resmini yükle
        if let photoURL = user.photoURL {
            URLSession.shared.dataTask(with: photoURL) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                        self?.loadingIndicator.stopAnimating()
                    }
                }
            }.resume()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    // İstatistikleri günceller
    private func updateStats() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        loadingIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // İzleme listesi sayısını al
        db.collection("users").document(userID).collection("watchlist")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Watchlist sayısı alınamadı: \(error.localizedDescription)")
                    return
                }
                
                self?.watchlistCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.watchlistCountLabel.text = "\(self?.watchlistCount ?? 0)"
                }
            }
        
        // Yorum sayısını al
        db.collection("comments")
            .whereField("user", isEqualTo: Auth.auth().currentUser?.email ?? "")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Yorum sayısı alınamadı: \(error.localizedDescription)")
                    return
                }
                
                self?.commentCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.commentCountLabel.text = "\(self?.commentCount ?? 0)"
                    self?.loadingIndicator.stopAnimating()
                }
            }
    }
    
    // MARK: - Actions
    // Ayarlar butonuna tıklandığında
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        // Ayarlar sayfasına git
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    // Çıkış butonuna tıklandığında
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Çıkış yapmak istediğinizden emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            do {
                try Auth.auth().signOut()
                // Giriş sayfasına yönlendir
                self?.performSegue(withIdentifier: "showLogin", sender: nil)
            } catch {
                print("Çıkış yapılamadı: \(error.localizedDescription)")
                self?.showAlert(title: "Hata", message: "Çıkış yapılırken bir hata oluştu.")
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    // Hata mesajı gösterir
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
