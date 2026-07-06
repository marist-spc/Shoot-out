extends CharacterBody2D

var isPlayerKeyboard := false
@export var playerNumber : int
@export var gun : Node2D

var Ammo : int
const SPEED = 100.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	var x = Input.get_axis(concat("left",playerNumber), concat("right",playerNumber))
	var y = Input.get_axis(concat("up",playerNumber), concat("down",playerNumber))
	var direction := Vector2(x,y)
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

	move_and_slide()
	aim()
func aim():
	if isPlayerKeyboard:
		pass

func concat(words : String, number : int):
	return words + str(number)


func _on_main_player_1_is_keyboard():
	if playerNumber == 1:
		isPlayerKeyboard = true	

func _on_pick_up_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ammo"):
		Ammo += 1
		area.queue_free()
		print(str(Ammo))
