/mob/living/basic/cow/gizmoo
	name = "gizmoo"
	desc = "This one smells of ash and brimstone."
	icon_state = "gizmoo"
	icon_dead = "gizmoo_dead"
	icon_gib = "gizmoo_gib"
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

/datum/targeting_strategy/basic/allow_items/tameable/gizmoo
	tame_food = /obj/item/food/grown/wheat

/datum/ai_controller/basic_controller/cow/gizmoo
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/cow/hostile.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items/tameable/gizmoo,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("moo?", "moo", "MOOOOOO"),
			BB_EMOTE_HEAR = list("brays."),
			BB_EMOTE_SEE = list("shakes her head."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/cow/cow.ogg'),
			BB_SPEAK_CHANCE = 1,
		),
	)
