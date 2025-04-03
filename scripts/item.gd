extends Node2D

@onready var building_layer = get_parent().get_node('Layers/BuildingLayer')

const SPEED: int = 48

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos: Vector2           = self.global_position
	var tile_pos: Vector2i     = building_layer.local_to_map(pos)
	var tile_center: Vector2   = building_layer.map_to_local(tile_pos)
	var rotation               = building_layer.get_tile_rotation(building_layer, tile_pos)
	var distance: Vector2      = (tile_center - pos) * 4

	if building_layer.get_cell_source_id(tile_pos) == 5:
		if rotation == 0:
			self.global_position += Vector2(distance.x, -SPEED) * delta
		elif rotation == 1:
			self.global_position += Vector2(SPEED, distance.y) * delta
		elif rotation == 2:
			self.global_position += Vector2(distance.x, SPEED) * delta
		elif rotation == 3:
			self.global_position += Vector2(-SPEED, distance.y) * delta


	elif building_layer.get_cell_source_id(tile_pos) == 6:
		if rotation == 0:
			self.global_position += Vector2(SPEED, -SPEED) * delta
		elif rotation == 1:
			self.global_position += Vector2(SPEED, SPEED) * delta
		elif rotation == 2:
			self.global_position += Vector2(-SPEED, SPEED) * delta
		elif rotation == 3:
			self.global_position += Vector2(-SPEED, -SPEED) * delta


	elif building_layer.get_cell_source_id(tile_pos) == 2:
		if rotation == 0:
			self.global_position += Vector2(-SPEED, -SPEED) * delta
		elif rotation == 1:
			self.global_position += Vector2(-SPEED, SPEED) * delta
		elif rotation == 2:
			self.global_position += Vector2(SPEED, SPEED) * delta
		elif rotation == 3:
			self.global_position += Vector2(SPEED, -SPEED) * delta

#	elif distance > 0:
#		var move_amount: float = SPEED * delta
#		if move_amount > distance:
#			move_amount = distance
#
#		self.global_position = pos.move_toward(tile_center, move_amount)


#	print(building_layer.get_cell_source_id(tile_pos), tile_pos, building_layer.local_to_map(get_global_mouse_position()))
