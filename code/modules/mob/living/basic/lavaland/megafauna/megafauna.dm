/// megafauna specific behavior
/mob/living/basic/mining/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	obj_damage = 400
	light_range = 3
	faction = list(FACTION_MINING, FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, STAMINA = 0, OXY = 1)
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	can_buckle_to = FALSE

	// special handling of crusher loot, so no normal logic
	crusher_loot = null
	///List of things spawned at megafauna's loc when it dies.
	var/list/megafauna_loot = list()
	///list of things spawned ALTERNATIVELY when a crusher kills the megafauna.
	var/list/crusher_alternate_loot = list()

	/// Achievement given to surrounding players when the megafauna is killed
	var/achievement_type
	/// Crusher achievement given to players when megafauna is killed
	var/crusher_achievement_type
	/// Score given to players when megafauna is killed
	var/score_achievement_type
	/// If the megafauna was actually killed (not just dying, then transforming into another type)
	var/elimination = 0
	/// Modifies attacks when at lower health
	var/anger_modifier = 0
	/// Name for the GPS signal of the megafauna
	var/gps_name = null
	/// If this is a megafauna that is real (has achievements, gps signal)
	var/true_spawn = TRUE

/mob/living/basic/mining/megafauna/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cheese_avoidant)
	if(megafauna_loot || crusher_alternate_loot)
		AddElement(
			/datum/element/death_drops,\
			list(),\
			CALLBACK(src, PROC_REF(on_death_loot)),\
		)

/mob/living/basic/mining/megafauna/singularity_act()
	set_health(0)
	return ..()

/mob/living/basic/mining/megafauna/dust(just_ash, drop_items, force)
	//already does not dust unless 0 health, but no loot even so
	megafauna_loot.Cut()
	crusher_alternate_loot.Cut()
	return ..()

// could be moved into cheese avoidant in the future? felt it was unique enough to keep as-is
/mob/living/basic/mining/megafauna/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)

		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)

		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

	return TRUE

/// Devours a target and restores health to the megafauna,
/// generally useful common megafauna behavior to end fights once crit
/mob/living/basic/mining/megafauna/proc/devour(mob/living/victim)
	if(isnull(victim) || victim.has_status_effect(/datum/status_effect/gutted))
		return FALSE
	celebrate_kill(victim)
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		heal_overall_damage(victim.maxHealth * 0.5)
	victim.investigate_log("has been devoured by [src].", INVESTIGATE_DEATHS)
	if(iscarbon(victim))
		qdel(victim.get_organ_slot(ORGAN_SLOT_LUNGS))
		qdel(victim.get_organ_slot(ORGAN_SLOT_HEART))
		qdel(victim.get_organ_slot(ORGAN_SLOT_LIVER))
	victim.adjustBruteLoss(500)
	victim.death() //make sure they die
	victim.apply_status_effect(/datum/status_effect/gutted)
	return TRUE

///visual part of devour() to override for flavor reasons
/mob/living/basic/mining/megafauna/proc/celebrate_kill(mob/living/loser)
	visible_message(
		span_danger("[src] disembowels [loser]!"),
		span_userdanger("You feast on [loser]'s organs, restoring your health!"))


///callback to decide whether normal or crusher loot should drop
/mob/living/basic/mining/megafauna/proc/on_death_loot(gibbed)
	var/list/dropped_loot
	var/datum/status_effect/crusher_damage/damage = has_status_effect(/datum/status_effect/crusher_damage)
	var/valid_crusher_kill = damage && damage.total_damage >= maxHealth * 0.6

	if(valid_crusher_kill)
		dropped_loot = crusher_alternate_loot
	else
		dropped_loot = megafauna_loot

	if(true_spawn && !(flags_1 & ADMIN_SPAWNED_1))
		var/tab = "megafauna_kills"
		if(valid_crusher_kill)
			tab = "megafauna_kills_crusher"
		if(!elimination) //used so the achievment only occurs for the last legion to die.
			grant_achievement(achievement_type, score_achievement_type, valid_crusher_kill)
			SSblackbox.record_feedback("tally", tab, 1, "[initial(name)]")

	return dropped_loot

/// Grants medals and achievements to surrounding players
/mob/living/basic/mining/megafauna/proc/grant_achievement(medaltype, scoretype, crusher_kill)
	if(!achievement_type || (flags_1 & ADMIN_SPAWNED_1) || !SSachievements.achievements_enabled) //Don't award medals if the medal type isn't set
		return FALSE
	for(var/mob/living/victor in view(7,src))
		if(victor.stat || !victor.client)
			continue
		victor.add_mob_memory(/datum/memory/megafauna_slayer, antagonist = src)
		victor.client.give_award(/datum/award/achievement/boss/boss_killer, victor)
		victor.client.give_award(achievement_type, victor)
		if(crusher_kill && istype(victor.get_active_held_item(), /obj/item/kinetic_crusher))
			victor.client.give_award(crusher_achievement_type, victor)
		victor.client.give_award(/datum/award/score/boss_score, victor) //Score progression for bosses killed in general
		victor.client.give_award(score_achievement_type, victor) //Score progression for specific boss killed
	return TRUE
