/mob/living/basic/cow/gizmoo
	name = "gizmoo"
	desc = "This one smells of ash and brimstone."
	icon_state = "gizmoo"
	icon_dead = "gizmoo_dead"
	melee_damage_lower = 10
	melee_damage_upper = 10
	faction = list(FACTION_HOSTILE)
	gold_core_spawnable = NO_SPAWN
	milked_reagent = /datum/reagent/gunpowder

/mob/living/basic/cow/gizmoo/setup_udder()
	AddComponent(/datum/component/udder/explosive, reagent_produced_override = /datum/reagent/gunpowder)

/mob/living/basic/cow/gizmoo/death()
	icon_state = "gizmoo_udderless"
	return ..()
