extends Ability
class_name Dash

func _init(target) -> void:
	abilityName = "dash"
	iconPath = preload("res://assets/Dashico.png")
	
	super._init(target)
