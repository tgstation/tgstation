/mob/living/basic/cow/gizmoo
	name = "gizmoo"
	desc = "This one smells of ash and brimstone."
	icon_state = "gizmoo"
	melee_damage_lower = 10
	melee_damage_upper = 10
	faction = list(FACTION_HOSTILE)
	gold_core_spawnable = NO_SPAWN
	milked_reagent = /datum/reagent/gunpowder

/mob/living/basic/cow/gizmoo/death(gibbed)
	if(!gibbed)
		var/obj/item/udder/udder = locate(/obj/item/udder) in src
		if(udder)
			udder.reagents.chem_temp = 1000
			udder.reagents.handle_reactions() // Exploding udder
	return ..()
