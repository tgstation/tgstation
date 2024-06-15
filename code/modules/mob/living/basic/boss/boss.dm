//(its almost megafauna!!, if someone actually wants to port megafauna this probably would be it but for now
//im using it for stuff both of them get
/mob/living/basic/boss
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
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
	can_buckle_to = FALSE
	faction = list(FACTION_MINING, FACTION_BOSS)
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	/// Loot dropped when the megafauna is NOT killed with a crusher
	var/list/loot
	/// Crusher loot dropped when the megafauna is killed with a crusher
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
	/// Attack actions, sets chosen_attack to the number in the action
	var/list/attack_action_types = list()
	/// Summoning line, said when summoned via megafauna vents.
	var/summon_line = "I'll kick your ass!"
	/// weather immunities
	var/list/weather_immunities = list(TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE)

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	if(gps_name && true_spawn)
		AddComponent(/datum/component/gps, gps_name)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	add_traits(weather_immunities, ROUNDSTART_TRAIT)
	grant_actions_by_list(attack_action_types)

/mob/living/basic/boss/death(gibbed, list/force_grant)
	if(gibbed) // in case they've been force dusted
		return ..()

	if(health > 0) // prevents instakills
		return
	var/datum/status_effect/crusher_damage/crusher_dmg = has_status_effect(/datum/status_effect/crusher_damage)
	///Whether we killed the megafauna with primarily crusher damage or not
	var/crusher_kill = (crusher_dmg && crusher_dmg.total_damage >= maxHealth * 0.6)
	for(var/loot in (crusher_kill ? crusher_loot : loot)) // might aswell just do it here because the element proves unreliable
		new loot(drop_location())

	loot.Cut() // no revive farming
	crusher_loot.Cut()

	if(true_spawn && !(flags_1 & ADMIN_SPAWNED_1) && !elimination)
		grant_achievement(achievement_type, score_achievement_type, crusher_kill, force_grant)
		SSblackbox.record_feedback("tally", "megafauna_kills[crusher_kill ? "_crusher" : ""]", 1, "[initial(name)]")
	return ..()

/mob/living/basic/boss/gib()
	if(health > 0)
		return

	return ..()

/mob/living/basic/boss/singularity_act()
	set_health(0)
	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return

	loot.Cut()
	crusher_loot.Cut()

	return ..()

/mob/living/basic/boss/melee_attack(mob/living/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()

	if(!istype(target))
		return

	if(!. && target.stat != DEAD) // we REALLY need to gut people or we waste time trying to melee someone to gut them
		return

	if(target.stat == DEAD || (target.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(target, TRAIT_NODEATH)))
		devour(target)
		return

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

/mob/living/basic/boss/proc/celebrate_kill(mob/living/L)
	visible_message(
		span_danger("[src] disembowels [L]!"),
		span_userdanger("You feast on [L]'s organs, restoring your health!"))

/mob/living/basic/boss/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)
		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)
		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

	return TRUE

/// Grants medals and achievements to surrounding players
/mob/living/basic/boss/proc/grant_achievement(medaltype, scoretype, crusher_kill, list/grant_achievement = list())
	if(!achievement_type || (flags_1 & ADMIN_SPAWNED_1) || !SSachievements.achievements_enabled) //Don't award medals if the medal type isn't set
		return FALSE
	if(!grant_achievement.len)
		for(var/mob/living/L in view(7,src))
			grant_achievement += L
	for(var/mob/living/L in grant_achievement)
		if(L.stat || !L.client)
			continue
		L.add_mob_memory(/datum/memory/megafauna_slayer, antagonist = src)
		L.client.give_award(/datum/award/achievement/boss/boss_killer, L)
		L.client.give_award(achievement_type, L)
		if(crusher_kill && istype(L.get_active_held_item(), /obj/item/kinetic_crusher))
			L.client.give_award(crusher_achievement_type, L)
		L.client.give_award(/datum/award/score/boss_score, L) //Score progression for bosses killed in general
		L.client.give_award(score_achievement_type, L) //Score progression for specific boss killed
	return TRUE
