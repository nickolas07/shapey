extends Node2D

@onready var base_layer: TileMapLayer = $Layers/BaseLayer
@onready var building_layer: TileMapLayer = $Layers/BuildingLayer
@onready var cam_body: CharacterBody2D = $CamBody

@onready var belt: Button = $CanvasLayer/belt
@onready var hover: AnimatedSprite2D = $hover

var prev_tile: Vector2i     = Vector2i()
var prev_mouse_pos: Vector2 = Vector2.ZERO
const MOVE_THRESHOLD: int   = 4
const TILE_WIDTH: int       = 32

func place_tiles(start_pos: Vector2, tiles: int, tile_set_id:int, tile_id: Vector2i):
	for x in range(tiles):
		for y in range(tiles):
			base_layer.set_cell(Vector2i(int(start_pos.x) + x, int(start_pos.y) + y),
			tile_set_id, tile_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const map_size: int = 20

	place_tiles(Vector2(0, 0), map_size, 1, Vector2i(0, 0))
	cam_body.global_position = base_layer.map_to_local(Vector2i(map_size/2, map_size/2))
	
	

# Game running process
func _process(_delta: float) -> void:
	pass
