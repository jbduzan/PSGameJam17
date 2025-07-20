extends Ability
class_name WallBounce

func _init(target) -> void:
	abilityName = "wallBounce"
	iconPath = preload("res://assets/Jumpico.png")
	shortcut = "space"
	
	super._init(target)
