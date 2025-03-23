extends TileMapLayer

@onready var building_layer: TileMapLayer = $"."
@onready var hover: AnimatedSprite2D = $"../../hover"
@onready var belt: Button = $"../../CanvasLayer/belt"

var prev_tile: Vector2i     = Vector2i()
var prev_mouse_pos: Vector2 = Vector2.ZERO

const MOVE_THRESHOLD: int    = 4
const TILE_WIDTH: int        = 32
const TILE_INFO: Dictionary = {'belt_straight': [5, Vector2i(0, 0)],
							  'belt_right': [6, Vector2i(0, 0)],
							  'belt_left': [2, Vector2i(0, 0)]}
const TILE_INFO_SOURCE: Dictionary = {5: 'belt_straight', 6: 'belt_right', 2: 'belt_left'}

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
	pass

func _input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var tile_pos: Vector2i = building_layer.local_to_map(mouse_pos)
	var direction: Vector2 = (mouse_pos - prev_mouse_pos).normalized()
	var distance: float    = mouse_pos.distance_to(prev_mouse_pos)

	if Input.is_action_just_pressed("rotate"):
		if hover.rotation_degrees == 270:
			hover.set_rotation_degrees(0)
		else:
			hover.rotate(deg_to_rad(90))
	hover.position = building_layer.map_to_local(tile_pos)

	if belt.button_pressed:
		hover.visible = true
	else:
		hover.visible = false
		hover.rotation = 0


	if belt.button_pressed and Input.is_action_just_pressed('lmb'):
		build('belt_straight', mouse_pos, tile_pos, false)

	elif belt.button_pressed and Input.is_action_pressed('lmb') and distance > MOVE_THRESHOLD:
		build('belt_straight', mouse_pos, tile_pos, true)

	if not belt.button_pressed and Input.is_action_pressed('rmb'):
		building_layer.set_cell(tile_pos, -1)
			

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
	
func get_tile_rotation(layer: TileMapLayer, pos: Vector2i) -> int:
	if layer.get_cell_source_id(pos) == -1:
		return 0
	
	var tile_data: TileData = layer.get_cell_tile_data(pos)
	var rotation: int       = 0
	if tile_data.get_flip_h() and tile_data.transpose:
		rotation = 90
	elif tile_data.get_flip_v():
		rotation = 180
	elif tile_data.get_transpose():
		rotation = 270
	rotation /= 90

	return rotation

func build(tile, mouse_pos, tile_pos, calc_tile_rotation=true):
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

	var neighbors: Dictionary = {'unten': building_layer.get_surrounding_cells(prev_tile)[1], 
									'rechts': building_layer.get_surrounding_cells(prev_tile)[0], 
									'oben': building_layer.get_surrounding_cells(prev_tile)[3], 
									'links': building_layer.get_surrounding_cells(prev_tile)[2]}

	var neighbors_rotation: Dictionary = {'unten': get_tile_rotation(building_layer, neighbors['unten']),
		                               'links': get_tile_rotation(building_layer, neighbors['links']),
		                               'oben': get_tile_rotation(building_layer, neighbors['oben']),
		                               'rechts': get_tile_rotation(building_layer, neighbors['rechts'])}

	var neighbors_id: Dictionary = {'unten': building_layer.get_cell_source_id(neighbors['unten']),
									   'links': building_layer.get_cell_source_id(neighbors['links']),
									   'oben': building_layer.get_cell_source_id(neighbors['oben']),
									   'rechts': building_layer.get_cell_source_id(neighbors['rechts'])}

	# links nach rechts	/ rechts nach links
	if neighbors_id['links'] != -1 and neighbors_id['rechts'] != -1 and tile_rotation % 2 != 0:
		pass

	# oben nach unten / unten nach oben
	elif neighbors_id['oben'] != -1 and neighbors_id['unten'] != -1 and tile_rotation % 2 == 0:
		pass

	# unten nach rechts
	elif neighbors_id['unten'] != -1 and neighbors_rotation['unten'] == 0 and neighbors_id['rechts'] != -1 and neighbors_rotation['rechts'] == 1 and tile_rotation == 1:
		source_id = TILE_INFO['belt_right'][0]
		atlas_coods = TILE_INFO['belt_right'][1]
		
		building_layer.set_cell(prev_tile, source_id, atlas_coods, 0)
		
	# unten nach links
	elif neighbors_id['unten'] != -1 and neighbors_rotation['unten'] == 0 and neighbors_id['links'] != -1 and neighbors_rotation['links'] == 3 and tile_rotation == 3:
		source_id = TILE_INFO['belt_left'][0]
		atlas_coods = TILE_INFO['belt_left'][1]
		
		building_layer.set_cell(prev_tile, source_id, atlas_coods, 0)
	
	# oben nach rechts
	elif neighbors_id['oben'] != -1 and neighbors_rotation['oben'] == 2 and neighbors_id['rechts'] != -1 and neighbors_rotation['rechts'] == 1 and tile_rotation == 1:
		source_id = TILE_INFO['belt_left'][0]
		atlas_coods = TILE_INFO['belt_left'][1]
	
		building_layer.set_cell(prev_tile, source_id, atlas_coods, 2)

	# oben nach links
	elif neighbors_id['oben'] != -1 and neighbors_rotation['oben'] == 2 and neighbors_id['links'] != -1 and neighbors_rotation['links'] == 3 and tile_rotation == 3:
		source_id = TILE_INFO['belt_right'][0]
		atlas_coods = TILE_INFO['belt_right'][1]

		building_layer.set_cell(prev_tile, source_id, atlas_coods, 2)
	
	# rechts nach oben
	elif neighbors_id['rechts'] != -1 and neighbors_rotation['rechts'] == 3 and neighbors_id['oben'] != -1 and neighbors_rotation['oben'] == 0 and tile_rotation == 0:
		source_id = TILE_INFO['belt_right'][0]
		atlas_coods = TILE_INFO['belt_right'][1]

		building_layer.set_cell(prev_tile, source_id, atlas_coods, 3)

	# rechts nach unten
	elif neighbors_id['rechts'] != -1 and neighbors_rotation['rechts'] == 3 and neighbors_id['unten'] != -1 and neighbors_rotation['unten'] == 2 and tile_rotation == 2:
		source_id = TILE_INFO['belt_left'][0]
		atlas_coods = TILE_INFO['belt_left'][1]

		building_layer.set_cell(prev_tile, source_id, atlas_coods, 1)
			
	# links nach oben
	elif neighbors_id['links'] != -1 and neighbors_rotation['links'] == 1 and neighbors_id['oben'] != -1 and neighbors_rotation['oben'] == 0 and tile_rotation == 0:
		source_id = TILE_INFO['belt_left'][0]
		atlas_coods = TILE_INFO['belt_left'][1]

		building_layer.set_cell(prev_tile, source_id, atlas_coods, 3)

	# links nach unten
	elif neighbors_id['links'] != -1 and neighbors_rotation['links'] == 1 and neighbors_id['unten'] != -1 and neighbors_rotation['unten'] == 2 and tile_rotation == 2:
		source_id = TILE_INFO['belt_right'][0]
		atlas_coods = TILE_INFO['belt_right'][1]

		building_layer.set_cell(prev_tile, source_id, atlas_coods, 1)

	# Speichert die alten Standorte
	prev_tile = tile_pos if tile_pos != prev_tile else prev_tile
	prev_mouse_pos = mouse_pos if mouse_pos != prev_mouse_pos else prev_mouse_pos
	
