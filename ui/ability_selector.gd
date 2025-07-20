extends Control

signal onAbilitiesSelected(abilitiesSelected)

const abilityBox = preload("res://ui/ability_box.tscn")
@export var NbrAbilitiesAllowed: int = 0
@export var AbilitiesAllowed: Array

@onready var abilitiesToSelectContainer = $MarginContainer/VBoxContainer/AbilitiesToSelect
@onready var abilitiesSelected = $MarginContainer/VBoxContainer/SelectedAbilities
@onready var startButton = $MarginContainer/VBoxContainer/StartButton
	
func _ready():	
	for i in AbilitiesAllowed.size():
		var abilityBox = abilityBox.instantiate()
		abilityBox.ability = AbilitiesAllowed[i].new(abilityBox)
		abilityBox.disabled = false
		abilityBox.onAbilitySelected.connect(onAbilitySelected)
		abilitiesToSelectContainer.add_child(abilityBox)

func onAbilitySelected(ability: Ability):
	var selectedAbilitiesCount = abilitiesSelected.get_child_count()
	
	if selectedAbilitiesCount < NbrAbilitiesAllowed:
		var abilityBox = abilityBox.instantiate()
		ability.target = abilityBox
		abilityBox.ability = ability
		abilityBox.icon = ability.iconPath
		abilityBox.disabled = false
		abilityBox.onAbilitySelected.connect(removeSelectedAbility)
		abilitiesSelected.add_child(abilityBox)
		checkStartButtonState()

func removeSelectedAbility(ability: Ability):
	abilitiesSelected.remove_child(ability.target)
	checkStartButtonState()

func checkStartButtonState():
	if abilitiesSelected.get_child_count() < NbrAbilitiesAllowed:
		startButton.disabled = true
	else:
		startButton.disabled= false

func _on_start_button_pressed() -> void:
	onAbilitiesSelected.emit(abilitiesSelected.get_children().map(func(e): return e.ability.get_script()))
