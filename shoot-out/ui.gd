extends CanvasLayer

func change_player_name(name : String):
	$PlayerName.Text = name

func add_ammo():
	for key in $Ammo.get_children():
		if key.visible:
			continue
		key.show()
		break
		
func remove_ammo():
	var keys := $Ammo.get_children()
	keys.reverse()
	for key in keys:
		if key.visible:
			key.hide()
			break

func add_key():
	for key in $Keys.get_children():
		if key.visible:
			continue
		key.show()
		break

func remove_keys():
	var keys = $Keys.get_children()
	for key in keys:
		key.hide()
		
func reset_breath():
	$Breath.value = 100
func add_breath(num : float):
	$Breath.value += num
func remove_breath(num : float):
	$Breath.value -= num
func get_breath():
	return $Breath.value
