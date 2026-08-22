extends CharacterBody2D
var movement_speed : float
@export var listening_speed : float = 100.0
@export var wandering_speed : float = 200.0
@export var chasing_speed : float = 500.0

@export var bark_sprite : Texture
@export var default_sprite : Texture
@export var Jibidoo : Node2D

@export var WonderNodes : Node2D
var target_to_chase : Node2D

var isInjured := false

var isAggro : bool

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	enter_wandering()

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func enter_wandering():
	if !isInjured:
		movement_speed = wandering_speed
	isAggro = false
	var POIs = WonderNodes.get_children()
	target_to_chase = POIs.pick_random()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		if !isAggro and !isInjured:
			enter_wandering()
	if target_to_chase != null:
		set_movement_target(target_to_chase.global_position)
	var current_agent_global_position: Vector2 = global_position
	var next_path_global_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_global_position.direction_to(next_path_global_position) * movement_speed
	move_and_slide()
	if !isAggro:
		pass
		##hide()
	else:
		$Bediboo.texture = bark_sprite
		$Bark.play()
		if check_LOS_between(global_position,target_to_chase.global_position):
			Jibidoo.hear_noise(6, target_to_chase.global_position, 5)
		else:
			isAggro = false
		await get_tree().create_timer(0.45).timeout
		$Bediboo.texture = default_sprite
	

func Injury():
	$"Injury Sound".play()
	isInjured = true
	$"Injury Timer".start()

func check_LOS_between(pos1 : Vector2, pos2 : Vector2):
	var count = 0
	var adjustment := Vector2.ZERO
	while count != 3:
		if count == 1:
			adjustment = Vector2.UP
		elif count == 2:
			adjustment = Vector2.DOWN
		var space_state = get_world_2d().direct_space_state

		var query = PhysicsRayQueryParameters2D.create(pos1 + adjustment, pos2 + adjustment)
		query.collision_mask = 2

		var result = space_state.intersect_ray(query)

		if result.is_empty():
			return true
		count += 1
	return false


func _on_injury_timer_timeout() -> void:
	isInjured = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if check_LOS_between(global_position,body.global_position) and !isInjured:
		isAggro = true
		target_to_chase = body
		movement_speed = chasing_speed
	else:
		movement_speed = listening_speed
		target_to_chase = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	enter_wandering()
