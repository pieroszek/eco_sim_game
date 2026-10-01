extends CharacterBody3D

@export var move_speed: float = 2.0
@export var hunger_rate: float = 0.2

var hunger: float = randf()
var target_position: Vector3
var my_cell := Vector2i.ZERO
var my_biome := 0
var next_pos := Vector3.ZERO
var next_cell := Vector2i.ZERO
enum State { WANDER, EAT, SLEEP, RUN }
var current_state: State = State.WANDER

var danger_dir := Vector3.ZERO

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
			if hunger > 0.8:
				if my_biome == World.item_grass:
					current_state = State.EAT
					_pick_new_wander_target()
				#else:
					#current_state = State.WANDER
			elif global_position.distance_to(target_position) < 0.5:
				_pick_new_wander_target()
		State.EAT:
			hunger = max(0.0, hunger - delta * 0.5)
			if hunger < 0.2:
				current_state = State.WANDER
		State.RUN:
			if hunger > 0.9:
				current_state = State.WANDER
			elif global_position.distance_to(target_position) < 0.5:
				current_state = State.WANDER
				_pick_new_wander_target()
				
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
		State.RUN:
			#print("run")
			danger_dir.x *= -1
			danger_dir.z *= -1
			velocity = danger_dir * (move_speed * 2)
			


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("predator"):
		#print("fox")
		danger_dir = body.global_position.normalized()
		current_state = State.RUN
	pass # Replace with function body.
	
	
	
func die():
	queue_free()
	pass
