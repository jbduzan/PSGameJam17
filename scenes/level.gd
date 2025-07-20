extends Node2D

const abilityBox = preload("res://ui/ability_box.tscn")
const player = preload("res://scenes/player.tscn")

@onready var abilitySelectScreen = $UI/AbilitySelector
@onready var abilityBar = $UI/abilitiesBar
@onready var spawn = $Spawn

func _on_ability_selector_on_abilities_selected(abilitiesSelected: Array) -> void:
	abilitySelectScreen.visible = false
	
	for ability in abilitiesSelected:
		var abilityBox = abilityBox.instantiate()
		abilityBox.ability = ability.new(abilityBox)
		abilityBar.add_child(abilityBox)
		
	var currentPlayer = player.instantiate()
	currentPlayer.abilities = abilityBar
	spawn.add_child(currentPlayer)
	
