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

/obj/effect/mob_spawn/ghost_role/venus_human_trap/equip(mob/living/basic/venus_human_trap/spawned_human_trap)
	if(spawned_human_trap && flower_bud)
		if(flower_bud.trait_flags & SPACEVINE_HEAT_RESISTANT)
			spawned_human_trap.unsuitable_heat_damage = 0
			spawned_human_trap.resistance_flags |= FIRE_PROOF
			ADD_TRAIT(spawned_human_trap, TRAIT_RESISTHEAT, INNATE_TRAIT)
		if(flower_bud.trait_flags & SPACEVINE_COLD_RESISTANT)
			spawned_human_trap.unsuitable_cold_damage = 0
			spawned_human_trap.resistance_flags |= FREEZE_PROOF
			ADD_TRAIT(spawned_human_trap, TRAIT_RESISTCOLD, INNATE_TRAIT)
		if(flower_bud.trait_flags & SPACEVINE_TOXIN_RESISTANT)
			ADD_TRAIT(spawned_human_trap, TRAIT_TOXIMMUNE, INNATE_TRAIT)
		if(flower_bud.trait_flags & SPACEVINE_AGGRESSIVE_SPREADING)
			spawned_human_trap.kudzu_off_distance_range = initial(spawned_human_trap.kudzu_off_distance_range) * 3
		if(flower_bud.trait_flags & SPACEVINE_HARDENED)
			spawned_human_trap.health = initial(spawned_human_trap.health) * 1.5
			spawned_human_trap.maxHealth = initial(spawned_human_trap.maxHealth) * 1.5
		if(flower_bud.trait_flags & SPACEVINE_THORNY)
			spawned_human_trap.melee_damage_lower = initial(spawned_human_trap.melee_damage_lower) * 0.5
			spawned_human_trap.melee_damage_upper = initial(spawned_human_trap.melee_damage_upper) * 0.5
			spawned_human_trap.obj_damage = initial(spawned_human_trap.obj_damage) * 0.5
			spawned_human_trap.wound_bonus = 5
			spawned_human_trap.exposed_wound_bonus = 15
			spawned_human_trap.sharpness = SHARP_POINTY
		if(flower_bud.trait_flags & SPACEVINE_LIGHT)
			spawned_human_trap.light_range = LIGHT_MUTATION_BRIGHTNESS
		if(flower_bud.trait_flags & SPACEVINE_TRANSPARENT)
			spawned_human_trap.alpha = 125
		if(flower_bud.trait_flags & SPACEVINE_EXPLOSIVE)
			RegisterSignal(spawned_human_trap, COMSIG_LIVING_DEATH, PROC_REF(on_death))
		if(flower_bud.trait_flags & SPACEVINE_TIMID)
			var/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/tangle_action
			tangle_action.Remove(spawned_human_trap)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/proc/on_death(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	SIGNAL_HANDLER

	explosion(spawned_mob, light_impact_range = EXPLOSION_MUTATION_IMPACT_RADIUS, adminlog = FALSE)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	flavour_text += "\nYou have the following vine mutations:\n"

	if(flower_bud.trait_flags & SPACEVINE_HEAT_RESISTANT)
		flavour_text += "\n<b>Heat Resistance</b> - Immune to extreme heat and fire"
	if(flower_bud.trait_flags & SPACEVINE_COLD_RESISTANT)
		flavour_text += "\n<b>Cold Resistance</b> - Immune to freezing temperatures"
	if(flower_bud.trait_flags & SPACEVINE_TOXIN_RESISTANT)
		flavour_text += "\n<b>Toxin Resistance</b> - Immune to chemical weedkillers and toxins"
	if(flower_bud.trait_flags & SPACEVINE_AGGRESSIVE_SPREADING)
		flavour_text += "\n<b>Aggressive Spreading</b> - Can travel farther away from vines before taking damage"
	if(flower_bud.trait_flags & SPACEVINE_HARDENED)
		flavour_text += "\n<b>Hardened</b> - Increased health"
	if(flower_bud.trait_flags & SPACEVINE_THORNY)
		flavour_text += "\n<b>Thorny</b> - Your physical attacks deal reduced damage but cause wounds"
	if(flower_bud.trait_flags & SPACEVINE_LIGHT)
		flavour_text += "\n<b>Light</b> - Your body emits a glowing light"
	if(flower_bud.trait_flags & SPACEVINE_TRANSPARENT)
		flavour_text += "\n<b>Transparency</b> - Your body is transparent"
	if(flower_bud.trait_flags & SPACEVINE_EXPLOSIVE)
		flavour_text += "\n<b>Explosive</b> - You will violently explode upon death"
	if(flower_bud.trait_flags & SPACEVINE_TIMID)
		flavour_text += "\n<b>Timid</b> - You no longer have the ability to shoot tangling vines at targets"

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
