extends Node2D
 
@onready var grid_layer: TileMapLayer = $GridLayer
@onready var cam_body: CharacterBody2D = $CamBody

var previous = Vector2i()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const tiles = 100
	
	place_tiles(Vector2(0, 0), tiles, 1)
	cam_body.global_position = grid_layer.map_to_local(Vector2i(tiles/2, tiles/2))

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		
		var tile_mouse_pos = grid_layer.local_to_map(mouse_pos)
		
		if previous != tile_mouse_pos:
			print(tile_mouse_pos)
		
		previous = tile_mouse_pos

func place_tiles(start_pos: Vector2, tiles: int, tile_id: int):
	for x in range(tiles):
		for y in range(tiles):
			grid_layer.set_cell(Vector2i(int(start_pos.x) + x, int(start_pos.y) + y), tile_id, Vector2i(1, 1))
