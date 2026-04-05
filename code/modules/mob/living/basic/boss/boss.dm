//not quite simple animal megafauna but close enough
// port actual megafauna stuff once it gets used for lavaland megafauna
//im using it for stuff both of them get
/mob/living/basic/boss
	combat_mode = TRUE
	status_flags = NONE
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
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	/// Name for the GPS signal of the megafauna
	var/gps_name = null
	/// What crusher trophy/trophies this mob drops, if any
	/// Should be wrapped in a list for sanity when we pass it to the element.
	var/list/crusher_loot = null
	/// Loot dropped on death in normal circumstances
	var/list/regular_loot = list()

	/// What achievements do we give our defeater?
	var/list/achievements = null
	/// What type of achievement we give for crusher kills, if any.
	var/crusher_achievement_type = null
	/// What memory to give to victor who have killed us, if any.
	var/victor_memory_type = null

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer, tear_time = 1 SECONDS)
	if(gps_name)
		AddComponent(/datum/component/gps, gps_name)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/death_drops, string_list(regular_loot))
	handle_crusher_loot()
	handle_achievements()

/mob/living/basic/boss/gib()
	if(health > 0)
		return
	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, give_moodlet, force)
	if(!force && health > 0)
		return
	return ..()

/mob/living/basic/boss/death(gibbed)
	if (health > 0 && !gibbed) // prevents instakills
		return
	return ..()

/mob/living/basic/boss/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjust_brute_loss(250)

		if (EXPLODE_HEAVY)
			adjust_brute_loss(100)

		if (EXPLODE_LIGHT)
			adjust_brute_loss(50)

	return TRUE

/mob/living/basic/boss/early_melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !istype(target))
		return
	if(should_devour(target))
		devour(target)

/// Determines if this mob is worth devouring
/mob/living/basic/boss/proc/should_devour(mob/living/victim)
	return victim.stat == DEAD || (victim.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(victim, TRAIT_NODEATH))

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
	victim.adjust_brute_loss(500)
	victim.death() //make sure they die
	victim.apply_status_effect(/datum/status_effect/gutted)
	return TRUE

/// Small little taunt when we epically troll someone
/mob/living/basic/boss/proc/celebrate_kill(mob/living/poor_sap)
	visible_message(
		span_danger("[src] disembowels [poor_sap]!"),
		span_userdanger("You feast on [poor_sap]'s organs, restoring your health!"),
	)

/// Handles adding all relevant achievements when applicable (probably when we are defeated)
/// Achievements being null/no length is handled in the element itself.
/mob/living/basic/boss/proc/handle_achievements()
	if(length(achievements) <= 0)
		return
	AddElement(/datum/element/kill_achievement, string_list(achievements), crusher_achievement_type, victor_memory_type)

/// Handles adding crusher loot when applicable (probably when we are defeated)
/mob/living/basic/boss/proc/handle_crusher_loot()
	if(isnull(crusher_loot))
		return
	AddElement(\
		/datum/element/crusher_loot,\
		trophy_type = string_list(crusher_loot),\
		guaranteed_drop = 0.6,\
		drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
	)

