#define BB_LEAPER_VOLLEY "leaper_volley"
#define BB_LEAPER_FLOP "leaper_flop"
#define BB_LEAPER_BUBBLE "leaper_bubble"
#define BB_LEAPER_SUMMON "leaper_summon"
#define BB_KEY_SWIM_TIME "key_swim_time"
#define BB_SWIM_ALTERNATE_TURF "swim_alternate_turf"
#define BB_CURRENTLY_SWIMMING "currently_swimming"
#define BB_KEY_SWIMMER_COOLDOWN "key_swimmer_cooldown"
#define BB_KEY_SWIM_TIMER "key_swim_timer"
#define DEFAULT_TIME_SWIMMER 30 SECONDS


/mob/living/basic/leaper
	name = "leaper"
	desc = "Commonly referred to as 'leapers', the Geron Toad is a massive beast that spits out highly pressurized bubbles containing a unique toxin, knocking down its prey and then crushing it with its girth."
	icon = 'icons/mob/simple/jungle/leaper.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST

	melee_damage_lower = 15
	melee_damage_upper = 20
	maxHealth = 350
	health = 350
	speed = 10

	pixel_x = -16
	base_pixel_x = -16

	faction = list(FACTION_JUNGLE)
	obj_damage = 30

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY

	status_flags = NONE
	lighting_cutoff_red = 5
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 25
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/leaper
	///appearance when we dead
	var/mutable_appearance/dead_overlay
	///appearance when we are alive
	var/mutable_appearance/living_overlay

/datum/ai_controller/basic_controller/leaper
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/targeted_mob_ability/pointed_bubble,
		/datum/ai_planning_subtree/targeted_mob_ability/flop,
		/datum/ai_planning_subtree/targeted_mob_ability/volley,
		/datum/ai_planning_subtree/targeted_mob_ability/summon,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/go_for_swim,
	)

/datum/ai_planning_subtree/go_for_swim

/datum/ai_planning_subtree/go_for_swim/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_SWIM_ALTERNATE_TURF))
		controller.queue_behavior(/datum/ai_behavior/travel_towards/swimming, BB_SWIM_ALTERNATE_TURF)

	if(isnull(controller.blackboard[BB_KEY_SWIM_TIME]))
		controller.set_blackboard_key(BB_KEY_SWIM_TIME, DEFAULT_TIME_SWIMMER)

	var/mob/living/living_pawn = controller.pawn
	var/turf/our_turf = get_turf(living_pawn)

	///we have been taken out of water!
	controller.set_blackboard_key(BB_CURRENTLY_SWIMMING, iswaterturf(our_turf))

	if(controller.blackboard[BB_KEY_SWIM_TIME] >= world.time)
		controller.queue_behavior(/datum/ai_behavior/find_and_set/swim_alternate, BB_SWIM_ALTERNATE_TURF, /turf/open)
		return

	///have some fun in the water
	if(controller.blackboard[BB_CURRENTLY_SWIMMING])
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "splashes water all around!")
		return


/datum/ai_behavior/find_and_set/swim_alternate

/datum/ai_behavior/find_and_set/swim_alternate/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(living_pawn))
		return null
	var/turf/our_turf = get_turf(living_pawn)
	var/look_for_land = controller.blackboard[BB_CURRENTLY_SWIMMING]
	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(search_range, living_pawn))
		if(isclosedturf(possible_turf) || isspaceturf(possible_turf))
			continue
		if(possible_turf.is_blocked_turf())
			continue
		if(look_for_land)
			if(iswaterturf(our_turf))
				continue
		else if(!iswaterturf(our_turf))
			continue
		possible_turfs += possible_turfs

	if(!length(possible_turfs))
		return null

	return(pick(possible_turfs))

/datum/ai_behavior/travel_towards/swimming
	clear_target = TRUE

/datum/ai_behavior/travel_towards/swimming/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/time_to_add = controller.blackboard[BB_KEY_SWIMMER_COOLDOWN] ? controller.blackboard[BB_KEY_SWIMMER_COOLDOWN] : DEFAULT_TIME_SWIMMER
	controller.set_blackboard_key(BB_KEY_SWIM_TIME, world.time + time_to_add )

/datum/ai_planning_subtree/targeted_mob_ability/pointed_bubble
	ability_key = BB_LEAPER_BUBBLE
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/flop
	ability_key = BB_LEAPER_FLOP
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/flop/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(isclosedturf(current_target) || isspaceturf(current_target))
		return
	return ..()
/datum/ai_planning_subtree/targeted_mob_ability/volley
	ability_key = BB_LEAPER_VOLLEY
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/summon
	ability_key = BB_LEAPER_SUMMON
	finish_planning = FALSE


/mob/living/basic/leaper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/wall_smasher)
	AddElement(/datum/element/ridable, component_type = /datum/component/riding/creature/leaper)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)
	var/datum/action/cooldown/mob_cooldown/blood_rain/volley = new(src)
	volley.Grant(src)
	var/datum/action/cooldown/mob_cooldown/belly_flop/flop = new(src)
	flop.Grant(src)
	var/datum/action/cooldown/mob_cooldown/projectile_attack/leaper_bubble/bubble = new(src)
	bubble.Grant(src)
	var/datum/action/cooldown/spell/conjure/limit_summons/create_suicide_toads/toads = new(src)
	toads.Grant(src)

/mob/living/basic/leaper/proc/set_color_overlay(toad_color)
	dead_overlay = mutable_appearance(icon, "[icon_state]_dead_overlay")
	dead_overlay.color = toad_color

	living_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	living_overlay.color = toad_color
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/leaper/update_overlays()
	. = ..()
	if(stat == DEAD && dead_overlay)
		. += dead_overlay
		return

	if(living_overlay)
		. += living_overlay

/mob/living/basic/leaper/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, LEAPING_TRAIT)
	return ..()

/mob/living/basic/leaper/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LEAPING_TRAIT)
