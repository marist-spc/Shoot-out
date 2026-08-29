extends Area2D


func _on_death_timer_timeout() -> void:
	queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	$DeathTimer.stop()

func _on_player_detector_body_exited(body: Node2D) -> void:
	$DeathTimer.start()
