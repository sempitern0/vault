extends Node

@export var current_save_mode: SaveModes = SaveModes.JsonMode
@export var encrypted_key: StringName 
@export var default_path: String = "%s/saves" % OS.get_user_data_dir()

enum SaveModes {
	ResourceMode,
	JsonMode
}

var current_saved_game: IndieBlueprintSavedGame
var list_of_saved_games: Dictionary[String, IndieBlueprintSavedGame] = {}


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if current_saved_game:
			save_game(current_saved_game)


func _ready() -> void:
	read_user_saved_games()

		
func make_current(saved_game: IndieBlueprintSavedGame) -> void:
	current_saved_game = saved_game


func save_game(saved_game: IndieBlueprintSavedGame, save_mode: SaveModes = current_save_mode, _encrypted_key: StringName = encrypted_key) -> void:
	var save_strategy: SaveStrategy
	var file_path: String = saved_game.data.core.file_path
	var file_name: String = saved_game.data.core.file_name
	
	match save_mode:
		SaveModes.ResourceMode:
			save_strategy = SaveStrategyResource.new(file_path, file_name, _encrypted_key)
		SaveModes.JsonMode:
			save_strategy = SaveStrategyJson.new(file_path, file_name, _encrypted_key)
	
	save_strategy.save_file(saved_game)


func update_saved_games_list() -> void:
	pass


func read_user_saved_games(path: String = default_path, save_mode: SaveModes = current_save_mode,  _encrypted_key: StringName = encrypted_key) -> void:
	var save_directory_creation_error: Error = DirAccess.make_dir_absolute(default_path)
	
	if save_directory_creation_error not in [OK, ERR_ALREADY_EXISTS]:
		printerr(error_string(save_directory_creation_error))
		push_error("IndieBlueprintSaveManager: An error %s with code %d happened when reading user saved games" % [error_string(save_directory_creation_error), save_directory_creation_error])
	
	var save_directory: DirAccess = DirAccess.open(default_path)
	var save_directory_open_error: Error = DirAccess.get_open_error()
	
	if save_directory_open_error != OK:
		push_error("IndieBlueprintSaveManager: An error %s ocurred trying to open the save directory folder in path %s " % [error_string(save_directory_open_error), default_path])
		
	save_directory.list_dir_begin()
	var file_name: String = save_directory.get_next()
	
	list_of_saved_games.clear()
	
	while not file_name.is_empty():
		if not save_directory.current_is_dir() and file_name.get_extension() in ["json", "res", "tres"]:
			var save_strategy: SaveStrategy
		
			match save_mode:
				SaveModes.ResourceMode:
					save_strategy = SaveStrategyResource.new(path, file_name, _encrypted_key)
				SaveModes.JsonMode:
					save_strategy = SaveStrategyJson.new(path, file_name, _encrypted_key)
					
			var saved_game: IndieBlueprintSavedGame = save_strategy.load_file()
			
			list_of_saved_games[saved_game.data.core.file_name] = saved_game
		
		file_name = save_directory.get_next()
				
	save_directory.list_dir_end()
