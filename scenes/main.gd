extends Control

const levelBtn = preload("res://scenes/levelBox.tscn")
@export_dir var dirPath
@onready var grid = $MarginContainer/VBoxContainer/GridContainer

func _ready():
	getLevel(dirPath)
	
func getLevel(path):
	var dir = DirAccess.open(path)
	
	if dir:
		var files = dir.get_files()
		files.sort()
		
		for fileName in files:
			while fileName != "":
				print(fileName)
				createLvlButton('%s/%s' % [dir.get_current_dir(), fileName], fileName)
				fileName = dir.get_next()
	
func createLvlButton(lvlPath, lvlName):
	var btn = levelBtn.instantiate()
	btn.textLabel = lvlName.trim_suffix(".tscn").replace("_", " ")
	btn.levelPath = lvlPath
	btn.locked = false
	grid.add_child(btn)
