//
//  WatchlistViewController.swift
//  moview
//
//  Created by АИДА on 16.06.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - WatchlistViewController
// Kullanıcının izleme listesini gösteren ve yöneten görünüm kontrolcüsü
// Firebase'den izleme listesi verilerini çeker ve tablo görünümünde gösterir
class WatchlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet weak var tableView: UITableView! // İzleme listesi tablosu

    // MARK: - Properties
    var watchlist: [WatchlistMovie] = [] // İzleme listesi filmleri
        
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchWatchlist()
    }
    
    // Sayfa her görünür olduğunda izleme listesini güncelle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWatchlist()
    }
    
    // MARK: - Firebase Operations
    // Kullanıcının izleme listesini Firebase'den çeker
    func fetchWatchlist() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturum açmamış veya UID yok.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("watchlist")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Watchlist alma hatası: \(error.localizedDescription)")
                    return
                }

                // Firestore dökümanlarını WatchlistMovie nesnelerine dönüştür
                self.watchlist = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    // Gerekli alanların varlığını kontrol et
                    guard let title = data["title"] as? String,
                          let poster = data["poster"] as? String,
                          let year = data["year"] as? String else {
                        print("Eksik veri: \(doc.documentID) - \(data)")
                        return nil
                    }

                    let movieID = doc.documentID
                    return WatchlistMovie(movieID: movieID, title: title, posterURL: poster, year: year)
                } ?? []

                print("Çekilen Watchlist Filmleri: \(self.watchlist.map { $0.title })")

                // Tabloyu güncelle
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - UITableViewDataSource
    // Tablo görünümü için gerekli metodlar
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = watchlist[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        cell.textLabel?.text = movie.title
        return cell
    }
}

// MARK: - WatchlistMovie
// İzleme listesindeki film bilgilerini tutan model
struct WatchlistMovie {
    let movieID: String    // Film IMDB ID'si
    let title: String      // Film başlığı
    let posterURL: String  // Film posteri URL'i
    let year: String       // Film yılı
}
