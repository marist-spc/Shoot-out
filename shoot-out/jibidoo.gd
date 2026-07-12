extends CharacterBody2D
@export var movement_speed: float = 200.0
@export var listening_speed : float = 100.0
@export var wandering_speed : float = 200.0
@export var chasing_speed : float = 500.0
@export var retreat_speed := 50.0


@export var Player1 : Node2D
@export var Player2 : Node2D
@export var WonderNodes : Node2D
var target_to_chase : Node2D

var isInjured

var curr_priority
var isAggro : bool

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	hide()
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
	enter_listening_mode()

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func enter_wandering():
	if !isInjured:
		movement_speed = wandering_speed
	curr_priority = 0
	isAggro = false
	var POIs = WonderNodes.get_children()
	target_to_chase = POIs.pick_random()
	
func enter_listening_mode():
	var players : Array = $"Player Detector".get_overlapping_bodies()
	if !players.is_empty():      
		movement_speed = listening_speed
		if len(players) > 0:
			players.sort_custom(func(a,b): return a if a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position) else b)
		target_to_chase = players[0]
		curr_priority = 0
	else:
		enter_wandering()
func hear_noise(priority : int, pos : Vector2, time_to_stay : float):
	if priority < curr_priority or isInjured:
		return
	movement_speed = chasing_speed
	target_to_chase = null
	isAggro = true
	curr_priority = priority
	set_movement_target(pos)
	$AggroTimer.wait_time = time_to_stay
	$AggroTimer.start()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		if !isAggro:
			enter_wandering()
		else:
			enter_listening_mode()
	if target_to_chase != null:
		set_movement_target(target_to_chase.global_position)
	var current_agent_global_position: Vector2 = global_position
	var next_path_global_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_global_position.direction_to(next_path_global_position) * movement_speed
	move_and_slide()
	hide()
	if check_LOS_between(Player1.global_position, global_position):
		Player1.isVisibleToMonster = true
		show()
	else:
		Player1.isVisibleToMonster = false
	if check_LOS_between(Player2.global_position, global_position):
		Player2.isVisibleToMonster = true
		show()
	else:
		Player2.isVisibleToMonster = false

func Injury():
	isInjured = true
	movement_speed = retreat_speed
	enter_wandering()
	$"Injury Timer".start()

func _on_aggro_timer_timeout() -> void:
	enter_wandering()

func check_LOS_between(pos1 : Vector2, pos2 : Vector2):
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(pos1, pos2)
	query.collision_mask = 2

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return true
	else:
		return false


func _on_injury_timer_timeout() -> void:
	isInjured = false


func _on_hit_box_body_entered(body: Node2D) -> void:
	body.death()
	enter_wandering()
