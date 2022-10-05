<div align="center">
  <img width=200 src="docs/logo.png">
  <h1>FeatureConfig</h1>
  <p><strong>⚙️ An extensible feature flag and remote config service.</strong></p>

  <a href="https://github.com/rogerluan/FeatureConfig/actions/workflows/run_tests.yml">
    <img src="https://github.com/rogerluan/FeatureConfig/workflows/Run%20Tests/badge.svg" alt="GitHub Action Build Status" />
  </a>
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-5.3-F05138?logo=swift&logoColor=white" alt="Swift 5.3" />
  </a>
  <img src="https://img.shields.io/static/v1?label=Platforms&message=iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20Ubuntu%20&color=brightgreen" alt="Supports iOS, macOS, tvOS, watchOS and Ubuntu" />
  <a href="https://github.com/rogerluan/FeatureConfig/releases">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/rogerluan/FeatureConfig?sort=semver">
  </a>
  </br>
  <a href="https://codeclimate.com/github/rogerluan/FeatureConfig/maintainability">
    <img src="https://api.codeclimate.com/v1/badges/465cfeb965d52d65ba33/maintainability" />
  </a>
  <a href="https://codeclimate.com/github/rogerluan/FeatureConfig/test_coverage">
    <img src="https://api.codeclimate.com/v1/badges/465cfeb965d52d65ba33/test_coverage" />
  </a>
  <a href="https://twitter.com/intent/follow?screen_name=rogerluan_">
    <img src="https://img.shields.io/twitter/follow/rogerluan_?&logo=twitter" alt="Follow on Twitter">
  </a>

  <p align="center">
    <a href="https://github.com/rogerluan/FeatureConfig/issues/new/choose">Report Bug</a>
    ·
    <a href="https://github.com/rogerluan/FeatureConfig/issues/new/choose">Request Feature</a>
  </p>
</div>

# Why would I use this?

Following the principles of [iOS Factor](https://ios-factor.com), a methodology to write high-quality iOS applications, more specifically the [Config factor](https://ios-factor.com/config), there should be no configuration in code: the app must ship with a default configuration, and allow OTA updates. This package provides an entry point for those OTA updates, which can be used, for instance, to:

- Run A/B tests to enable certain features or UI changes only for a subset of the active users;
- Rotate API keys;
- Remotely disable features;
- Conduct phased rollout of features.

# Installation

Using Swift Package Manager:

```swift
dependencies: [
    .package(name: "FeatureConfig", url: "https://github.com/rogerluan/FeatureConfig", .upToNextMajor(from: "1.0.0")),
]
```

# Terminology

The concept of feature flags is widely spread and well known. Some services call them feature flags, others call it remote config, and some make a distinction between flags and configs. This package unifies all those concepts in one: _Feature Configs_, regardless of what the "config" might be, or where it's being read from: it could be a boolean (to enable/disable a feature), a string, or even a complex key-value structure, and it could also be fetched from a remote server or service, as well as be loaded from local files or static default configs.

# Usage

## Providers

FeatureConfig was implemented with extensibility by design. It consumes concrete implementations of the `Provider` protocol as its data source, and will fetch information from them upon initialization. FeatureConfig comes with only 1 provider out-of-the-box, `EphemeralProvider`, which conforms to the `MutableProvider` protocol, meaning you can modify its configs during runtime (set their values), whereas `Provider` only allows you to read from them (since they will be written to by another service). `EphemeralProvider` should be used only for debugging purposes.

For an example on how to implement your own `Provider`, see: https://github.com/rogerluan/FeatureConfig_LaunchDarkly/blob/main/Sources/LaunchDarklyProvider.swift

Here is a list of community-driven Swift Packages that were already implemented to connect to feature config services:

- [LaunchDarkly](https://launchdarkly.com): https://github.com/rogerluan/FeatureConfig_LaunchDarkly

If you have implemented a provider that other people could benefit from, feel free to open a PR modifying the list above 🤗

Here is some inspiration:

- Implementing your own solution
- JSON-based open source solutions, like [FeatureFlags](https://github.com/rwbutler/FeatureFlags)
- Proprietary services, like [Firebase Remote Config](https://firebase.google.com/docs/remote-config)
- Proprietary services that allow running on-prem, like [Flagsmith](https://flagsmith.com)

## Initializing

Once you have implemented your providers, it's time to initialize FeatureConfig:

```swift
import FeatureConfig
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var providers: [Provider] = [ /* Configure your providers here */ ]
        #if DEBUG
        providers.append(EphemeralProvider())
        #endif
        FeatureConfig.initialize(providers: providers)
        return true
    }

    // […]
}
```

## Reading Configs

When implementing a feature, you should strive to always put this feature behind a feature config. This config should generally be "disabled" by default, while you enable it on your server-side service. This provides a _safe_ way to ship new features, run A/B tests on them, or even conduct a phased rollout.

To add a new feature config, use the `@Feature` property wrapper in an instance or static variable, as needed. For example:

```swift
import FeatureConfig

class MyView {
    @Feature("is_super_like_enabled", default: false) private var isSuperLikeEnabled: Bool

    func setUpSuperLike() {
        guard isSuperLikeEnabled else { return }
        view.addSubview(superLikeButton)
    }
}
```

Notice how easy it is to put your entire feature behind a feature config. It's a one-liner to configure it, and another one-liner to use it.

The `@Feature` property wrapper takes two arguments:

```swift
/// Instantiates a feature config property wrapper.
/// - Parameters:
///   - key: the key of this feature config, as configured in the providers' end.
///   - defaultExpression: the fallback value of this feature, in case none of the providers are able to
///   provide a valid value for this feature during runtime. This expression is evaluated only when and if needed.
public init(_ key: String, default defaultExpression: @autoclosure @escaping () -> Value)
```

The `Value` of a feature config must conform to `Codable`, thus it can be any of the existing Foundation types that already conform to `Codable`, but also more complex [`JSEN`](https://github.com/rogerluan/JSEN) values, and even custom structures, as long as conformance to `Codable` is put in place.

## Observing Changes

You can observe changes of your providers' `configs` instance properties as well as `FeatureConfig`'s shared instance, using Combine observers, as `configs` is a `CurrentValueSubject`. This is the designed way to know when the config values have been updated.

# Architecture Decisions

## Lifecycle

The lifecycle of a feature config value goes as follows:

1. On the user's first app launch (right after install), the app doesn't know anything about remote feature configs, thus the binary is shipped with enough information so that it can be used without the need to download extra resources from remote servers (such as config settings, API keys, etc). This is in accordance to the [iOS Factor's "Prefer local over Remote" factor](https://ios-factor.com/prefer-local-over-remote), where it's stipulated that the app should be smart enough to operate without a backend where possible, and that we should never assume a user has a working internet connection on the first launch of the app.
2. Once the app reaches internet connection for the first time, it will fetch remote configurations for its feature config providers. This information presumably cached (by the service itself, not FeatureConfig) and from then on, any further "offline interactions" will use the latest known cached config values.
3. The responsibility of fetching the values from your service belongs to the provider. Thus, determining _when_ it should fetch the remote values (e.g. during app launch, or when a different user authenticates) is the app's responsibility, by calling, for instance a `refresh()` method on the provider, when needed.

## Real-time Updates

The feature config system was specifically designed to prevent feature configs from receiving remote updates during runtime as much as possible. This means it actively prevents configs from receiving updates via real-time mechanisms such as websocket events. This is because the higher the chance the feature configs have to change during any arbitrary moment in the app's lifecycle, the more likely it is for a user to get into a unpredictable state. This way we attempt to eliminate an entire class of bugs that would be hard to understand, reproduce and debug.

## Caching

FeatureConfig doesn't implement caching on its own. Caching is usually built by SDKs of services being used (which map to your providers), so this usually means there's no need to implement a secondary caching mechanism. If the services being used don't implement a caching mechanism, you may implement one in your provider.

# Resources

For an introduction to the concept of feature configs, see: https://betterprogramming.pub/feature-configs-5ff6be0a4568

Other interesting resources:

- https://andreaslydemann.com/clean-ios-architecture-for-feature-toggling/
- https://jeroenmols.com/blog/2019/09/12/FeatureConfigsarchitecture/
- https://martinfowler.com/articles/feature-toggles.html

# Contributions

If you spot something wrong, missing, or if you'd like to propose improvements to this project, please open an Issue or a Pull Request with your ideas and I promise to get back to you within 24 hours! 😇

# License

This project is open source and covered by a standard 2-clause BSD license. That means you can use (publicly, commercially and privately), modify and distribute this project's content, as long as you mention **Roger Oba** as the original author of this code and reproduce the LICENSE text inside your app, repository, project or research paper.

# Contact

Twitter: [@rogerluan_](https://twitter.com/rogerluan_)
