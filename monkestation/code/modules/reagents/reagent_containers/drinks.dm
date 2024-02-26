/obj/item/reagent_containers/cup/glass/ice/Initialize(mapload, vol)
	. = ..()
	reagents.add_reagent(reagent = /datum/reagent/consumable/ice, amount = 30, reagtemp = WATER_MATTERSTATE_CHANGE_TEMP)
