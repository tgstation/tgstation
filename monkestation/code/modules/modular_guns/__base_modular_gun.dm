/obj/item/gun/ballistic/modular
	name = "generic receiver"
	desc = "some assembly required"
	w_class = WEIGHT_CLASS_SMALL // smuggle me
	spread = 100 // this is horrible unassembled
	mag_display = FALSE // needs some shitcode ig cause we have multiple types
	spawnwithmagazine = FALSE
	pinless = TRUE //for now until we do other shit

	var/mag_icon_state = "mag_32.25 Caseless"

/obj/item/gun/ballistic/modular/update_overlays()
	. = ..()
	if(mag_icon_state && magazine)
		. += mutable_appearance(icon, mag_icon_state, layer, offset_spokesman = src)
