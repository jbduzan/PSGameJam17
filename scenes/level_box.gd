extends Button

@export var locked = false: set = setLocked
@export var textLabel: String : set = setLabel
@export_file var levelPath

@onready var lock = $MarginContainer/Lock
@onready var label = $Label

var original_size := scale
var grow_size := Vector2(1.1, 1.1)

func setLocked(value):
	locked = value
	
	if not is_inside_tree():
		await ready
	
	lock.visible = value
	label.visible = not value
	
func setLabel(value):
	if not is_inside_tree():
		await ready
		
	label.text = value

func _on_pressed() -> void:
	if locked or not levelPath: return
	
	get_tree().change_scene_to_file(levelPath)

func _on_mouse_entered() -> void:
	grow(grow_size, .1)
	
func _on_mouse_exited() -> void:
	grow(original_size, .1)
	
func grow(endSize: Vector2, duration: float):
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', endSize, duration)
