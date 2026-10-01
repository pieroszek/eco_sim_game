extends Node

const item_water := 1
const item_grass := 2
const item_dirt := 3
const item_sand := 4

#@export var tree_scene: PackedScene
const tree_scene := preload("res://tree.glb")
var tile_data: Dictionary = {}
var plant_data: Dictionary = {}
var grid_map: GridMap

var last_plant_id : int = 0
class PlantData:
	var id: int
	var species: String        # "oak", "pine", "bush"
	var cell: Vector2i         # which tile it's rooted on
	var position: Vector3      # exact world position (with jitter)
	var age: float = 0.0
	var health: float = 1.0
	var mesh_instance: Node3D  # reference to the visual node, if spawned


var grid_width := 0
var grid_depth := 0

func world_to_cell(pos: Vector3) -> Vector2i:
	var local := grid_map.to_local(pos)
	var map := grid_map.local_to_map(local)
	return Vector2i(map.x, map.z)

func get_tile(cell: Vector2i):
	return tile_data.get(cell)

func get_biome(cell: Vector2i) -> int:
	var t = tile_data.get(cell)
	return t.biome if t else -1

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_width \
	   and cell.y >= 0 and cell.y < grid_depth
	
func is_walkable(cell: Vector2i) -> bool:
	if !is_in_bounds(cell):
		return false
	return get_biome(cell) != item_water

func spawn_plant(species: String, cell: Vector2i) -> void:
	if not is_in_bounds(cell):
		return
	if get_biome(cell) == item_water:
		return  # no trees on water
	
	var data := PlantData.new()
	data.id = last_plant_id + 1
	last_plant_id += 1
	data.species = species
	data.cell = cell
	data.age = randf_range(1,5)
	data.health = randf_range(0,1)
	data.position = grid_map.map_to_local(Vector3i(cell.x, 1.5, cell.y)) + Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3)) 
	data.position = grid_map.to_global(data.position)
	plant_data[data.id] = data
	_spawn_plant_mesh(data)
	
func _spawn_plant_mesh(data: PlantData) -> void:
	var mesh := tree_scene.instantiate()
	add_child(mesh)
	mesh.global_position = data.position
	data.mesh_instance = mesh
