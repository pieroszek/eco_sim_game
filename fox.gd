extends CharacterBody3D

@export var move_speed: float = 2.0
@export var hunger_rate: float = 0.2

@onready var Sight := $Area3D

var hunger: float = randf()
var target_position: Vector3
var my_cell := Vector2i.ZERO
var my_biome := 0
var next_pos := Vector3.ZERO
var next_cell := Vector2i.ZERO
enum State { WANDER, EAT, SLEEP, HUNT }
var current_state: State = State.WANDER

func _ready() -> void:
	_pick_new_wander_target()
	
func _physics_process(delta: float) -> void:
	_update_state(delta)
	_execute_state(delta)
	my_cell = World.world_to_cell(global_position)
	my_biome = World.get_biome(my_cell)
	next_pos = global_position + velocity * delta
	next_cell = World.world_to_cell(next_pos)
	if World.is_walkable(next_cell):
		move_and_slide()
	else:
		_pick_new_wander_target()


func _pick_new_wander_target() -> void:
	target_position = global_position + Vector3(
		randf_range(-5, 5), 0, randf_range(-5, 5)
	)
	
	
func _update_state(delta: float) -> void:
	hunger += hunger_rate * delta
	
	match current_state:
		State.WANDER:
			if hunger > 0.5:
				current_state = State.HUNT
			elif global_position.distance_to(target_position) < 0.2:
				_pick_new_wander_target()

		State.HUNT:
			if global_position.distance_to(target_position) < 0.2:
				_pick_new_wander_target()
			if hunger < 0.5:
				current_state = State.WANDER

func _execute_state(_delta: float) -> void:
	match current_state:
		State.WANDER:
			var dir := (target_position - global_position)
			dir.y = 0
			if dir.length() > 0.1:
				#if World.is_walkable(next_cell):
				velocity = dir.normalized() * move_speed
			else:
				velocity = Vector3.ZERO
		State.SLEEP, State.EAT:
			velocity = Vector3.ZERO
		State.HUNT:
			if prey_dir.length() > 0.1:
				velocity = prey_dir * (move_speed * 2)
			else:
				_pick_new_wander_target()
			#else:
			#	velocity = Vector3.ZERO
			#	current_state = State.WANDER

var prey_dir : Vector3
func _on_visibility_entered(body: Node3D) -> void:
	if body.is_in_group("prey"):
		#print("rabbit")
		prey_dir = body.global_position.normalized()
		current_state = State.HUNT
	pass # Replace with function body.
	


func _on_attack_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("prey"):
		hunger = 0
		body.die()
	pass # Replace with function body.
