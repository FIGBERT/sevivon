# Sevivon

**Sevivon** is an open-source multiplayer [dreidel][dreidel] game for
mobile devices, built with [Godot][godot].

## Installation

Sevivon will be available for download on your mobile device via the
App Store for iOS as well as the Google Play Store and F-Droid for
Android.

To install for development, install [Godot][godot] and clone the
repository:

```bash
git clone https://git.figbert.com/FIGBERT/sevivon.git
```

## Compiling

Sevivon is available for iOS and Android, though it technically could
be modified to run on any platform supported by Godot.

### Compiling for iOS

To compile for iOS, [export the project][ios-export] from Godot to
Xcode following the official documentation. Add assets (icons, launch
screens, etc) accordingly.

### Compiling for Android

Documentation coming soon.

## Structure

The project's structure is based on the Godot [project
organization][organization] guidelines, and holds to the following
ASCII tree:

```
sevivon/
├─ assets/
│  ├─ *.svg
│  ├─ *.png
│  ├─ *.jpeg
│  ├─ *.sketch
├─ blender/
│  ├─ *.blend
├─ godot/
│  ├─ scenes/
│  │  ├─ example_scene/
│  │  │  ├─ *.tscn
│  │  │  ├─ *.gltf
│  │  │  ├─ *.material
│  │  ├─ main.tscn
│  ├─ scripts/
│  │  ├─ *.gd
│  ├─ default_env.tres
│  ├─ project.godot
├─ .gitattributes
├─ .gitignore
├─ COPYING
├─ README.md
```

The `assets` directory contains two-dimensional graphics like app
icons, launch screens, and app previews. The `blender` directory
contains three-dimensional design files created in [Blender][blend].

In the `godot` directory, the `scenes` directory contains the
main scene file and several subdirectories. Per the Godot guidelines,
files are organized "as close to scenes as possible." Certain
subdirectories, like `sevivon` and `hanukkiah`, contain their
own subdirectories to organize different in-game skins. The
`scripts` directory, as the name would imply, contains the
project's Godotscript files.

## Contributing

Reporting issues and opening pull requests are welcomed.

## License

This project is licensed under the [AGPL][license].

[dreidel]: https://en.wikipedia.org/wiki/Dreidel
[godot]: https://godotengine.org/
[ios-export]: https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_ios.html
[ios-compile]: https://docs.godotengine.org/en/stable/development/compiling/compiling_for_ios.html
[organization]: https://docs.godotengine.org/en/stable/getting_started/workflow/project_setup/project_organization.html
[blend]: https://www.blender.org/
[license]: ./COPYING

