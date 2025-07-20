extends Control

const levelBtn = preload("res://ui/levelBox.tscn")
@export_dir var dirPath
@onready var grid = $MarginContainer/VBoxContainer/GridContainer

func _ready():
	getLevel(dirPath)
	
func getLevel(path):
	var dir = DirAccess.open(path)
	
	if dir:
		var files = dir.get_files()
		files.sort()
		
		for i in files.size():
			var fileName = files[i]
			
			if not fileName: break
			
			createLvlButton('%s/%s' % [dir.get_current_dir(), fileName], i + 1)
			fileName = dir.get_next()
	
func createLvlButton(lvlPath, lvlNumber):
	var btn = levelBtn.instantiate()
	var name = "0" + str(lvlNumber) if lvlNumber < 10 else lvlNumber
	btn.textLabel = name
	btn.levelPath = lvlPath
	btn.locked = false
	grid.add_child(btn)
