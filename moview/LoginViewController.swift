//
//  LoginViewController.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import FirebaseAuth

// MARK: - LoginViewController
// Kullanıcı girişi işlemlerini yöneten görünüm kontrolcüsü
// Firebase Authentication kullanarak kullanıcı girişi sağlar
class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet weak var emailTextField: UITextField!    // E-posta giriş alanı
    @IBOutlet weak var passwordTextField: UITextField! // Şifre giriş alanı
    @IBOutlet weak var loginButton: UIButton!          // Giriş butonu
    @IBOutlet weak var registerButton: UIButton!       // Kayıt ol butonu
    @IBOutlet weak var forgotPasswordButton: UIButton! // Şifremi unuttum butonu
    @IBOutlet weak var logoImageView: UIImageView!     // Uygulama logosu
    @IBOutlet weak var containerView: UIView!          // Ana konteyner görünümü
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! // Yükleme göstergesi
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Logo ayarları
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .systemBlue
        
        // Konteyner görünümü ayarları
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemBackground
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        
        // Giriş butonu ayarları
        loginButton.layer.cornerRadius = 8
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Kayıt ol butonu ayarları
        registerButton.layer.cornerRadius = 8
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Şifremi unuttum butonu ayarları
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        // Yükleme göstergesi
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func setupTextFields() {
        // E-posta alanı ayarları
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.placeholder = "E-posta"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        // Şifre alanı ayarları
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.systemGray4.cgColor
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordTextField.leftViewMode = .always
        passwordTextField.placeholder = "Şifre"
        passwordTextField.isSecureTextEntry = true
        
        // Klavye kapatma için dokunma algılama
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    // Giriş butonuna tıklandığında
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen e-posta ve şifrenizi girin.")
            return
        }
        
        // Butonları devre dışı bırak ve yükleme göstergesini başlat
        setLoading(true)
        
        // Firebase ile giriş yap
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoading(false)
                
                if let error = error {
                    print("Giriş hatası: \(error.localizedDescription)")
                    self.showAlert(title: "Hata", message: "Giriş yapılamadı: \(error.localizedDescription)")
                    return
                }
                
                // Ana sayfaya yönlendir
                self.performSegue(withIdentifier: "showMain", sender: nil)
            }
        }
    }
    
    // Kayıt ol butonuna tıklandığında
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegister", sender: nil)
    }
    
    // Şifremi unuttum butonuna tıklandığında
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen e-posta adresinizi girin.")
            return
        }
        
        // Yükleme göstergesini başlat
        loadingIndicator.startAnimating()
        
        // Şifre sıfırlama e-postası gönder
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("Şifre sıfırlama hatası: \(error.localizedDescription)")
                    self?.showAlert(title: "Hata", message: "Şifre sıfırlama e-postası gönderilemedi: \(error.localizedDescription)")
                    return
                }
                
                self?.showAlert(title: "Başarılı", message: "Şifre sıfırlama e-postası gönderildi.")
            }
        }
    }
    
    // MARK: - Helper Methods
    // Klavyeyi kapatır
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Yükleme durumunu ayarlar
    private func setLoading(_ isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        loginButton.isEnabled = !isLoading
        registerButton.isEnabled = !isLoading
        forgotPasswordButton.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }
    
    // Hata mesajı gösterir
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
