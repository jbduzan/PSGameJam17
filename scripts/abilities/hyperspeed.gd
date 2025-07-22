extends Ability
class_name Dash

func _init(target) -> void:
	abilityName = "hyperspeed"
	iconPath = preload("res://assets/Dashico.png")
	shortcut = "1"
	
	super._init(target)
