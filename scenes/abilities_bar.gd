extends HBoxContainer

var slots: Array

func _ready():
	slots = get_children()
	slots[0].ability = Jump.new(slots[0])	
	slots[1].ability = Dash.new(slots[1])

func can(name: String) -> bool:
	for slot in slots:
		if slot.ability and slot.ability.abilityName == name:
			return slot.ability.isAvailable
	
	return false

func use(name: String):
	for slot in slots:
		if slot.ability and slot.ability.abilityName == name:
			slot.ability.use(slot)
