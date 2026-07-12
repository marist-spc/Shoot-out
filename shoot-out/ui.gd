extends Node2D

func change_player_name(name : String):
	$PlayerName.Text = name

func add_key():
	for key in $CanvasGroup/Keys.get_children():
		if key.is_node_visible_in_scene_tree:
			continue
		key.show()
		break

func remove_key():
	var keys = $CanvasGroup/Keys.get_children()
	keys.reverse()
	for key in keys:
		if key.is_node_visible_in_scene_tree:
			key.hide()
			break
func add_breath(num : float):
	$CanvasGroup/Breath.value += num
func remove_breath(num : float):
	$CanvasGroup/Breath.value -= num
func get_breath():
	return $CanvasGroup/Breath.value
