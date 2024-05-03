/datum/reagent/consumable/nutriment/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.2))

/datum/reagent/consumable/virus_food/on_plant_apply(obj/item/seeds/seed)
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, -round(volume * 0.5))

/datum/reagent/consumable/honey/on_plant_apply(obj/item/seeds/seed)
	seed.adjust_maturation(rand(1,2))
	seed.adjust_lifespan(rand(1,2))
