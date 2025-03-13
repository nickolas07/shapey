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
	const map_size: int = 100

	place_tiles(Vector2(0, 0), map_size, 1, Vector2i(0, 0))
	cam_body.global_position = base_layer.map_to_local(Vector2i(map_size/2, map_size/2))
	
	

# Game running process
func _process(_delta: float) -> void:
	pass


#func build(coords: Vector2i, soure_id: int, atlas_coods: Vector2i, calc_tile_rotation=true, direction=Vector2.ZERO):
#	var tile_rotation: int = 0
#	
#	if calc_tile_rotation:
#		var mouse_pos: Vector2       = get_global_mouse_position()
#		# var rotation: Array[Variant] = calc_rotation(mouse_pos, prev_mouse_pos, direction)
#		var angle: int               = rotation[1]
#		
#		tile_rotation = rotation[0]
#		hover.rotation_degrees = angle
#	else:
#		tile_rotation = round(hover.rotation_degrees / 90)
#	
#	building_layer.set_cell(coords, soure_id, atlas_coods, tile_rotation)
#
#
#func _input(_event: InputEvent) -> void:
#	var mouse_pos: Vector2 = get_global_mouse_position()
#	var tile_pos: Vector2i = base_layer.local_to_map(mouse_pos)
#	var direction: Vector2 = (mouse_pos - prev_mouse_pos).normalized()
#	var distance: float    = mouse_pos.distance_to(prev_mouse_pos)
#	
#	print(distance, direction)
#
#	if Input.is_action_just_pressed("lmb"):
#		distance = 0
#		if belt.button_pressed:
#			build(tile_pos, 5, Vector2i(0, 0), false)
#
#	if Input.is_action_pressed("lmb"):
#		if prev_tile != tile_pos:
#			prev_mouse_pos = mouse_pos
#
#		# if belt.button_pressed and distance >= MOVE_THRESHOLD and distance < TILE_WIDTH:
#		if belt.button_pressed and Input.is_action_pressed("shift") and distance >= MOVE_THRESHOLD:
#			pass
#			# build(tile_pos, 5, Vector2i(0, 0), true, direction)
#
#
#		prev_tile = tile_pos
#	
#	if Input.is_action_pressed("rmb"):
#		building_layer.set_cell(tile_pos, -1)
		
