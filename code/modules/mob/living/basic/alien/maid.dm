/mob/living/basic/alien/maid
	name = "lusty xenomorph maid"
	melee_damage_lower = 0
	melee_damage_upper = 0
	combat_mode = FALSE
	friendly_verb_continuous = "caresses"
	friendly_verb_simple = "caress"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	icon_state = "maid"
	icon_living = "maid"
	icon_dead = "maid_dead"

/mob/living/basic/alien/maid/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cleaning)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

///Handles the maid attacking other players, cancelling the attack to clean up instead.
/mob/living/basic/alien/maid/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER
	target.wash(CLEAN_SCRUB)
	if(istype(target, /obj/effect/decal/cleanable))
		visible_message(span_notice("[src] cleans up \the [target]."))
	else
		visible_message(span_notice("[src] polishes \the [target]."))
	return COMPONENT_HOSTILE_NO_ATTACK

/**
 * Barmaid special type
 * Spawns on emergency shuttles, has access to them and godmode while inside of them.
 */
/mob/living/basic/alien/maid/barmaid
	gold_core_spawnable = NO_SPAWN
	name = "Barmaid"
	desc = "A barmaid, a maiden found in a bar."
	pass_flags = PASSTABLE
	unique_name = FALSE
	initial_language_holder = /datum/language_holder/universal

	ai_controller = null //they don't have their own AI and can uniquely only be controlled by players.

	///The access card we use to store access to the emergency shuttle.
	var/obj/item/card/id/access_card

/mob/living/basic/alien/maid/barmaid/Initialize(mapload)
	. = ..()
	// Simple bot ID card that can hold all accesses. Someone turn access into a component at some point, please.
	access_card = new /obj/item/card/id/advanced/simple_bot(src)

	var/datum/id_trim/job/cap_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/captain]
	access_card.add_access(cap_trim.access + cap_trim.wildcard_access + list(ACCESS_CENT_BAR))

	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	AddComponentFrom(ROUNDSTART_TRAIT, /datum/component/area_based_godmode, area_type = /area/shuttle/escape, allow_area_subtypes = TRUE)

/mob/living/basic/alien/maid/barmaid/Destroy()
	QDEL_NULL(access_card)
	return ..()
