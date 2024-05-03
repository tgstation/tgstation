/datum/reagent/consumable/ethanol/on_plant_apply(obj/item/seeds/seed)
	seed.process_trait_gain(/datum/plant_gene/trait/brewing, ((volume * 0.25) + (boozepwr * 0.1)))

/datum/reagent/consumable/ethanol/beer/on_plant_apply(obj/item/seeds/seed)
	. = ..()
	SEND_SIGNAL(seed, COMSIG_ADJUST_PLANT_HEALTH, round(volume * 0.1))
