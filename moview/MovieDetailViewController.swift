//
//  MovieDetailViewController.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - MovieDetailViewController
// Film detaylarını, yorumları ve izleme listesi işlemlerini yöneten görünüm kontrolcüsü
// OMDB API'den film bilgilerini çeker ve Firebase'de yorumları saklar
class MovieDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet var titleLabel: UILabel!        // Film başlığı
    @IBOutlet var posterImageView: UIImageView! // Film posteri
    @IBOutlet var plotLabel: UILabel!         // Film özeti
    @IBOutlet var infoLabel: UILabel!         // Film bilgileri (yıl, tür, yönetmen, puan)
    @IBOutlet weak var tableView: UITableView! // Yorumlar tablosu
    @IBOutlet weak var commentField: UITextField! // Yorum giriş alanı
    @IBOutlet weak var sendButton: UIButton!   // Yorum gönderme butonu
    @IBOutlet weak var watchlistButton: UIButton! // İzleme listesi butonu
    @IBOutlet weak var ratingView: UIView!     // Puan görünümü
    @IBOutlet weak var ratingLabel: UILabel!   // Puan etiketi
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! // Yükleme göstergesi
    
    // MARK: - Properties
    var imdbID: String?           // Film IMDB ID'si
    var comments: [Comment] = []  // Film yorumları dizisi
    var movie: MovieDetail?       // Film detay bilgileri
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchMovieDetail()
        fetchComments()
        checkWatchlistStatus()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Başlık etiketi ayarları
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        
        // Poster görüntüsü ayarları
        posterImageView.layer.cornerRadius = 12
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
        
        // Özet etiketi ayarları
        plotLabel.font = UIFont.systemFont(ofSize: 16)
        plotLabel.numberOfLines = 0
        
        // Bilgi etiketi ayarları
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = .gray
        
        // Yorum alanı ayarları
        commentField.layer.cornerRadius = 8
        commentField.layer.borderWidth = 1
        commentField.layer.borderColor = UIColor.systemGray4.cgColor
        commentField.placeholder = "Yorumunuzu yazın..."
        
        // Gönder butonu ayarları
        sendButton.layer.cornerRadius = 8
        sendButton.backgroundColor = .systemBlue
        sendButton.setTitleColor(.white, for: .normal)
        
        // İzleme listesi butonu ayarları
        watchlistButton.layer.cornerRadius = 8
        watchlistButton.backgroundColor = .systemGreen
        watchlistButton.setTitleColor(.white, for: .normal)
        
        // Puan görünümü ayarları
        ratingView.layer.cornerRadius = 8
        ratingView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Yükleme göstergesi
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
    }
    
    // MARK: - API Calls
    // OMDB API'den film detaylarını çeker
    func fetchMovieDetail() {
        guard let imdbID = imdbID else { return }
        
        loadingIndicator.startAnimating()
        
        let urlStr = "https://www.omdbapi.com/?apikey=7932d64a&i=\(imdbID)"
        guard let url = URL(string: urlStr) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MovieDetail.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: result)
                    self.loadingIndicator.stopAnimating()
                }
            } catch {
                print("Decode hatası: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }.resume()
    }
    
    // MARK: - UI Updates
    // Film bilgilerini arayüzde gösterir
    func updateUI(with movie: MovieDetail) {
        self.movie = movie
        titleLabel.text = movie.Title
        plotLabel.text = movie.Plot
        
        // Film bilgilerini formatla
        infoLabel.text = """
                Yıl: \(movie.Year)
                Tür: \(movie.Genre)
                Yönetmen: \(movie.Director)
                """
        
        // IMDB puanını göster
        ratingLabel.text = "⭐️ \(movie.imdbRating)"
        
        // Film posteri varsa yükle
        if let url = URL(string: movie.Poster) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Comment Actions
    // Yorum gönderme butonuna tıklandığında çağrılır
    @IBAction func didTapSendComment(_ sender: UIButton) {
        guard let text = commentField.text, !text.isEmpty else { return }
        
        // Butonu devre dışı bırak ve yükleme göstergesini başlat
        sendButton.isEnabled = false
        loadingIndicator.startAnimating()
        
        saveCommentToFirestore(text)
        commentField.text = ""
    }
    
    // Yorumu Firebase'e kaydeder
    func saveCommentToFirestore(_ commentText: String) {
        guard let user = Auth.auth().currentUser,
              let imdbID = imdbID else { return }
        
        let db = Firestore.firestore()
        let doc: [String: Any] = [
            "user": user.email ?? "anon",
            "comment": commentText,
            "timestamp": Timestamp(),
            "movieID": imdbID
        ]
        
        db.collection("comments").addDocument(data: doc) { [weak self] error in
            DispatchQueue.main.async {
                self?.sendButton.isEnabled = true
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("Yorum ekleme hatası: \(error.localizedDescription)")
                    // Hata mesajı göster
                    self?.showAlert(title: "Hata", message: "Yorum eklenirken bir hata oluştu.")
                } else {
                    print("Yorum başarıyla kaydedildi")
                    self?.fetchComments()
                }
            }
        }
    }
    
    // MARK: - Firebase Operations
    // Film yorumlarını Firebase'den çeker
    func fetchComments() {
        guard let imdbID = imdbID else { return }
        
        loadingIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("comments")
            .whereField("movieID", isEqualTo: imdbID)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    
                    if let error = error {
                        print("Yorumları alma hatası: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    self.comments = documents.compactMap { doc in
                        let data = doc.data()
                        let user = data["user"] as? String ?? "anonim"
                        let text = data["comment"] as? String ?? ""
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        return Comment(user: user, text: text, timestamp: timestamp)
                    }
                    
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Watchlist Actions
    // İzleme listesi butonuna tıklandığında çağrılır
    @IBAction func didTapWatchlist(_ sender: UIButton) {
        guard let imdbID = imdbID,
              let userID = Auth.auth().currentUser?.uid,
              let movie = self.movie else { return }
        
        // Butonu devre dışı bırak
        watchlistButton.isEnabled = false
        
        let db = Firestore.firestore()
        let watchlistRef = db.collection("users").document(userID).collection("watchlist").document(imdbID)
        
        watchlistRef.getDocument { [weak self] doc, error in
            guard let self = self else { return }
            
            if let doc = doc, doc.exists {
                // Film zaten listede, listeden çıkar
                watchlistRef.delete { err in
                    DispatchQueue.main.async {
                        self.watchlistButton.isEnabled = true
                        
                        if err == nil {
                            print("Watchlist'ten çıkarıldı")
                            self.watchlistButton.setTitle("+ Watchlist", for: .normal)
                            self.watchlistButton.backgroundColor = .systemGreen
                        } else {
                            self.showAlert(title: "Hata", message: "Film listeden çıkarılırken bir hata oluştu.")
                        }
                    }
                }
            } else {
                // Filmi listeye ekle
                let movieData: [String: Any] = [
                    "title": movie.Title,
                    "year": movie.Year,
                    "poster": movie.Poster
                ]
                watchlistRef.setData(movieData) { err in
                    DispatchQueue.main.async {
                        self.watchlistButton.isEnabled = true
                        
                        if err == nil {
                            print("Watchlist'e eklendi")
                            self.watchlistButton.setTitle("✓ Watchlisted", for: .normal)
                            self.watchlistButton.backgroundColor = .systemGray
                        } else {
                            self.showAlert(title: "Hata", message: "Film listeye eklenirken bir hata oluştu.")
                        }
                    }
                }
            }
        }
    }
    
    // İzleme listesi durumunu kontrol eder
    func checkWatchlistStatus() {
        guard let imdbID = imdbID else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        loadingIndicator.startAnimating()
        
        let ref = Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("watchlist")
            .document(imdbID)
        
        ref.getDocument { [weak self] doc, _ in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if doc?.exists == true {
                    self?.watchlistButton.setTitle("✓ Watchlisted", for: .normal)
                    self?.watchlistButton.backgroundColor = .systemGray
                } else {
                    self?.watchlistButton.setTitle("+ Watchlist", for: .normal)
                    self?.watchlistButton.backgroundColor = .systemGreen
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    // Hata mesajı gösterir
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView Extension
// Tablo görünümü için gerekli metodlar
extension MovieDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CommentCell")
        
        // Hücre görünümünü özelleştir
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.textLabel?.text = comment.user
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.text = comment.text
        cell.detailTextLabel?.numberOfLines = 0
        
        // Tarih formatı
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: comment.timestamp)
        
        // Hücre alt başlığına tarih ekle
        cell.detailTextLabel?.text = "\(comment.text)\n\n\(dateString)"
        
        return cell
    }
}

// MARK: - Models
// Film detayları için model
struct MovieDetail: Codable {
    let Title: String
    let Year: String
    let Genre: String
    let Director: String
    let Plot: String
    let Poster: String
    let imdbRating: String
}

// Yorum modeli
struct Comment {
    let user: String
    let text: String
    let timestamp: Date
}
