/obj/structure/artifact/test
	assoc_datum = /datum/artifact/test
/datum/artifact/test
	associated_object = /obj/structure/artifact/test
	weight = 1000
	type_name = "debug"
	effect_activate()
		to_chat(world,"activate")
	effect_deactivate()
		to_chat(world,"deactivate")
		return
	effect_touched()
		to_chat(world,"touch")
		return