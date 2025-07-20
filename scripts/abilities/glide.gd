extends Ability
class_name Glide

func _init(target) -> void:
	abilityName = "glide"
	iconPath = preload("res://assets/Jumpico.png")
	shortcut = "hold space"
	
	super._init(target)
