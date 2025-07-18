extends Ability
class_name Jump

func _init(target) -> void:
	abilityName = "jump"
	iconPath = preload("res://assets/Jumpico.png")
	
	super._init(target)
