extends Node2D
@export var player_2_sprite : Texture
@export var winner : Sprite2D
var isWinner2 := false
# Called when the node enters the scene tree for the first time.
func show_result() -> void:
	show()
	if isWinner2:
		$"Result Scene"/Winner.texture = player_2_sprite                                                                                                                                                                            
