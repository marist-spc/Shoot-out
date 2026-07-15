extends CharacterBody2D

@export var isPlayerKeyboard := false
@export var player1isKeyboard : = true	
@export var playerNumber : int

@export var full_heart : Texture2D
@export var half_heart : Texture2D

@export var curserSens := 1

@export var health := 2
@export var player2sprite : Texture

@export var main_script : Node2D

var spawnPos : Vector2
@export var deathTime := 10
var isDead
var Ammo : int
var keys : int
var SPEED = 300
var isOutOfBreath := false

var isVisibleToMonster : bool

func _ready() -> void:
	if !playerNumber == 2:
		$"Player Image".texture = player2sprite
	spawnPos = global_position
func _physics_process(delta: float) -> void:
	if health == 2:
		$Heart.texture = full_heart
	if health == 1:
		if $Heart.texture == full_heart:
			$"Hurt Sound".play()
		$Heart.texture = half_heart
	if health == 0 and !isDead:
		death()
	if !isDead:
		$"Heart Beat Area".isVisibleToMonster = isVisibleToMonster
		var x = Input.get_axis(concat("left",playerNumber), concat("right",playerNumber))
		var y = Input.get_axis(concat("up",playerNumber), concat("down",playerNumber))
		var direction := Vector2(x,y)
		
		var CurrSpeed = SPEED
		if Input.is_action_pressed("hold_breath" + str(playerNumber)) and !isOutOfBreath:
			CurrSpeed /= 4
		elif isOutOfBreath:
			CurrSpeed /= 2
		if direction != Vector2.ZERO:
			velocity = direction.normalized() * CurrSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, CurrSpeed * delta )
			velocity.y = move_toward(velocity.y, 0, CurrSpeed * delta)
			
		move_and_slide()
		aim(delta)
		breath(delta)
func aim(delta : float):
	var shootButton
	if isPlayerKeyboard:
		$CrossHair.global_position = get_global_mouse_position()
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
		$BulletSound.play()
		var collision = $"Gun/Bullet Path".get_collider()
		Ammo -= 1
		if !$Gun.get_overlapping_bodies().is_empty():
			$Gun.get_overlapping_bodies()[0].hear_noise(5, global_position, 10)
		$"Gun/Line2D".add_point($Gun.position)
		$"Gun/Line2D".add_point($Gun/Line2D.to_local($"Gun/Bullet Path".get_collision_point()))
		$"Gun/Line2D/BulletTime".start()
		$Gun_Shot_Collision_Noise.show()
		$Gun_Shot_Collision_Noise.global_position = $"Gun/Bullet Path".get_collision_point()
		if !$Gun_Shot_Collision_Noise.get_overlapping_bodies().is_empty():
			$Gun_Shot_Collision_Noise.get_overlapping_bodies()[0].hear_noise(4,$Gun_Shot_Collision_Noise.global_position, 4)
		if collision != null:
			if collision.is_in_group("Players"):
				collision.health -= 1
			if collision.is_in_group("Jibidoo"):
				collision.Injury()
		#Kill dog if hits them

func breath(delta : float):
	if Input.is_action_pressed("hold_breath" + str(playerNumber)) and !isOutOfBreath:
		main_script.manage_breath(playerNumber, delta, false)
	else: 
		main_script.manage_breath(playerNumber, delta, true)
func out_of_breath():
	isOutOfBreath = true
	health -= 1
	$OutOfBreathTimer.start()
	if health != 0:
		$"Catching Breath Sound".play()
func concat(words : String, number : int):
	return words + str(number)

func death():
	$"Death Sound".play()
	hide()
	main_script.player_death(playerNumber)
	global_position = Vector2.ZERO
	isDead = true
	Ammo = 0
	main_script.distrubute_keys(keys)
	keys = 0
	await get_tree().create_timer(deathTime).timeout
	$"Spawn Sound".play()
	global_position = spawnPos
	isDead = false
	health = 2
	
	show()
func _on_main_player_1_is_keyboard():
	if playerNumber == 1:
		isPlayerKeyboard = true
	else:
		player1isKeyboard = true

func _on_pick_up_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ammo"):
		if Ammo < 4:
			Ammo += 1
			area.queue_free()
			$"Pick Up Ammo".play()
		else:
			$"Full Ammo"
	if area.is_in_group("Key"):
		main_script.add_key(playerNumber)
		keys += 1
		area.queue_free()
		$"Pick Up Ammo".play()


func _on_bullet_time_timeout() -> void:
	$"Gun/Line2D".clear_points()
	$Gun_Shot_Collision_Noise.hide()


func _on_out_of_breath_timer_timeout() -> void:
	isOutOfBreath = false
