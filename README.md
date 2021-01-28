# Sov

**Sov** is an open-source multiplayer [dreidel][dreidel] game for
mobile devices, built with [Godot][godot].

## Status

This implementation is backend-first. The game is being written in
Godotscript without graphics, and will be restructered after the fact
to facilitate the addition of graphics.

## Structure

The project's structure is based on the Godot [project
organization][organization] guidelines, and holds to the following
ASCII tree:

```
sov/
├─ src/
│  ├─ scenes/
│  │  ├─ example_scene/
│  │  │  ├─ *.tscn
│  │  │  ├─ *.gltf
│  │  │  ├─ *.material
│  │  ├─ main.tscn
│  ├─ scripts/
│  │  ├─ *.gd
├─ .gitignore
├─ COPYING
├─ README.md
├─ default_env.tres
├─ icon.png
├─ project.godot
```

## Contributing

All contributions are welcome!

## License

This project is licensed under the [AGPL][license].

[dreidel]: https://en.wikipedia.org/wiki/Dreidel
[godot]: https://godotengine.org/
[organization]: https://docs.godotengine.org/en/stable/getting_started/workflow/project_setup/project_organization.html
[license]: ./COPYING

