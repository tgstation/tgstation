//not quite simple animal megafauna but close enough
// port actual megafauna stuff once it gets used for lavaland megafauna
//im using it for stuff both of them get
/mob/living/basic/boss
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	faction = list(FACTION_MINING, FACTION_BOSS)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 400
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	/// Loot if not killed by crusher. ONLY matters on initialize.
	var/list/loot
	/// Loot if killed by crusher. ONLY matters on initialize.
	var/list/crusher_loot
	/// Achievement given to surrounding players when the megafauna is killed
	var/achievement_type
	/// Crusher achievement given to players when megafauna is killed
	var/crusher_achievement_type
	/// Score given to players when megafauna is killed
	var/score_achievement_type
	/// If the megafauna was actually killed (not just dying, then transforming into another type)
	var/elimination = FALSE
	/// Name for the GPS signal of the megafauna
	var/gps_name = null
	/// If this is a megafauna that is real (has achievements, gps signal)
	var/true_spawn = TRUE

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer, tear_time = 1 SECONDS)
	if(gps_name && true_spawn)
		AddComponent(/datum/component/gps, gps_name)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	if(!isnull(loot))
		AddElement(/datum/element/death_drops, string_list(loot))
	if(!isnull(crusher_loot))
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = islist(crusher_loot) ? string_list(crusher_loot) : crusher_loot,\
			drop_mod = 100,\
			drop_immediately = TRUE,\
		)

/mob/living/basic/boss/gib()
	if(health > 0)
		return

	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return

	RemoveElement(/datum/element/death_drops)
	RemoveElement(/datum/element/crusher_loot)

	return ..()

/mob/living/basic/boss/death(gibbed, list/force_grant)
	if(gibbed) // in case they've been force dusted
		return ..()

	if(health > 0) // prevents instakills
		return
	var/datum/status_effect/crusher_damage/crusher_dmg = has_status_effect(/datum/status_effect/crusher_damage)
	///Whether we killed the megafauna with primarily crusher damage or not
	var/crusher_kill = FALSE
	if(crusher_dmg && crusher_dmg.total_damage >= maxHealth * 0.6)
		crusher_kill = TRUE
		if(crusher_loot)
			RemoveElement(/datum/element/death_drops)
	if(true_spawn && !(flags_1 & ADMIN_SPAWNED_1))
		var/tab = "megafauna_kills"
		if(crusher_kill)
			tab = "megafauna_kills_crusher"
		if(!elimination) //used so the achievment only occurs for the last legion to die.
			grant_achievement(achievement_type, score_achievement_type, crusher_kill, force_grant)
			SSblackbox.record_feedback("tally", tab, 1, "[initial(name)]")
	return ..()

/// Grants medals and achievements to surrounding players
/mob/living/basic/boss/proc/grant_achievement(medaltype, scoretype, crusher_kill, list/grant_achievement = list())
	if(!achievement_type || (flags_1 & ADMIN_SPAWNED_1) || !SSachievements.achievements_enabled) //Don't award medals if the medal type isn't set
		return FALSE
	if(!grant_achievement.len)
		for(var/mob/living/victor in view(7,src))
			grant_achievement += victor
	for(var/mob/living/victor in grant_achievement)
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

/mob/living/basic/boss/early_melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !istype(target))
		return
	if(target.stat == DEAD || (target.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(target, TRAIT_NODEATH)))
		devour(target)

/// Devours a target and restores health to the megafauna
/mob/living/basic/boss/proc/devour(mob/living/victim)
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

/mob/living/basic/boss/proc/celebrate_kill(mob/living/poor_sap)
	visible_message(
		span_danger("[src] disembowels [poor_sap]!"),
		span_userdanger("You feast on [poor_sap]'s organs, restoring your health!"))

/mob/living/basic/boss/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)

		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)

		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

	return TRUE
