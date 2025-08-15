class_name SaveStrategyResource extends SaveStrategy


func load_file() -> IndieBlueprintSavedGame:
	if save_exists():
		var saved_file: _SavedGameResource = ResourceLoader.load(save_path(), "", ResourceLoader.CACHE_MODE_IGNORE)
		
		return IndieBlueprintSavedGame.new(
			save_file_path, 
			save_filename, 
			saved_file.data, 
			false
		)

	return null


func save_file(saved_game: IndieBlueprintSavedGame) -> bool:
	var save_game_resource: _SavedGameResource = _SavedGameResource.new(saved_game)
	var error: Error = ResourceSaver.save(save_game_resource, save_path())
	
	if error != OK:
		push_error("SaveStrategyResource: An error happened trying to save the file %s with code %s" % [save_filename, error_string(error)])
		return false
		
	return true
	

func delete_file() -> bool:
	if save_exists():
		var error: Error = DirAccess.remove_absolute(save_path())
		
		if error != OK:
			push_error("SaveStrategyResource: An error happened trying to delete the file %s with code %s" % [save_filename, error_string(error)])
			return false
			
	return true


func extension_on_save() -> String:
	return "tres" if OS.is_debug_build() else "res"


func save_exists() -> bool:
	return ResourceLoader.exists(save_path())
	
