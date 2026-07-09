extends CharacterBody2D

@export var isPlayerKeyboard := false
@export var player1isKeyboard : = true	
@export var playerNumber : int

@export var curserSens := 1

@export var health := 2

var Ammo : int
const SPEED = 300
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
	aim(delta)
func aim(delta : int):
	var shootButton
	if isPlayerKeyboard:
		$CrossHair.global_position = get_viewport().get_mouse_position()
		shootButton = Input.is_action_just_pressed("mouse_click")
	else:
		var x = Input.get_axis(concat("aim_left",playerNumber), concat("aim_right",playerNumber))
		var y = Input.get_axis(concat("aim_up",playerNumber), concat("aim_down",playerNumber))
		var direction := Vector2(x,y)
		var device = 1 if player1isKeyboard else 2
		shootButton = Input.is_action_just_pressed(concat("shoot", device))
		if direction != Vector2.ZERO:
			$CrossHair.hide()
			$CrossHair.global_position = position + direction.normalized() * curserSens	
	$Gun.look_at($CrossHair.global_position)
	
	if shootButton and Ammo != 0:
		var collision = $"Gun/Bullet Path".get_collider()
		Ammo -= 1
		if collision != null:
			$"Gun/Line2D".add_point($Gun/Tip.position)
			$"Gun/Line2D".add_point($Gun/Line2D.to_local(collision.global_position))
			$"Gun/Line2D/BulletTime".start()
			
			if collision.is_in_group("Players"):
				collision.health -= 1
				print("HIT PLAYER")
		else:
			$"Gun/Line2D".add_point($Gun/Tip.position)
			$"Gun/Line2D".add_point($"Gun/Bullet Path".target_position)
		#Stun monster if hits them
		#Kill dog if hits them
		#Make sound on wall if hits them

func concat(words : String, number : int):
	return words + str(number)
func _on_main_player_1_is_keyboard():
	if playerNumber == 1:
		isPlayerKeyboard = true
	else:
		player1isKeyboard = true

func _on_pick_up_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ammo") and Ammo < 4:
		Ammo += 1
		area.queue_free()
		print(str(Ammo))
	else:
		print("MAX AMMO")


func _on_bullet_time_timeout() -> void:
	$"Gun/Line2D".clear_points()
