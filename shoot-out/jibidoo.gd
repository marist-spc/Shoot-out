extends CharacterBody2D
@export var movement_speed: float = 200.0
@export var listening_speed : float = 200.0
@export var wandering_speed : float = 200.0
@export var chasing_speed : float = 200.0



var movement_target_global_position := Vector2(0,0)

var curr_priority
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

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_global_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_global_position = movement_target

func enter_wandering():
	movement_speed = wandering_speed
	curr_priority = 0
	isAggro = false
	#Func for finding random new pos
func enter_listening_mode():
	var players : Array = $"Player Detector".get_overlapping_bodies()
	if !players.is_empty():      
		movement_speed = listening_speed
		if len(players)> 0:
			players.sort_custom(func(a,b): return a if a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position) else b)
		set_movement_target(players[0].global_position)
		curr_priority = 0
	else:
		enter_wandering()
func hear_noise(priority : int, pos : Vector2, time_to_stay : float):
	if priority < curr_priority:
		return
	movement_speed = chasing_speed
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

	var current_agent_global_position: Vector2 = global_position
	var next_path_global_position: Vector2 = navigation_agent.get_next_path_global_position()

	velocity = current_agent_global_position.direction_to(next_path_global_position) * movement_speed
	move_and_slide()


func _on_aggro_timer_timeout() -> void:
	enter_wandering()
