/// Represents how the app is currently connected to the smart home mesh.
enum AppMode {
  cloudOnline,
  localNetworkOnly,
  apLocalOnly,
  offline,
}

extension AppModeDisplay on AppMode {
  String get label {
    switch (this) {
      case AppMode.cloudOnline:
        return 'Cloud Online';
      case AppMode.localNetworkOnly:
        return 'Local Network Only';
      case AppMode.apLocalOnly:
        return 'AP Local Only';
      case AppMode.offline:
        return 'Offline';
    }
  }
}
