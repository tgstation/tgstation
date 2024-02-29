/obj/item/reagent_containers/cup/glass/ice/Initialize(mapload, vol)
	. = ..()
	reagents.add_reagent(reagent = /datum/reagent/consumable/ice, amount = 30, reagtemp = WATER_MATTERSTATE_CHANGE_TEMP)

/obj/item/reagent_containers/cup/glass/ice/prison/Initialize(mapload, vol)
	. = ..()
	reagents.remove_reagent(reagent = /datum/reagent/consumable/ice, amount = 5)
	reagents.add_reagent(reagent = /datum/reagent/consumable/liquidgibs, amount = 5, reagtemp = WATER_MATTERSTATE_CHANGE_TEMP)
