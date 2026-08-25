/// Handles logic for ghost spawning code, visible object in game is handled by /obj/structure/alien/resin/flower_bud
/obj/effect/mob_spawn/ghost_role/venus_human_trap
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/mob/spacevines.dmi'
	icon_state = "bud0"
	mob_type = /mob/living/basic/venus_human_trap
	density = FALSE
	prompt_name = "venus human trap"
	you_are_text = "You are a venus human trap."
	flavour_text = "You are a venus human trap!  Protect the kudzu at all costs, and feast on those who oppose you!"
	faction = list(FACTION_HOSTILE, FACTION_VINES, FACTION_PLANTS)
	spawner_job_path = /datum/job/venus_human_trap
	invisibility = INVISIBILITY_ABSTRACT //The flower bud structure is our visible component, we just handle logic.
	/// Physical structure housing the spawner
	var/obj/structure/alien/resin/flower_bud/flower_bud
	/// Used to determine when to notify ghosts
	var/ready = FALSE

/obj/effect/mob_spawn/ghost_role/venus_human_trap/Destroy()
	if(flower_bud) // anti harddel checks
		if(!QDELETED(flower_bud))
			qdel(flower_bud)
		flower_bud = null
	return ..()

/obj/effect/mob_spawn/ghost_role/venus_human_trap/equip(mob/living/basic/venus_human_trap/venus_trap)
	if(!venus_trap || !flower_bud)
		return

	for(var/datum/spacevine_mutation/mutation in flower_bud.mutations)
		mutation.equip_venus_trap(venus_trap)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	if(flower_bud && length(flower_bud.mutations))
		var/list/flavour_mutation_list = list()
		flavour_mutation_list += "\nYou have the following vine mutations:"
		for(var/datum/spacevine_mutation/mutation in flower_bud.mutations)
			flavour_mutation_list += mutation.venus_flavor_text
		flavour_text += flavour_mutation_list.join("\n")
	. = ..()
	spawned_mob.mind.add_antag_datum(/datum/antagonist/venus_human_trap)

/// Called when the attached flower bud has borne fruit (ie. is ready)
/obj/effect/mob_spawn/ghost_role/venus_human_trap/proc/bear_fruit()
	ready = TRUE
	notify_ghosts(
		"[src] has borne fruit!",
		source = src,
		header = "Venus Human Trap",
		click_interact = TRUE,
		ignore_key = POLL_IGNORE_VENUSHUMANTRAP,
	)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/allow_spawn(mob/user, silent = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ready)
		if(!silent)
			to_chat(user, span_warning("\The [src] has not borne fruit yet!"))
		return FALSE
	return TRUE
