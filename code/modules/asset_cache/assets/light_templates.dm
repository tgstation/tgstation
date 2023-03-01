/datum/asset/spritesheet/lights
	name = "lights"

/datum/asset/spritesheet/lights/create_spritesheets()
	for(var/id in GLOB.light_types)
		var/datum/light_template/template = GLOB.light_types[id]
		Insert("light_fantastic_[template.id]", template.icon, template.icon_state)
