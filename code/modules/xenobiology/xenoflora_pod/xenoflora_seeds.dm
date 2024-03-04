/obj/item/xeno_seeds
	name = "xenoflora seeds"
	icon = 'icons/obj/xenobiology/equipment.dmi'
	icon_state = "xenoseeds"
	w_class = WEIGHT_CLASS_TINY

	var/plant_type = /datum/xenoflora_plant

/obj/item/xeno_seeds/Initialize(mapload)
	. = ..()
	var/datum/xenoflora_plant/plant = plant_type
	name = "[lowertext(initial(plant.name))] seeds"
	desc = "Description on the packet reads: [initial(plant.desc)]"
	icon_state = initial(plant.seeds_icon_state)
	update_icon()

// Tier 2 plants

/obj/item/xeno_seeds/broombush
	plant_type = /datum/xenoflora_plant/broombush

/obj/item/xeno_seeds/cubomelon
	plant_type = /datum/xenoflora_plant/cubomelon

/obj/item/xeno_seeds/bluespace_limon
	plant_type = /datum/xenoflora_plant/bluespace_limon

/obj/item/xeno_seeds/pyrite_peaches
	plant_type = /datum/xenoflora_plant/pyrite_peaches
