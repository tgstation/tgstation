/datum/reagent/toxin/plantbgone/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 10))

/datum/reagent/toxin/plantbgone/weedkiller/on_plant_apply(obj/item/seeds/seed)


/datum/reagent/toxin/acid/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 1))

/datum/reagent/toxin/acid/fluacid/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 2))
