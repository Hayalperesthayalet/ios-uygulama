//
//  RegisterViewController.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import FirebaseAuth

// MARK: - RegisterViewController
// Kullanıcı kaydı işlemlerini yöneten görünüm kontrolcüsü
class RegisterViewController: UIViewController {
    
    // MARK: - IBOutlets
    // Kullanıcı arayüzü elemanlarına bağlantılar
    @IBOutlet weak var nameTextField: UITextField!     // İsim giriş alanı
    @IBOutlet weak var emailTextField: UITextField!    // E-posta giriş alanı
    @IBOutlet weak var passwordTextField: UITextField! // Şifre giriş alanı
    @IBOutlet weak var registerButton: UIButton!       // Kayıt ol butonu
    @IBOutlet weak var loginButton: UIButton!          // Giriş yap butonu
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
        // Konteyner görünümü ayarları
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemBackground
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        
        // Kayıt ol butonu ayarları
        registerButton.layer.cornerRadius = 8
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Giriş yap butonu ayarları
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        // Yükleme göstergesi
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func setupTextFields() {
        // İsim alanı ayarları
        nameTextField.layer.cornerRadius = 8
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.systemGray4.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.placeholder = "Ad Soyad"
        nameTextField.autocapitalizationType = .words
        
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
    // Kayıt ol butonuna tıklandığında
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        // Şifre uzunluğunu kontrol et
        if password.count < 6 {
            showAlert(title: "Hata", message: "Şifre en az 6 karakter olmalıdır.")
            return
        }
        
        // E-posta formatını kontrol et
        if !isValidEmail(email) {
            showAlert(title: "Hata", message: "Geçerli bir e-posta adresi girin.")
            return
        }
        
        // Butonları devre dışı bırak ve yükleme göstergesini başlat
        setLoading(true)
        
        // Firebase ile kayıt ol
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    print("Kayıt hatası: \(error.localizedDescription)")
                    self.showAlert(title: "Hata", message: "Kayıt yapılamadı: \(error.localizedDescription)")
                }
                return
            }
            
            // Kullanıcı profilini güncelle
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { error in
                DispatchQueue.main.async {
                    self.setLoading(false)
                    
                    if let error = error {
                        print("Profil güncelleme hatası: \(error.localizedDescription)")
                        self.showAlert(title: "Hata", message: "Profil güncellenemedi: \(error.localizedDescription)")
                        return
                    }
                    
                    // Ana sayfaya yönlendir
                    self.performSegue(withIdentifier: "showMain", sender: nil)
                }
            }
        }
    }
    
    // Giriş yap butonuna tıklandığında
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    // Klavyeyi kapatır
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // E-posta formatını kontrol eder
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Yükleme durumunu ayarlar
    private func setLoading(_ isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        
        registerButton.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading
        nameTextField.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
    }
    
    // Hata mesajı gösterir
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
