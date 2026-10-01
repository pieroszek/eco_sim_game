extends Node3D

@onready var grid_map: GridMap = $GridMap

const item_water := 1
const item_grass := 2
const item_dirt := 3
const item_sand := 4

@export var width := 128
@export var depth := 128
var moisture_noise := FastNoiseLite.new()
const rabbit_animal_scene := preload("res://rabit.tscn")
const fox_animal_scene := preload("res://fox.tscn")
@export var rabbit_spawn_count: int = 10
@export var fox_spawn_count: int = 1
@export var tree_density: float = 0.45
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moisture_noise.seed = randi()  # or a fixed seed for reproducibility
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	moisture_noise.frequency = .07  # lower = smoother, larger features
	generate_world()
	
	World.grid_map = grid_map
	World.grid_depth = depth
	World.grid_width = width
	spawn_animals()
	generate_plants()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func generate_plants():
	for x in range(width):
		for z in range(depth):
			var coord := Vector2i(x, z)
			var noise_value := moisture_noise.get_noise_2d(float(x), float(z))
			if (noise_value + 1 ) * 0.5  <= tree_density:
				World.spawn_plant("oak", coord)
	pass
func generate_world():
	
	for x in range(width):
		for z in range(depth):
			var coord := Vector2i(x, z)
			
			# Initialize your simulation data
			var noise_value := moisture_noise.get_noise_2d(float(x), float(z))
			var moisture : float = (noise_value + 1 ) * 0.5 
			var data := {
				"biome": item_grass,
				"moisture": moisture
			}
			World.tile_data[coord] = data
			var tree_vector : Vector2i = coord
			#if moisture >= 0.2 and moisture <= 0.6 :
			World.spawn_plant("oak", tree_vector)
			# Sync the visual to the initial data
			_update_visual(coord)
			
			

func _update_visual(coord: Vector2i) -> void:
	var data = World.tile_data.get(coord)
	if data == null:
		return
	
	# Convert your 2D grid coord to 3D GridMap coord
	var grid_coord := Vector3i(coord.x, 0, coord.y)
	var item_id: int = data["biome"]
	
	# Place the mesh
	
	grid_map.set_cell_item(grid_coord, item_id)
	
func _on_sim_tick() -> void:
	for coord in World.tile_data.keys():
		_simulate_cell(coord)
	
func _simulate_cell(coord: Vector2i) -> void:
	var data = World.tile_data[coord]
	var old_biome = data["biome"]
	
	
	if data["moisture"] >= 0.7 and data["biome"] != item_water:
		data["biome"] = item_water
	elif data["moisture"] < 0.7 and data["moisture"] >= 0.4  and data["biome"] != item_grass:
		data["biome"] = item_grass
	elif data["moisture"] < 0.4 and data["moisture"] > 0.2 and data["biome"] != item_dirt:
		data["biome"] = item_dirt
	elif data["moisture"] < 0.2 and data["biome"] != item_sand:
		data["biome"] = item_sand
	#else:
			#data["moisture"] += 0.1
	
	
	# Only update the GridMap if the visual actually needs to change
	if data["biome"] != old_biome:
		_update_visual(coord)
		
func spawn_animals() -> void:
	for i in range(rabbit_spawn_count):
		var animal := rabbit_animal_scene.instantiate()
		add_child(animal)
		animal.global_position = Vector3(
			randf_range(0, World.grid_width), 1.5, randf_range(0, World.grid_depth)
		)
	for i in range(fox_spawn_count):
		var animal := fox_animal_scene.instantiate()
		add_child(animal)
		animal.global_position = Vector3(
			randf_range(0, 64), 1.5, randf_range(0, 64)
		)
