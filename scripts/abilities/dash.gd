extends Ability
class_name Hyperspeed

func _init(target) -> void:
	abilityName = "dash"
	iconPath = preload("res://assets/Dashico.png")
	shortcut = "shift"
	
	super._init(target)
