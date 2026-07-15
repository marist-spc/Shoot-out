extends Area2D

var isVisibleToMonster : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$"Heartbeat Timer".start()

func _on_heartbeat_timer_timeout() -> void:
	if !Input.is_action_pressed("hold_breath"+ str(get_parent().playerNumber)) and !get_parent().isDead and !get_parent().isOutOfBreath:
		#make heartbeat sound
		if isVisibleToMonster:
			show()
			$HeartBeat.play()
			$"Heartbeat Timer".start()
			if len(get_overlapping_bodies()) != 0:
				get_overlapping_bodies()[0].hear_noise(1, global_position, 2)
			await get_tree().create_timer(0.1).timeout
			hide()
		$"Heartbeat Timer".start()
