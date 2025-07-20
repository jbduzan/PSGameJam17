extends Resource
class_name Ability

var abilityName: String
var isAvailable: bool
var iconPath: Texture2D
var target: Button

func _init(target: Button):
	isAvailable = true
	target.icon = iconPath

func use(target: Button):
	isAvailable = false
	target.icon = preload("res://icon.svg")

func clone(newTarget: Button):
	var newAbility = Ability.new(newTarget)
	newAbility.isAvailable = isAvailable
	newAbility.iconPath = iconPath
	newAbility.abilityName = abilityName
	return newAbility
