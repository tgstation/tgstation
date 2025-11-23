/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	abstract_type = /mob/living/simple_animal/hostile/megafauna
	health = 1000
	maxHealth = 1000
	combat_mode = TRUE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL|MOB_MINING
	obj_damage = 400
	light_range = 3
	faction = list(FACTION_MINING, FACTION_BOSS)
	weather_immunities = list(TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE)
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = DEAD
	atmos_requirements = null
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, STAMINA = 0, OXY = 1)
	minbodytemp = 0
	maxbodytemp = INFINITY
	vision_range = 5
	aggro_vision_range = 18
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	can_buckle_to = FALSE
	/// Crusher loot dropped when the megafauna is killed with a crusher
	var/list/crusher_loot
	/// Should the crusher drop replace our main loot entirely?
	var/replace_crusher_drop = FALSE
	/// Achievement given to surrounding players when the megafauna is killed
	var/achievement_type
	/// Crusher achievement given to players when megafauna is killed
	var/crusher_achievement_type
	/// Score given to players when megafauna is killed
	var/score_achievement_type
	/// Modifies attacks when at lower health
	var/anger_modifier = 0
	/// Name for the GPS signal of the megafauna
	var/gps_name = null
	/// Next time the megafauna can use a melee attack
	var/recovery_time = 0
	/// If this is a megafauna that is real (has achievements, gps signal)
	var/true_spawn = TRUE
	/// The chosen attack by the megafauna
	var/chosen_attack = 1
	/// Attack actions, sets chosen_attack to the number in the action
	var/list/attack_action_types = list()
	/// Summoning line, said when summoned via megafauna vents.
	var/summon_line = "I'll kick your ass!"
	///any delay before we start attacking something near us
	var/attack_delay = 0.25 SECONDS

/mob/living/simple_animal/hostile/megafauna/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/basic_mob_attack_telegraph,\
		display_telegraph_overlay = FALSE,\
		telegraph_duration = attack_delay,\
	)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/simple_flying)
	if (achievement_type || score_achievement_type)
		var/list/achievements = list(/datum/award/achievement/boss/boss_killer, /datum/award/score/boss_score)
		if (achievement_type)
			achievements += achievement_type
		if (score_achievement_type)
			achievements += score_achievement_type
		AddElement(/datum/element/kill_achievement, string_list(achievements), crusher_achievement_type, /datum/memory/megafauna_slayer)
	if(gps_name && true_spawn)
		AddComponent(/datum/component/gps, gps_name)
	if(crusher_loot)
		if (islist(crusher_loot))
			crusher_loot = string_list(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			guaranteed_drop = 0.6,\
			replace_all = replace_crusher_drop,\
			drop_immediately = del_on_death,\
		)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_traits(list(TRAIT_NO_TELEPORT), MEGAFAUNA_TRAIT)
	grant_actions_by_list(attack_action_types)

/mob/living/simple_animal/hostile/megafauna/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	//Safety check
	if(!loc)
		return ..()
	return ..()

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0 && !gibbed) // prevents instakills
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/singularity_act()
	set_health(0)
	return ..()

/mob/living/simple_animal/hostile/megafauna/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return
	loot.Cut()
	return ..()

/mob/living/simple_animal/hostile/megafauna/AttackingTarget(atom/attacked_target)
	if(recovery_time >= world.time)
		return
	. = ..()
	if(target && !CanAttack(target))
		LoseTarget()
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat == DEAD || (living_target.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(living_target, TRAIT_NODEATH)))
		devour(living_target)
		return
	if(isnull(client) && ranged && ranged_cooldown <= world.time)
		OpenFire()

/// Devours a target and restores health to the megafauna
/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/victim)
	if(isnull(victim) || victim.has_status_effect(/datum/status_effect/gutted))
		LoseTarget()
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
	LoseTarget()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/proc/celebrate_kill(mob/living/L)
	visible_message(
		span_danger("[src] disembowels [L]!"),
		span_userdanger("You feast on [L]'s organs, restoring your health!"))

/mob/living/simple_animal/hostile/megafauna/CanAttack(atom/the_target)
	. = ..()
	if (!.)
		return FALSE
	if(!isliving(the_target))
		return TRUE
	var/mob/living/living_target = the_target
	return !living_target.has_status_effect(/datum/status_effect/gutted)

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)

		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)

		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

	return TRUE

/// Sets/adds the next time the megafauna can use a melee or ranged attack, in deciseconds. It is a list to allow using named args. Use the ignore_staggered var if youre setting the cooldown to ranged_cooldown_time.
/mob/living/simple_animal/hostile/megafauna/proc/update_cooldowns(list/cooldown_updates, ignore_staggered = FALSE)
	if(!ignore_staggered && has_status_effect(/datum/status_effect/rebuked))
		for(var/update in cooldown_updates)
			cooldown_updates[update] *= 2
	if(cooldown_updates[COOLDOWN_UPDATE_SET_MELEE])
		recovery_time = world.time + cooldown_updates[COOLDOWN_UPDATE_SET_MELEE]
	if(cooldown_updates[COOLDOWN_UPDATE_ADD_MELEE])
		recovery_time += cooldown_updates[COOLDOWN_UPDATE_ADD_MELEE]
	if(cooldown_updates[COOLDOWN_UPDATE_SET_RANGED])
		ranged_cooldown = world.time + cooldown_updates[COOLDOWN_UPDATE_SET_RANGED]
	if(cooldown_updates[COOLDOWN_UPDATE_ADD_RANGED])
		ranged_cooldown += cooldown_updates[COOLDOWN_UPDATE_ADD_RANGED]

/datum/action/innate/megafauna_attack
	name = "Megafauna Attack"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = ""
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/megafauna_attack/Grant(mob/living/L)
	if(!ismegafauna(L))
		return FALSE
	return ..()

/datum/action/innate/megafauna_attack/Activate()
	var/mob/living/simple_animal/hostile/megafauna/fauna = owner
	fauna.chosen_attack = chosen_attack_num
	to_chat(fauna, chosen_message)
