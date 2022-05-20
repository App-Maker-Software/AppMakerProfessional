# App Maker Professional
Download the [App Store version](https://apps.apple.com/us/app/app-maker-professional/id1545064329), join the community on [Discord](https://discord.gg/renuncMbbB), or visit the [website](https://www.appmakerios.com).

## An Extendable IDE for iOS / iPadOS
> Learn about customization with [Plugins](#-plugins)  



## Welcome to App Maker Professional

App Maker is an IDE designed to run on iPhones and iPads. It's built mostly in [Swift](https://www.swift.org) and [SwiftUI](https://developer.apple.com/xcode/swiftui/), although its source code includes some C, Objective C, Python, and even Lua.

Although initially intended to be an IDE specifically for iOS development with SwiftUI, App Maker is now capable of working with more programming languages and frameworks. The [core module](https://github.com/App-Maker-Software/AppMakerProfessional/tree/main/Plugins/com.appmakerios/AppMakerCore) provides public Swift protocols so that 3rd parties can add new build systems, source control systems, project templates, and more!

- [App Maker Professional](#app-maker-professional)
 - [An Extendable IDE for iOS / iPadOS](#an-extendable-ide-for-ios--ipados)
 - [Wecome to App Maker Professional](#wecome-to-app-maker-professional)
 - [Main Features](#main-features)
  - [⭐️ Live Simulator](#️-live-simulator)
  - [📱 iOS Development](#-ios-development)
  - [🎮 Game Development](#-game-development)
  - [💾 Git Support](#-git-support)
  - [👩‍💻 Customizations API](#-customizations-api)
  - [🔌 Plugins](#-plugins)
  - [💻 Partially Compile Projects](#-partially-compile-projects)
  - [🔥 Multiplayer Server](#-multiplayer-server)
 - [Getting Started](#getting-started)
  - [Custom Build](#custom-build)
  - [App Store](#app-store)
 - [Architecture](#architecture)
 - [Licensing](#licensing)
 - [Contributing to App Maker Professional](#contributing-to-app-maker-professional)

## Main Features

### ⭐️ Live Simulator
Instantly see code changes in an iPhone or iPad simulator. Choose from different models such as the iPhone 13 or iPad Pro.

### 📱 iOS Development
Use the [Swift Interpreter](https://github.com/App-Maker-Software/SwiftInterpreter) to run your iOS projects in the App Maker IDE. Or connect your device to a Mac for remote builds.

### 🎮 Game Development
Create video games using [Lua](https://www.lua.org) and [Solar2D](https://solar2d.com).

### 💾 Git Support
Connect to your GitHub or any Git host via SSH with the [Git Providers](https://github.com/App-Maker-Software/GitProviders) plugin--built on top of [SwiftGit2](https://github.com/SwiftGit2/SwiftGit2).

### 👩‍💻 Customizations API
Extend the IDE with customizations through the [Customizations API](https://docs.appmakerios.com/#/customizations). Want to add support for a language? Make a build system customization! Want to add your own text editor? Make an editor customization!

### 🔌 Plugins
Choose from a selection of App Maker plugins, or add in one of the 1,000s of plugins found at [Solar2D](http://plugins.solar2d.com) to suit your game development needs. You can also create your own via the [Customizations API](#-customizations-api).

### 💻 Partially Compile Projects
There are times when your project might have dependencies that cannot be easily compiled or linked on iOS. For example:
 1) Your project includes C source code
 2) Your project links against .a static libraries or .dylib dynamic libraries
 3) Your Solar2D game project includes [native plugins](https://docs.coronalabs.com/native/plugin/index.html#architecture) which require linking and codesigning static libraries<sup>*</sup>
 4) Your project uses frameworks such as [Firebase](https://github.com/firebase/firebase-ios-sdk) which look for a `GoogleService-Info.plist` file in the app bundle.

In any of these cases, you will want to compile these dependencies with your custom build of App Maker. In your `config.appmaker.lua`, set `partiallyCompiledProjectFolder` to the name of the folder you wish to include. Then put all files you wish to compile with App Maker at `PartiallyCompiledProjects/{YOUR_PARTIALLY_COMPILED_PROJECT_NAME}`.

<sup>*</sup>Native Solar2D plugins can be more easily integrated into your custom build as a [Plugin](#-plugins).

Note that partially compile projects are still under development. 

### 🔥 Multiplayer Server
Start live development sessions over WebSockets with your friends. Still under development.

## Getting Started

### Sideloading with Altstore

Download the latest IPA on the releases page.

https://github.com/App-Maker-Software/AppMakerProfessional/releases

Then follow instructions with https://altstore.io on how to sideload the iOS app to your device. 

### Custom Build

First clone this repository:

```bash
git clone https://github.com/App-Maker-Software/AppMakerProfessional.git
```

Then cd into the directory and run `./app-maker-builder`

```bash
cd AppMakerProfessional
./app-maker-builder
```

Follow the prompts provided by the builder. It should generate a `config.appmaker.lua` file for you. You can then open `config.appmaker.lua` to customize App Maker with [plugins](#-plugins). For game developers using Solar2D, you will want to put your native plugins under the `Solar2D` plugin with the key `solar2DPlugins`.

Once you have `config.appmaker.lua` to your liking, run `./app-maker-builder` again.

```bash
./app-maker-builder
```

This will generate and open `AppMaker.xcodeproj`. Change the signing team to your Apple ID and build!

### App Store

Don't have a Mac or don't need a custom build? Get App Maker Professional in the [App Store](https://apps.apple.com/us/app/app-maker-professional/id1545064329) right now!

## Architecture

This repo, AppMakerProfessional, is responsible for creating an Xcode project which builds and links AppMakerCore (closed source) against all plugins to produce the final iOS app. More will be detailed about the architecture later.

## Licensing

While AppMakerCore is closed source and proprietary, this repo (AppMakerProfessional) is licensed under the AGPLv3 open source license. See [LICENSE.AGPL3](https://github.com/App-Maker-Software/AppMakerProfessional/blob/main/LICENSE.AGPL3) for full text of AGPL license.

## Contributing to App Maker Professional

See [CONTRIBUTING.md](https://github.com/App-Maker-Software/AppMakerProfessional/blob/main/CONTRIBUTING.md)
