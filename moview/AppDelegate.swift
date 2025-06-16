//
//  AppDelegate.swift
//  moview
//
//  Created by АИДА on 1.06.2025.
//

import UIKit
import FirebaseCore

// MARK: - AppDelegate
// AppDelegate, uygulamanın yaşam döngüsünü yöneten ana sınıftır.
// Uygulama başlatma, arka plana geçiş, ön plana dönüş gibi olayları yönetir.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Ana pencere referansını tutan değişken
    var window: UIWindow?

    // MARK: - Uygulama Başlatma
    // Uygulama ilk başlatıldığında çağrılan fonksiyon
    // Firebase yapılandırmasını başlatır
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
                       [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure() // Firebase servislerini başlatır
        return true
    }

    // MARK: - UISceneSession Yaşam Döngüsü
    // Yeni bir sahne oturumu oluşturulduğunda çağrılır
    // Sahne yapılandırmasını döndürür
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Kullanıcı bir sahne oturumunu iptal ettiğinde çağrılır
    // İptal edilen sahnelerle ilgili kaynakları temizler
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

