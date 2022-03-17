# expo-eas-app-extension-test

1. Replace `com.tylerchurch.expoeasappextensiontest` in this project with a unique identifier that is usable by your
   Apple Developer account.
2. `npm install`
3. `expo prebuild`
4. It will likely fail due to the identifier not having the SiriKit capability. Open up https://developer.apple.com and
   add the SiriKit capability.
5. `rm -rf ios; expo run:ios --no-build-cache`
6. The app should now be running, displaying a message like `Shortcuts says: null`. If you open the Apple Shortcuts app
   and add a shortcut that uses the app, you'll see the data appear when you run it.
7. `eas build -p ios` - This will fail in the archive step will a code signing error.
