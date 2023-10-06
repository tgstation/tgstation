/datum/asset/spritesheet/lights
	name = "lights"

/datum/asset/spritesheet/lights/create_spritesheets()
	// These two are required to ensure this spritesheet is not rendered with a fully white background
	// No I have absolutely no idea why, something something alpha maybe? but it does work, so that's for LATER!!
	Insert("light_dummy_start_fuckyoubyond", 'icons/obj/medical/bloodpack.dmi', "generic_bloodpack")
	for(var/id in GLOB.light_types)
		var/datum/light_template/template = GLOB.light_types[id]
		Insert("light_fantastic_[template.id]", template.icon, template.icon_state)
	Insert("light_dummy_end_fuckyoubyond", 'icons/mob/silicon/ai.dmi', "questionmark")
