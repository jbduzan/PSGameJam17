extends Ability
class_name Dash

func _init(target) -> void:
	abilityName = "hyperspeed"
	iconPath = preload("res://assets/Dashico.png")
	shortcut = "r"
	
	super._init(target)
