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
	/// What crusher trophy this mob drops, if any
	var/crusher_loot

/mob/living/basic/boss/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_tearer, tear_time = 1 SECONDS)
	if(gps_name)
		AddComponent(/datum/component/gps, gps_name)
	if(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			guaranteed_drop = 0.6,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
		)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT, TRAIT_MARTIAL_ARTS_IMMUNE, TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE, TRAIT_NO_FLOATING_ANIM), MEGAFAUNA_TRAIT)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)

/mob/living/basic/boss/gib()
	if(health > 0)
		return
	return ..()

/mob/living/basic/boss/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return
	return ..()

/mob/living/basic/boss/death(gibbed)
	if (health > 0 && !gibbed) // prevents instakills
		return
	return ..()

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
