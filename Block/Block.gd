extends Node2D
class_name Block
onready var sprite = $Sprite
var state = '' setget _set_state

func _change_sprite(state):
	match state:
		'x':
			 sprite.frame = 1
		'o':
			sprite.frame = 2
		_:
			sprite.frame = 0

func _set_state(value):
	state = value
	_change_sprite(state)
	
