import Flutter
import UIKit
// import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase BEFORE plugin registration
    // FirebaseApp.configure()
    
    // GMSServices.provideAPIKey("AIzaSyDtkiRSCRJgGQ9eKmbaeg9_GwcXY3Gvv4M")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
