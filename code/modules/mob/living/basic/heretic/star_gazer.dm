/mob/living/basic/heretic_summon/star_gazer
	name = "\improper Star Gazer"
	desc = "A creature that has been tasked to watch over the stars."
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	mob_biotypes = MOB_HUMANOID | MOB_SPECIAL
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	speed = -0.2
	maxHealth = 6000
	health = 6000

	obj_damage = 400
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attack_verb_continuous = "ravages"
	attack_verb_simple = "ravage"
	attack_vis_effect = ATTACK_EFFECT_SLASH
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	melee_attack_cooldown = 0.6 SECONDS
	speak_emote = list("growls")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/effects/magic/cosmic_expansion.ogg'

	slowed_by_drag = FALSE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	ai_controller = /datum/ai_controller/basic_controller/star_gazer
	/// Reference to the mob which summoned us
	var/datum/weakref/summoner

	//---- Abilities given to the star gazer mob
	var/datum/action/cooldown/spell/conjure/cosmic_expansion/expansion
	var/datum/action/cooldown/spell/pointed/projectile/star_blast/blast
	var/datum/action/cooldown/recall_stargazer/recall
	var/datum/action/cooldown/stargazer_laser/giga_laser

/mob/living/basic/heretic_summon/star_gazer/Initialize(mapload)
	. = ..()
	expansion = new(src)
	expansion.Grant(src)
	blast = new(src)
	blast.Grant(src)
	recall = new(src)
	recall.Grant(src)
	giga_laser = new(src)
	giga_laser.Grant(src)
	var/static/list/death_loot = list(/obj/effect/temp_visual/cosmic_domain)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/death_explosion, 3, 6, 12)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/wall_smasher, ENVIRONMENT_SMASH_RWALLS)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	AddElement(/datum/element/ai_target_damagesource)
	AddComponent(/datum/component/regenerator, outline_colour = "#b97a5d")
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	set_light(4, l_color = "#dcaa5b")
	INVOKE_ASYNC(src, PROC_REF(beg_for_ghost))
	RegisterSignal(src, COMSIG_MOB_GHOSTIZED, PROC_REF(beg_for_ghost))

/// Tries to find a ghost to take control of the mob. If no ghost accepts, ask again in a bit
/mob/living/basic/heretic_summon/star_gazer/proc/beg_for_ghost()
	var/mob/chosen_ghost = SSpolling.poll_ghost_candidates("Do you want to play as an ascended heretic's stargazer?", check_jobban = ROLE_HERETIC, poll_time = 20 SECONDS, ignore_category = POLL_IGNORE_HERETIC_MONSTER, alert_pic = mutable_appearance('icons/mob/nonhuman-player/96x96eldritch_mobs.dmi', "star_gazer"), jump_target = src, role_name_text = "star gazer", amount_to_pick = 1)
	if(chosen_ghost)
		PossessByPlayer(chosen_ghost.key)
	else
		addtimer(CALLBACK(src, PROC_REF(beg_for_ghost)), 2 MINUTES) // Keep begging until someone accepts

// Star gazer attacks everything around itself applies a spooky mark
/mob/living/basic/heretic_summon/star_gazer/melee_attack(mob/living/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/star_mark)
	target.apply_damage(damage = 5, damagetype = BURN)
	var/datum/targeting_strategy/target_confirmer = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY])
	for(var/mob/living/nearby_mob in range(1, src))
		if(target == nearby_mob || !target_confirmer?.can_attack(src, nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.apply_damage(10)
		to_chat(nearby_mob, span_userdanger("\The [src] [attack_verb_continuous] you!"))
		do_attack_animation(nearby_mob, ATTACK_EFFECT_SLASH)
		log_combat(src, nearby_mob, "slashed")

/*
/mob/living/basic/heretic_summon/star_gazer/RangedAttack(atom/target, modifiers)
	. = ..()
	if(!combat_mode || target == summoner?.resolve())
		return
	changeNext_move(melee_attack_cooldown)
	if(isopenturf(target))
		return
	if(laser_beam)
		QDEL_NULL(laser_beam)
	laser_beam = Beam(target, icon_state = "plasmabeam", icon = 'icons/effects/beam.dmi')

/mob/living/basic/heretic_summon/star_gazer/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!laser_beam)
		return
	if(laser_beam.target)
		process_beam(seconds_per_tick, laser_beam.target)

/// Processes the beam every life tick, depending on what we are targetting
/mob/living/basic/heretic_summon/star_gazer/proc/process_beam(seconds_per_tick, atom/target)
	if(iswallturf(target))
		var/turf/target_turf = target
		target_turf.ChangeTurf()
		QDEL_NULL(laser_beam)
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat < CONSCIOUS)
			living_target.dust()
			QDEL_NULL(laser_beam)
		living_target.apply_status_effect(/datum/status_effect/star_mark)
		living_target.apply_damage(damage = 15, damagetype = BURN)
*/

/datum/action/cooldown/recall_stargazer
	name = "Seek master"
	desc = "Teleports you to your master"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "stargazer_menu"
	check_flags = NONE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/recall_stargazer/Activate(atom/target)
	var/mob/living/basic/heretic_summon/star_gazer/real_owner = owner
	var/mob/living/master = real_owner.summoner?.resolve()
	if(!master)
		return FALSE
	do_teleport(owner, master, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE)
	StartCooldown()
	return TRUE

/datum/action/cooldown/stargazer_laser
	name = "Activate laser"
	desc = "Generates a massive death beam that destroys everything in it's path"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "stargazer_menu"
	check_flags = NONE
	cooldown_time = 5 SECONDS
	/// list of turfs we are hitting while shooting our beam
	var/list/turf/targets
	/// The laser beam we generate
	var/datum/beam/giga_laser
	/// Timer that handles the damage ticking
	var/damage_timer

/datum/action/cooldown/stargazer_laser/Activate(atom/target)
	. = ..()

	if(damage_timer)
		stop_beaming()

	var/turf/check_turf = get_step(owner, owner.dir)
	LAZYINITLIST(targets)
	while(check_turf && length(targets) < 20)
		targets += check_turf
		check_turf = get_step(check_turf, owner.dir)
	if(!LAZYLEN(targets))
		return

	if(!do_after(owner, 2 SECONDS, owner))
		QDEL_NULL(giga_laser)
		targets = null
		return

	giga_laser = owner.Beam(targets[length(targets)], icon_state = "plasmabeam", icon = 'icons/effects/beam.dmi', override_origin_pixel_x = 8)
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), PROC_REF(stop_beaming))
	process_beam()

/// Recursive proc which affects whatever is caught within the beam
/datum/action/cooldown/stargazer_laser/proc/process_beam()
	for(var/turf/target as anything in targets)
		if(iswallturf(target))
			var/turf/closed/wall/wall_target = target
			wall_target.dismantle_wall(devastated = TRUE)
			continue
		for(var/victim in target)
			if(isliving(victim))
				var/mob/living/living_victim = victim
				if(living_victim.stat > CONSCIOUS)
					living_victim.dust()
				living_victim.apply_status_effect(/datum/status_effect/star_mark)
				living_victim.apply_damage(damage = 10, damagetype = BURN)
	damage_timer = addtimer(CALLBACK(src, PROC_REF(process_beam)), 0.3 SECONDS, TIMER_STOPPABLE)

/// Stops the beam after we cancel it
/datum/action/cooldown/stargazer_laser/proc/stop_beaming()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(giga_laser)
	deltimer(damage_timer)
	damage_timer = null
	targets = null

/datum/ai_controller/basic_controller/star_gazer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends/attack_everything,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_behavior/attack_obstructions/star_gazer
	action_cooldown = 0.4 SECONDS
	can_attack_turfs = TRUE
	can_attack_dense_objects = TRUE

/datum/pet_command/attack/star_gazer
	speech_commands = list("attack", "sic", "kill", "slash them")
	command_feedback = "stares!"
	pointed_reaction = "stares intensely!"
	refuse_reaction = "..."
	attack_behaviour = /datum/ai_behavior/basic_melee_attack
