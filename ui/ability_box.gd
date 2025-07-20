extends Button

var ability = null : set = setAbility

signal onAbilitySelected

func _init() -> void:
	disabled = true

func _on_pressed() -> void:
	onAbilitySelected.emit(ability)

func setAbility(value):
	ability = value
	text = ability.abilityName + '\n' + ability.shortcut
