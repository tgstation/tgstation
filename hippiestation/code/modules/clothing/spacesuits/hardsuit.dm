/obj/item/clothing/head/helmet/space/hardsuit
	var/next_warn_rad = 0
	var/warn_rad_cooldown = 180

/obj/item/clothing/suit/space/hardsuit
	var/next_warn_acid = 0
	var/warn_acid_cooldown = 150

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(severity)
	.=..()
	if (prob(33) && rad_count > 500 && severity > 25)
		if (next_warn_rad > world.time)
			return
		next_warn_rad = world.time + warn_rad_cooldown
		display_visor_message("Radiation present, seek distance from source!")

/obj/item/clothing/suit/space/hardsuit/acid_act(acidpwr, acid_volume)
	.=..()
	if (prob(33) && acidpwr >= 10)
		if(helmet)
			if(next_warn_acid > world.time)
				return
			next_warn_acid = world.time + warn_acid_cooldown
			helmet.display_visor_message("Corrosive Chemical Detected!")
