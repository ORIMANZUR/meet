---
description: How to deploy the app to TestFlight
---

# Deploy to TestFlight

1.  **Bump Version**: Check `pubspec.yaml` and increment the build number (after the `+`).
    - Example: `version: 1.0.0+17` -> `version: 1.0.0+18`
    - *Note: This has already been done for the current release (bumped to +17).*

2.  **Commit & Push**: Ensure all changes are committed and pushed to your repository.
    ```bash
    git add .
    git commit -m "Bump version and ready for deploy"
    git push
    ```

3.  **Build & Upload (Mac Only)**:
    If you have a Mac:
    ```bash
    flutter clean
    flutter pub get
    cd ios
    pod install
    cd ..
    flutter build ipa --release --export-options-plist=ios/Runner/ExportOptions.plist
    ```
    Then upload the generated `.ipa` using the **Transporter** app or:
    ```bash
    xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa -u <YOUR_APPLE_ID> -p <APP_SPECIFIC_PASSWORD>
    ```

4.  **CI/CD (Windows User)**:
    Since you are on Windows, you likely rely on a CI/CD pipeline (e.g., Codemagic, GitHub Actions).
    - **Action**: Pushing the code (Step 2) usually triggers the build automatically.
    - Check your CI/CD dashboard to see the build status.
