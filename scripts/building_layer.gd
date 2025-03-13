extends TileMapLayer

@onready var building_layer: TileMapLayer = $"."
@onready var hover: AnimatedSprite2D = $"../../hover"
@onready var belt: Button = $"../../CanvasLayer/belt"

var prev_tile: Vector2i     = Vector2i()
var prev_mouse_pos: Vector2 = Vector2.ZERO

const MOVE_THRESHOLD: int    = 4
const TILE_WIDTH: int        = 32
const TILE_INFO: Dictionary = {
							  'belt_straight': [5, Vector2i(0, 0)],
							  'belt_right': [6, Vector2i(0, 0)],
							  'belt_left': [2, Vector2i(0, 0)],
							  }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_belt_toggled(toggled_on: bool) -> void:
	hover.animation = "belt"
	hover.visible = toggled_on
	
	if not toggled_on:
		hover.rotation = 0
		hover.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var tile_pos: Vector2i = building_layer.local_to_map(mouse_pos)
	var direction: Vector2 = (mouse_pos - prev_mouse_pos).normalized()
	var distance: float    = mouse_pos.distance_to(prev_mouse_pos)

	if Input.is_action_just_pressed("rotate"):
		hover.rotate(deg_to_rad(90))
	hover.position = building_layer.map_to_local(tile_pos)
		
	if belt.button_pressed:
		hover.visible = true
	else:
		hover.visible = false
		hover.rotation = 0
	
	if belt.button_pressed and Input.is_action_just_pressed('lmb'):
		distance = 0
		build('belt_straight', false)
		
	elif belt.button_pressed and Input.is_action_pressed('lmb') and distance > MOVE_THRESHOLD:
		build('belt_straight', true)
	
	
# Calculates the rotation for tiles and an the angle
func calc_rotation(pos, prev_pos) -> Array[Variant]:
	var rotation: int      = 0
	var angle: int         = 0
	var direction: Vector2 = (pos - prev_pos).normalized()

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			rotation = 1  # Rechts
			angle = 90
		else:
			rotation = 3  # Links
			angle = 270
	else:
		if direction.y > 0:
			rotation = 2  # Runter
			angle = 180
		else:
			rotation = 0  # Hoch
			angle = 0

	return [rotation, angle]
	
	
func build(tile, calc_tile_rotation=true):
	var mouse_pos: Vector2 = get_global_mouse_position()
	var tile_pos: Vector2i = building_layer.local_to_map(mouse_pos)
	var tile_rotation: int = 0

	if calc_tile_rotation:
		var rotation: Array[Variant] = calc_rotation(mouse_pos, prev_mouse_pos)
		var angle: int               = rotation[1]

		tile_rotation = rotation[0]
		hover.rotation_degrees = angle
	else:
		tile_rotation = round(hover.rotation_degrees / 90)
	
	var source_id = TILE_INFO[tile][0]
	var atlas_coods = TILE_INFO[tile][1]
	
	building_layer.set_cell(tile_pos, source_id, atlas_coods, tile_rotation)


	# Speichert die alten Standorte
	prev_tile = tile_pos
	prev_mouse_pos = mouse_pos
	
