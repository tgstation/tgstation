/datum/reagent/napalm/on_plant_apply(obj/item/seeds/seed)
	if(seed.resistance_flags & FIRE_PROOF)
		return

	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 6))
