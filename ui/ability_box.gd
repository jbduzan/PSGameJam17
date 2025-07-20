extends Button

var ability = null

signal onAbilitySelected

func _init() -> void:
	disabled = true

func _on_pressed() -> void:
	onAbilitySelected.emit(ability)
