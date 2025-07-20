extends HBoxContainer
class_name AbilitiesBar

func can(name: String) -> bool:
	for slot in get_children():
		if slot.ability and slot.ability.abilityName == name:
			return slot.ability.isAvailable
	
	return false

func use(name: String):
	for slot in get_children():
		if slot.ability and slot.ability.abilityName == name:
			slot.ability.use(slot)
