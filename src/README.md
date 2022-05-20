# App Maker Source Files

The `src` folder holds both `Core` source code and all plugins. Under each folder there must be a `plugin_manifest.lua` which provides instructions to `AppMakerBuilder` on how to combine each plugin into the final generated Xcode project. See https://docs.appmakerios.com/#/plugin-manifest for information.

### Creating a new plugin

Run the following command:

```bash
./app-maker-builder develop new-plugin --name Example --authorId com.example
```

This will create new folder at `src/Example` with a new `plugin_manifest.lua` file.

### Testing a plugin

Simply add the plugin to your `config.appmaker.lua` and run the normal build command:

```bash
./app-maker-builder
```

### Publishing a plugin

Right now all plugins are kept in the main repository for simplicity's sake. So just commit and make a pull request.

If you have private code which you wish to use in your plugin, you can publish an XCFramework (or even a normal Framework) and then add the URL to the manifest.

Similarly, if your plugin has a very large codebase, it might be better to put the large codebase into a Swift Package and then add the Swift Package URL to the manifest. 
