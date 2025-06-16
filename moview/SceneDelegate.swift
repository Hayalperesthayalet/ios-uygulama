//
//  SceneDelegate.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit

// MARK: - SceneDelegate
// SceneDelegate, uygulamanın görsel arayüzünü ve sahne yaşam döngüsünü yönetir
// iOS 13 ve sonrası için çoklu pencere desteği sağlar
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // Ana pencere referansını tutan değişken
    var window: UIWindow?

    // MARK: - Sahne Bağlantısı
    // Sahne ilk oluşturulduğunda çağrılır
    // Uygulamanın başlangıç ekranını ve navigasyon yapısını ayarlar
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Yeni bir pencere oluştur
        let window = UIWindow(windowScene: windowScene)
        // Giriş ekranını yükle
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)

        // Navigasyon kontrolcüsünü oluştur ve giriş ekranını kök görünüm olarak ayarla
        let navVC = UINavigationController(rootViewController: loginVC)

        // Pencereyi yapılandır ve görünür yap
        window.rootViewController = navVC
        self.window = window
        window.makeKeyAndVisible()
    }

    // MARK: - Sahne Yaşam Döngüsü Metodları
    
    // Sahne bağlantısı kesildiğinde çağrılır
    // Arka plana geçiş veya oturum iptali durumlarında kaynakları temizler
    func sceneDidDisconnect(_ scene: UIScene) {
        // Sahne ile ilgili kaynakları temizle
    }

    // Sahne aktif hale geldiğinde çağrılır
    // Duraklatılmış görevleri yeniden başlatmak için kullanılır
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Duraklatılmış görevleri yeniden başlat
    }

    // Sahne aktif olmaktan çıkmadan önce çağrılır
    // Geçici kesintiler (örn. gelen telefon araması) durumunda tetiklenir
    func sceneWillResignActive(_ scene: UIScene) {
        // Geçici kesinti durumunda gerekli işlemleri yap
    }

    // Sahne arka plandan ön plana geçerken çağrılır
    // Arka planda yapılan değişiklikleri geri almak için kullanılır
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Arka planda yapılan değişiklikleri geri al
    }

    // Sahne ön plandan arka plana geçerken çağrılır
    // Verileri kaydetmek ve kaynakları serbest bırakmak için kullanılır
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Verileri kaydet ve kaynakları serbest bırak
    }
}

