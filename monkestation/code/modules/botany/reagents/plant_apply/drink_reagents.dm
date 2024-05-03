/datum/reagent/consumable/milk/on_plant_apply(obj/item/seeds/seed)
	seed.adjust_potency(-volume * 0.5)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.1))

/datum/reagent/consumable/sodawater/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.15))
