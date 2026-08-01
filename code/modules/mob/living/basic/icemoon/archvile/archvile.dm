/mob/living/basic/mining/archvile
	name = "archvile"
	desc = "A being of pure hatred, reveling in misery. Channels plasmafires at you, and isn't done with you even if you die."
	icon = 'icons/mob/simple/icemoon/archvile.dmi'
	icon_state = "archvile"
	icon_living = "archvile"
	icon_dead = "archvile_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_MINING

	friendly_verb_continuous = "growls at"
	friendly_verb_simple = "growl at"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	habitable_atmos = null
	pixel_x = -8
	speed = 0.2
	maxHealth = 500
	health = 500
	obj_damage = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	wound_bonus = -5
	exposed_wound_bonus = 10
	sharpness = SHARP_EDGED

	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/stack/sheet/mineral/plasma = 3, /obj/item/stack/sheet/bone = 2)
	crusher_loot = null

	var/datum/action/cooldown/mob_cooldown/archvile_rez/resurrect
	var/datum/action/cooldown/mob_cooldown/archvile_fire/fire_attack
	ai_controller = /datum/ai_controller/basic_controller/archvile
	idle_sound = 'sound/effects/nightmare_reappear.ogg'
	pain_sound = 'sound/mobs/non-humanoids/archvile/pain.ogg'
	aggro_sound = 'sound/mobs/non-humanoids/archvile/aggro.ogg'
	death_sound = 'sound/mobs/non-humanoids/archvile/death.ogg'
	pain_chance = 10
	pain_stun = 0.2 SECONDS

/mob/living/basic/mining/archvile/Initialize(mapload)
	. = ..()

	add_traits(list(TRAIT_SPACEWALK, TRAIT_SNOWSTORM_IMMUNE, TRAIT_NO_ARCHVILE_REVIVE), INNATE_TRAIT)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_CLAW)
	resurrect = new(src)
	resurrect.Grant(src)
	fire_attack = new(src)
	fire_attack.Grant(src)
	ai_controller.set_blackboard_key(BB_ARCHVILE_FIRE, fire_attack)
	ai_controller.set_blackboard_key(BB_ARCHVILE_REZ, resurrect)

/mob/living/basic/mining/archvile/Destroy(force)
	QDEL_NULL(resurrect)
	return ..()

/datum/ai_controller/basic_controller/archvile
	behavior_tree_json = "code/modules/mob/living/basic/icemoon/archvile/archvile.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ARCHVILE_REZ_STRATEGY = /datum/targeting_strategy/basic/archvile_rez,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_TARGET_MAXIMUM_STAT = STABLE,
		BB_ARCHVILE_REZ_MINIMUM_STAT = DEAD,
		BB_ARCHVILE_REZ_TARGET = null,
		BB_ARCHVILE_REZ_HIDING_LOCATION = null,
		BB_AGGRO_RANGE = 9,
		BB_STANDOFF_DISTANCE_MAX = 5,
		BB_STANDOFF_DISTANCE_MIN = 3,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/targeting_strategy/basic/archvile_rez
	minimum_stat_key = BB_ARCHVILE_REZ_MINIMUM_STAT
	maximum_stat_key = BB_ARCHVILE_REZ_MINIMUM_STAT
	ignore_faction = TRUE

/datum/targeting_strategy/basic/archvile_rez/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if (!.)
		return FALSE
	if(HAS_TRAIT(the_target, TRAIT_NO_ARCHVILE_REVIVE))
		return FALSE

/datum/action/cooldown/mob_cooldown/archvile_rez
	name = "Resurrect Mob"
	desc = "Use your plasma powers to revive mobs or some shit."
	shared_cooldown = MOB_SHARED_COOLDOWN_1
	cooldown_time = 3 SECONDS
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

/datum/action/cooldown/mob_cooldown/archvile_rez/Activate(atom/target_atom)
	if(target_atom == owner)
		to_chat(owner, span_warning("You can't revive yourself!"))
		return
	if(!isliving(target_atom))
		to_chat(owner, span_warning("That's not able to be revived!"))
		return
	var/mob/living/living_target = target_atom
	if(living_target.stat != DEAD)
		to_chat(owner, span_warning("You can't revive that which isn't dead!"))
		return
	if(HAS_TRAIT(living_target, TRAIT_NO_ARCHVILE_REVIVE))
		to_chat(owner, span_warning("That's too powerful for you to revive!"))
		return
	if (istype(owner, /mob/living/basic/mining/archvile))
		var/mob/living/basic/mining/archvile/vile = owner
		vile.icon_state = "archvile_rez"
		var/mutable_appearance/emissive_sprite = emissive_appearance('icons/mob/simple/icemoon/archvile.dmi', "archvile_rez_emissive", vile)
		vile.add_overlay(emissive_sprite)
	revive_mob(owner, living_target)
	sleep(1 SECONDS)
	if (istype(owner, /mob/living/basic/mining/archvile))
		var/mob/living/basic/mining/archvile/vile = owner
		vile.icon_state = "archvile"
		vile.update_appearance(UPDATE_OVERLAYS)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/archvile_rez/proc/revive_mob(mob/living/archvile, mob/living/target)
	playsound(target, 'sound/effects/goresplat.ogg', 100)
	to_chat(target, span_userdanger("You are brought back to life by [archvile]!"))
	archvile.visible_message(span_warning("[archvile] resurrects [target]!"))
	target.revive(HEAL_ARCHVILE)

/datum/action/cooldown/mob_cooldown/archvile_fire
	name = "Archvile Fire"
	desc = "Light a line in front of you on fire!"
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "brimdemon_firing"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0
	/// How far do we light on fire?
	var/beam_range = 5
	/// How long do we wind up before firing?
	var/charge_duration = 0.25 SECONDS

/obj/effect/temp_visual/telegraphing/line/archvile
	duration = 0.25 SECONDS

/datum/action/cooldown/mob_cooldown/archvile_fire/Activate(atom/target)
	StartCooldown(69 SECONDS)
	owner.face_atom(target)
	owner.icon_state = "archvile_attack"
	if (istype(owner, /mob/living/basic/mining/archvile))
		var/mob/living/basic/mining/archvile/vile = owner
		vile.icon_state = "archvile_attack"
		var/mutable_appearance/emissive_sprite = emissive_appearance('icons/mob/simple/icemoon/archvile.dmi', "archvile_attack_emissive", vile)
		vile.add_overlay(emissive_sprite)
	playsound(owner, 'sound/mobs/non-humanoids/archvile/fire.ogg', 100, FALSE)
	var/turf/target_turf = get_ranged_target_turf(owner, owner.dir, beam_range)
	var/turf/origin_turf = get_turf(owner)
	var/list/affected_turfs = get_line(origin_turf, target_turf) - origin_turf
	for(var/turf/affected_turf in affected_turfs)
		if(affected_turf.opacity)
			break
		var/blocked = FALSE
		for(var/obj/potential_block in affected_turf)
			if(potential_block.opacity)
				blocked = TRUE
				break
		if(blocked)
			break
		var/obj/effect/temp_visual/telegraphing/line/archvile/fire_indicator = new /obj/effect/temp_visual/telegraphing/line/archvile(affected_turf)
		fire_indicator.dir = get_dir(owner, target)
	var/fully_charged = do_after(owner, delay = charge_duration, target = owner)
	if (!fully_charged)
		StartCooldown()
		return TRUE
	owner.face_atom(target)
	do_fire()
	if (istype(owner, /mob/living/basic/mining/archvile))
		var/mob/living/basic/mining/archvile/vile = owner
		vile.icon_state = "archvile"
		vile.update_appearance(UPDATE_OVERLAYS)
	StartCooldown()
	return TRUE

/// Create a laser in the direction we are facing
/datum/action/cooldown/mob_cooldown/archvile_fire/proc/do_fire()
	owner.visible_message(span_danger("[owner] lights the path on fire!"))
	var/turf/target_turf = get_ranged_target_turf(owner, owner.dir, beam_range)
	var/turf/origin_turf = get_turf(owner)
	var/list/affected_turfs = get_line(origin_turf, target_turf) - origin_turf
	for(var/turf/affected_turf in affected_turfs)
		if(affected_turf.opacity)
			break
		var/blocked = FALSE
		for(var/obj/potential_block in affected_turf)
			if(potential_block.opacity)
				blocked = TRUE
				break
		if(blocked)
			break
		playsound(owner, 'sound/effects/fire_puff.ogg', 100, FALSE)
		new /obj/effect/hotspot(affected_turf, 200, 2000)
		affected_turf.hotspot_expose(2000, 200, TRUE)
		for(var/mob/living/hit_mob in affected_turf)
			hit_mob.adjust_fire_stacks(20)
			hit_mob.ignite_mob()
		sleep(1.5 DECISECONDS)
	return TRUE
