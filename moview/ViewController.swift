//
//  ViewController.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import SafariServices

// MARK: - Global Variables
// Önerilen filmler listesi
var suggestedMovies: [Movie] = []
// Arama modunda olup olmadığını kontrol eden bayrak
var isSearching = false

// MARK: - ViewController
// Ana görünüm kontrolcüsü
// Film arama ve önerilen filmleri gösterme işlevlerini yönetir
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet var table: UITableView!  // Film listesi tablosu
    @IBOutlet var field: UITextField!  // Arama alanı
    
    // MARK: - Properties
    var movies = [Movie]() // Arama sonuçları için film dizisi
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Tablo hücresini kaydet ve delegeleri ayarla
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        field.delegate = self
        
        // Önerilen filmleri yükle
        loadSuggestions()
    }
    
    // MARK: - UITextFieldDelegate
    // Arama alanı için gerekli metodlar
    
    // Enter tuşuna basıldığında aramayı başlat
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isSearching = true
        searchMovies()
        return true
    }

    // Arama alanı boşaltıldığında önerilen filmleri göster
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            isSearching = false
            table.reloadData()
        }
    }

    // MARK: - API Calls
    // OMDB API'den film araması yapar
    func searchMovies() {
        field.resignFirstResponder()
        
        guard let text = field.text, !text.isEmpty else {
            return
        }
        
        let query = text.replacingOccurrences(of: " ", with: "%20")
        movies.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=7932d64a&s=\(query)")!, completionHandler: {data, response, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            // JSON verisini MovieResult nesnesine dönüştür
            var result: MovieResult?
            do {
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            }
            catch {
                print("error")
            }
            
            guard let finalResult = result else {
                return
            }
            
            // Arama sonuçlarını güncelle
            let newMovies = finalResult.Search
            self.movies.append(contentsOf: newMovies)
            
            // Tabloyu güncelle
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }).resume()
    }
    
    // MARK: - UITableViewDataSource
    // Tablo görünümü için gerekli metodlar
    
    // Tablo satır sayısını döndür
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? movies.count : suggestedMovies.count
    }

    // Tablo hücresini yapılandır
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        let movie = isSearching ? movies[indexPath.row] : suggestedMovies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }

    // MARK: - UITableViewDelegate
    // Tablo seçim işlemleri
    
    // Film seçildiğinde detay sayfasına yönlendir
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMovie = isSearching ? movies[indexPath.row] : suggestedMovies[indexPath.row]
        let detailVC = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
        detailVC.imdbID = selectedMovie.imdbID
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Helper Methods
    // Önerilen filmleri yükler
    func loadSuggestions() {
        let keywords = ["batman", "harry potter", "avengers", "inception", "matrix"]
        suggestedMovies.removeAll()

        let group = DispatchGroup()

        // Her anahtar kelime için film araması yap
        for keyword in keywords {
            group.enter()
            let query = keyword.replacingOccurrences(of: " ", with: "%20")
            guard let url = URL(string: "https://www.omdbapi.com/?apikey=7932d64a&s=\(query)") else {
                group.leave()
                continue
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }

                guard let data = data, error == nil else {
                    return
                }

                do {
                    let result = try JSONDecoder().decode(MovieResult.self, from: data)
                    // Her arama için ilk 2 filmi ekle
                    suggestedMovies.append(contentsOf: result.Search.prefix(2))
                } catch {
                    print("Decoding failed for keyword: \(keyword)")
                }
            }.resume()
        }

        // Tüm aramalar tamamlandığında tabloyu güncelle
        group.notify(queue: .main) {
            self.table.reloadData()
        }
    }
}

// MARK: - Models
// API yanıtı için model
struct MovieResult: Codable {
    let Search: [Movie]
}

// Film bilgileri için model
struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String
    let imdbRating: String?
    
    private enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, _Type = "Type", Poster, imdbRating
    }
}
