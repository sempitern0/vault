### CLASS FOR INTERNAL USE - DO NOT EXTEND OR USE IT DIRECTLY ###
class_name _SavedGameResource extends Resource

@export var data: Dictionary

func _init(saved_game: IndieBlueprintSavedGame) -> void:
	data = saved_game.data
