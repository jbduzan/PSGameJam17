extends Resource
class_name Ability

var abilityName: String
var isAvailable: bool
var iconPath: Texture2D

func _init(target):
	isAvailable = true
	target.texture = iconPath

func use(target):
	isAvailable = false
	target.texture = preload("res://icon.svg")
