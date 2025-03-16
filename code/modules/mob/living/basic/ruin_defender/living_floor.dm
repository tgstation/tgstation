/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/on_top/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || QDELETED(target))
		return
	if(target.loc != controller.pawn.loc)
		return
	return ..()

/datum/ai_controller/basic_controller/living_floor
	max_target_distance = 2
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/on_top
	)

/mob/living/basic/living_floor
	name = "floor"
	desc = "The floor you walk on. It looks near-impervious to damage."
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	icon_living = "floor"
	mob_size = MOB_SIZE_HUGE
	mob_biotypes = MOB_SPECIAL
	status_flags = NONE
	death_message = ""
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	basic_mob_flags = DEL_ON_DEATH
	move_resist = INFINITY
	density = FALSE
	combat_mode = TRUE
	layer = LOW_FLOOR_LAYER
	plane = FLOOR_PLANE
	faction = list(FACTION_HOSTILE)
	melee_damage_lower = 20
	melee_damage_upper = 40 //pranked.....
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	ai_controller = /datum/ai_controller/basic_controller/living_floor
	melee_attack_cooldown = 0.5 SECONDS // get real

	var/icon_aggro = "floor-hostile"
	var/desc_aggro = "This flooring is alive and filled with teeth, better not step on that. Being covered in plating, it is immune to damage. Seems vulnerable to prying though."

/mob/living/basic/living_floor/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED), INNATE_TRAIT) //nothing but crowbars may kill us
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(look_aggro), COMSIG_ATOM_EXITED = PROC_REF(look_deaggro))
	AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = 1, works_in_containers = FALSE)

/mob/living/basic/living_floor/proc/look_aggro(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || istype(victim, /mob/living/basic/living_floor) || victim.stat == DEAD)
		return
	if(victim.loc == loc) //guaranteed bite
		var/datum/targeting_strategy/basic/targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY])
		if(targeting.can_attack(src, victim))
			melee_attack(victim)
	icon_state = icon_aggro
	desc = desc_aggro

/mob/living/basic/living_floor/proc/look_deaggro(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) && !istype(victim, /mob/living/basic/living_floor))
		return
	icon_state = initial(icon_state)
	desc = initial(desc_aggro)

/mob/living/basic/living_floor/med_hud_set_health()
	return

/mob/living/basic/living_floor/med_hud_set_status()
	return

/mob/living/basic/living_floor/attackby(obj/item/weapon, mob/user, list/modifiers)
	if(weapon.tool_behaviour != TOOL_CROWBAR)
		return ..()
	balloon_alert(user, "prying...")
	playsound(src, 'sound/items/tools/crowbar.ogg', 45, TRUE)
	if(!do_after(user, 5 SECONDS, src))
		return
	new /obj/effect/gibspawner/generic(loc)
	qdel(src)

/mob/living/basic/living_floor/white
	icon_state = "white"
	icon_living = "white"
	icon_aggro = "whitefloor-hostile"
