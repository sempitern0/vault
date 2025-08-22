<div align="center">
	<img src="icon.svg" alt="Logo" width="160" height="160">

<h3 align="center">Vault</h3>

  <p align="center">
  This save system provides a convenient way to manage save files in your Godot project. It leverages the **VaultSavedGame** resource, which can be extended for your specific game data
	<br />
	·
	<a href="https://github.com/sempitern0/vault/issues/new?assignees=sempitern0&labels=%F0%9F%90%9B+bug&projects=&template=bug_report.md&title=">Report Bug</a>
	·
	<a href="https://github.com/sempitern0/vault/issues/new?assignees=sempitern0&labels=%E2%AD%90+feature&projects=&template=feature_request.md&title=">Request Features</a>
  </p>
</div>

<br>
<br>

- [📦 Installation](#-installation)
- [VaultSaveManager 💾](#vaultsavemanager-)
	- [Signals](#signals)
	- [Methods](#methods)
- [VaultSavedGame Resource](#vaultsavedgame-resource)
	- [How to save](#how-to-save)

# 📦 Installation

1. [Download Latest Release](https://github.com/sempitern0/vault/releases/latest)
2. Unpack the `addons/vault` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`

To better understand what branch to choose from for which Godot version, please refer to this table:
|Godot Version|vault Branch|vault Version|
|---|---|--|
|[![GodotEngine](https://img.shields.io/badge/Godot_4.3.x_stable-blue?logo=godotengine&logoColor=white)](https://godotengine.org/)|`4.3`|`1.x`|
|[![GodotEngine](https://img.shields.io/badge/Godot_4.4.x_stable-blue?logo=godotengine&logoColor=white)](https://godotengine.org/)|`main`|`1.x`|

# VaultSaveManager 💾

- **Multiple Save File Support:** Load and manage multiple save files stored in the user's game directory.
- **Customizable VaultSavedGame Resource:** The VaultSavedGame resource acts as a container for your game data and can be extended with your own logic.
- **Simple Saving:** Easily save game data using the `write_savegame` method on a newly created VaultSavedGame resource.
- **Efficient Loading:** Load previously saved games using the VaultSaveManager's functionality.
- **File format:** Use `.tres` format when detects that the current build is a debug build or `.res` if not.

There are 2 operations that the `VaultSaveManager` always does.

- Load the save files when ready
- Write the current save game when the game is closed.

```swift

// Load saved games in _ready
func _ready() -> void:
	list_of_saved_games.merge(read_user_saved_games(), true)


//Write the current save game when close
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if current_saved_game:
			current_saved_game.write_savegame()
```

## Signals

```swift
created_savegame(saved_game: VaultSavedGame)
loaded_savegame(saved_game: VaultSavedGame)
removed_saved_game(saved_game: VaultSavedGame)

error_creating_savegame(filename: String, error: Error)
error_loading_savegame(filename: String, error: Error)
error_removing_savegame(filename: String, error: Error)
```

## Methods

```swift
// Dictionary<String, VaultSavedGame>
@export var list_of_saved_games: Dictionary = {}
@export var current_saved_game: VaultSavedGame


func make_current(saved_game: VaultSavedGame) -> void

func create_new_save(filename: String, make_it_as_current: bool = false)

func load_savegame(filename: String) -> VaultSavedGame

func remove(filename: String)

func read_user_saved_games() -> Dictionary

func saved_game_exists(saved_game: VaultSavedGame) -> bool

func save_filename_exists(filename: String) -> bool
```

# VaultSavedGame Resource

This is the Resource that represents a save game in your project. Here is where you add new properties to save, the advantage of using resources is that it supports most types as well as being able to nest other resources.

**_It's recommended to extend this resource and set your game properties there_**

**_The dates are automatically updated in each write_**

```swift
class_name VaultSavedGame extends Resource

static var default_path: String = OS.get_user_data_dir()

@export var filename: String
@export var display_name: String
@export var version_control: String = ProjectSettings.get_setting("application/config/version", "1.0.0")
@export var engine_version: String = "Godot %s" % Engine.get_version_info().string
@export var device: String = OS.get_distribution_name()
@export var platform: String = OS.get_name()
@export var last_datetime: String = ""
@export var timestamp: float

// Write or update this resource with the filename provided.
// The filename is only needed in when it is first created
func write_savegame(new_filename: String = filename) -> Error

// This remove the resource file from the system is irreversible so be sure to use confirmation prompts in your UI before performing this action.
func delete()
```

## How to save

Here's a simplified example of saving a game:

```swift
var saved_game = VaultSavedGame.new()
saved_game.write_savegame("my_game_save") // The filename needs to be provided only in the first creation

// Updating content
saved_game.game_settings = updated_settings
saved_game.highscore = 10000

// The write_savegame method automatically creates the save file within the user's game directory.
saved_game.write_savegame()
```
