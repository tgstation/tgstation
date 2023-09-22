#define BB_LIST_SCARY_ITEMS "list_scary_items"

/mob/living/basic/mining/ice_demon
	name = "demonic watcher"
	desc = "A creature formed entirely out of ice, bluespace energy emanates from inside of it."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_demon"
	icon_living = "ice_demon"
	icon_dead = "ice_demon_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	speed = 2
	maxHealth = 150
	health = 150
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	ai_controller = /datum/ai_controller/basic_controller/ice_demon
	death_message = "fades as the energies that tied it to this world dissipate."
	death_sound = 'sound/magic/demon_dies.ogg'

/datum/ai_controller/basic_controller/ice_demon
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_LIST_SCARY_ITEMS = list(
			/obj/item/weldingtool,
			/obj/item/flashlight/flare,
		),
		BB_BASIC_MOB_FLEEING = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target/ice_demon,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/ice_demon,
		/datum/ai_planning_subtree/random_speech/tree,
	)


/datum/ai_planning_subtree/basic_ranged_attack_subtree/ice_demon
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/ice_demon

/datum/ai_behavior/basic_ranged_attack/ice_demon
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION


/datum/ai_planning_subtree/flee_target/ice_demon

/datum/ai_planning_subtree/flee_target/ice_demon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return

	if(!iscarbon(target))
		return ..()

	var/mob/living/carbon/human_target = target

	for(var/obj/held_item in human_target.held_items)
		if(!is_type_in_list(held_item, controller.blackboard[BB_LIST_SCARY_ITEMS]))
			continue
		if(!held_item.light_on)
			continue
		return ..()


/mob/living/basic/mining/ice_demon/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/slippery_ice_floors/ice_floor = new(src)
	ice_floor.Grant(src)
	var/datum/action/cooldown/mob_cooldown/ice_demon_teleport/demon_teleport = new(src)
	demon_teleport.Grant(src)
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/temp/ice_demon,\
		projectile_sound = 'sound/weapons/pierce.ogg',\
	)
	var/static/list/death_loot = list(/obj/item/stack/ore/bluespace_crystal = 3)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/simple_flying)


/obj/projectile/temp/ice_demon
	name = "ice blast"
	icon_state = "ice_2"
	damage = 5
	damage_type = BURN
	armor_flag = ENERGY
	speed = 1
	pixel_speed_multiplier = 0.25
	range = 200
	temperature = -75

/mob/living/basic/mining/ice_demon/death(gibbed)
	if(prob(5))
		new /obj/item/raw_anomaly_core/bluespace(loc)
	return ..()

/datum/action/cooldown/mob_cooldown/ice_demon_teleport
	name = "Bluespace Teleport"
	desc = "Teleport towards a destination target!"
	button_icon = 'icons/obj/ore.dmi'
	button_icon_state = "bluespace_crystal"
	cooldown_time = 7 SECONDS
	melee_cooldown_time = 0 SECONDS
	///the range of fire
	var/teleport_range = 5

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/Activate(atom/target_atom)
	if(isclosedturf(get_turf(target_atom)))
		owner.balloon_alert(owner, "blocked!")
		return FALSE
	if(get_dist(target_atom, owner) > teleport_range)
		owner.balloon_alert(owner, "too far!")
		return FALSE
	animate(owner, transform = matrix().Scale(0.5), time = 2 SECONDS, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(teleport_to_turf), target_atom), 2 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/proc/teleport_to_turf(atom/target)
	animate(owner, transform = matrix(), time = 0.5 SECONDS, easing = SINE_EASING)
	do_teleport(teleatom = owner, destination = target, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/datum/action/cooldown/mob_cooldown/slippery_ice_floors
	name = "Iced Floors"
	desc = "Summon slippery ice floors all around!"
	button_icon = 'icons/obj/ore.dmi'
	button_icon_state = "bluespace_crystal"
	cooldown_time = 20 SECONDS
	melee_cooldown_time = 0 SECONDS
	///perimeter we will spawn the iced floors on
	var/radius = 1
	///intervals we will spawn the ice floors in
	var/spread_duration = 0.2 SECONDS

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/Activate(atom/target_atom)
	for(var/i in 0 to radius)
		var/list/list_of_turfs = border_diamond_range_turfs(owner, i)
		addtimer(CALLBACK(src, PROC_REF(spawn_icy_floors), list_of_turfs), i * spread_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/proc/spawn_icy_floors(list/list_of_turfs)
	if(!length(list_of_turfs))
		return
	for(var/turf/location in list_of_turfs)
		if(isnull(location))
			continue
		if(isclosedturf(location) || isspaceturf(location))
			continue
		new /obj/effect/temp_visual/slippery_ice(location)

/obj/effect/temp_visual/slippery_ice
	name = "slippery acid"
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-6"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	duration = 3 SECONDS
	alpha = 100
	/// how long does it take for the effect to phase in
	var/phase_in_period = 2 SECONDS

/obj/effect/temp_visual/slippery_ice/Initialize(mapload)
	. = ..()
	animate(src, alpha = 160, time = phase_in_period)
	animate(alpha = 0, time = 1 SECONDS) /// slowly fade out of existence
	addtimer(CALLBACK(src, PROC_REF(add_slippery_component), phase_in_period)) //only become slippery after we phased in

/obj/effect/temp_visual/slippery_ice/proc/add_slippery_component()
	AddComponent(/datum/component/slippery, 2 SECONDS)
