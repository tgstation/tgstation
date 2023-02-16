/mob/living/basic/creature
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 50
	maxHealth = 50
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 30
	speed = 2
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	faction = list("nether")
	speak_emote = list("screams")
	death_message = "gets his head split open."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	ai_controller = /datum/ai_controller/basic_controller/creature
	/// Used for checking if the mob is phased or not.
	var/is_phased = FALSE
	/// Used for mobs that get spawned in a spawner appearently.
	var/datum/component/spawner/nest

/mob/living/basic/creature/Initialize(mapload)
	. = ..()
	var/datum/callback/health_changes_callback = CALLBACK(src, PROC_REF(health_check))
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_NETHER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 0)
	AddComponent(/datum/component/damage_buffs, health_changes_callback)
	var/datum/action/innate/creature/teleport/teleport = new(src)
	teleport.Grant(src)

/mob/living/basic/creature/proc/health_check(mob/living/attacker)
	if(health < maxHealth * 0.25)
		health_low_behaviour()
	else if (health < maxHealth * 0.5)
		health_medium_behaviour()
	else if (health < maxHealth * 0.75)
		health_high_behaviour()
	else
		health_full_behaviour()

/mob/living/basic/creature/proc/health_full_behaviour()
	melee_damage_lower = 20
	melee_damage_upper = 30
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/netherworld_enrage, multiplicative_slowdown = 0)

/mob/living/basic/creature/proc/health_high_behaviour()
	melee_damage_lower = 25
	melee_damage_upper = 40
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/netherworld_enrage, multiplicative_slowdown = -0.5)

/mob/living/basic/creature/proc/health_medium_behaviour()
	melee_damage_lower = 30
	melee_damage_upper = 50
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/netherworld_enrage, multiplicative_slowdown = -1)

/mob/living/basic/creature/proc/health_low_behaviour()
	melee_damage_lower = 35
	melee_damage_upper = 60
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/netherworld_enrage, multiplicative_slowdown = -1.5)

/mob/living/basic/creature/proc/can_be_seen(turf/location)
	// Check for darkness
	if(location?.lighting_object)
		if(location.get_lumcount() < 0.1) // No one can see us in the darkness, right?
			return null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(location)
		check_list += location

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/mob_target in oview(src, 7)) // They probably cannot see us if we cannot see them... can they?
			if(mob_target.client && !mob_target.is_blind() && !mob_target.has_unlimited_silicon_privilege)
				return mob_target
		for(var/obj/vehicle/sealed/mecha/mecha_mob_target in oview(src, 7))
			for(var/mob/mechamob_target as anything in mecha_mob_target.occupants)
				if(mechamob_target.client && !mechamob_target.is_blind())
					return mechamob_target
	return null

/datum/action/innate/creature
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"

/datum/action/innate/creature/teleport
	name = "Teleport"
	desc = "Teleport to wherever you want, as long as you aren't seen."

/datum/action/innate/creature/teleport/Activate()
	var/mob/living/basic/creature/owner_mob = owner
	var/obj/effect/dummy/phased_mob/holder = null
	if(owner_mob.stat == DEAD)
		return
	var/turf/owner_turf = get_turf(owner_mob)
	if (owner_mob.can_be_seen(owner_turf) || !do_after(owner_mob, 60, target = owner_turf))
		to_chat(owner_mob, span_warning("You can't phase in or out while being observed and you must stay still!"))
		return
	if (get_dist(owner_mob, owner_turf) != 0 || owner_mob.can_be_seen(owner_turf))
		to_chat(owner_mob, span_warning("Action cancelled, as you moved while reappearing or someone is now viewing your location."))
		return
	if(owner_mob.is_phased)
		holder = owner_mob.loc
		holder.eject_jaunter()
		holder = null
		owner_mob.is_phased = FALSE
		playsound(get_turf(owner_mob), 'sound/effects/podwoosh.ogg', 50, TRUE, -1)
	else
		playsound(get_turf(owner_mob), 'sound/effects/podwoosh.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(owner_turf, owner_mob)
		owner_mob.is_phased = TRUE

/mob/living/basic/creature/Destroy()
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	return ..()

/datum/ai_controller/basic_controller/creature
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/average_speed,
	)
