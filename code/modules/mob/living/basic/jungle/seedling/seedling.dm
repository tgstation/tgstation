#define SEEDLING_STATE_NEUTRAL 0
#define SEEDLING_STATE_WARMUP 1
#define SEEDLING_STATE_ACTIVE 2

//A plant rooted in the ground that forfeits its melee attack in favor of ranged barrages.
//It will fire flurries of solar energy, and occasionally charge up a powerful blast that makes it vulnerable to attack.
/mob/living/basic/seedling
	name = "seedling"
	desc = "This oversized, predatory flower conceals what can only be described as an organic energy cannon."
	icon = 'icons/mob/simple/jungle/seedling.dmi'
	icon_state = "seedling"
	icon_living = "seedling"
	icon_dead = "seedling_dead"
	habitable_atmos = list("min_oxy" = 2, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 450
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	maxHealth = 100
	health = 100
	pixel_y = -14
	pixel_x = -14
	response_harm_continuous = "strikes"
	response_harm_simple = "strike"
	melee_damage_lower = 30
	melee_damage_upper = 30
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 25
	mob_size = MOB_SIZE_LARGE
	ai_controller = /datum/ai_controller/basic_controller/seedling
	///the state of combat we are in
	var/combatant_state = SEEDLING_STATE_NEUTRAL
	///the colors our petals can have
	var/list/possible_colors = list(COLOR_RED, COLOR_YELLOW, COLOR_OLIVE, COLOR_CYAN)
	///appearance when we are in our normal state
	var/mutable_appearance/petal_neutral
	///appearance when we are in our warmup state
	var/mutable_appearance/petal_warmup
	///appearance when we are in the firing state
	var/mutable_appearance/petal_active
	///appearance when we are dead
	var/mutable_appearance/petal_dead
	///the bucket we carry
	var/obj/item/reagent_containers/cup/held_can
	///commands we follow
	var/list/seedling_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
	)

/mob/living/basic/seedling/Initialize(mapload, mob/living/tamer)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/seed_attack = new(src)
	seed_attack.Grant(src)
	ai_controller.set_blackboard_key(BB_RAPIDSEEDS_ABILITY, seed_attack)
	var/datum/action/cooldown/mob_cooldown/solarbeam/beam_attack = new(src)
	beam_attack.Grant(src)
	ai_controller.set_blackboard_key(BB_SOLARBEAM_ABILITY, beam_attack)

	var/petal_color = pick(possible_colors)

	petal_neutral = mutable_appearance(icon, "[icon_state]_overlay")
	petal_neutral.color = petal_color

	petal_warmup = mutable_appearance(icon, "[icon_state]_charging_overlay")
	petal_warmup.color = petal_color

	petal_active = mutable_appearance(icon, "[icon_state]_fire_overlay")
	petal_active.color = petal_color

	petal_dead = mutable_appearance(icon, "[icon_state]_dead_overlay")
	petal_dead.color = petal_color

	AddElement(/datum/element/wall_smasher)
	AddComponent(/datum/component/obeys_commands, seedling_commands)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	RegisterSignal(src, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(drop_can))
	if(tamer)
		befriend(tamer)
	update_appearance()

/mob/living/basic/seedling/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/machinery/hydroponics))
		treat_hydro_tray(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(!held_can)
		return

	if(istype(target, /obj/structure/sink) || istype(target, /obj/structure/reagent_dispensers))
		INVOKE_ASYNC(held_can, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target)
		return COMPONENT_HOSTILE_NO_ATTACK


///seedlings can water trays, remove weeds, or remove dead plants
/mob/living/basic/seedling/proc/treat_hydro_tray(obj/machinery/hydroponics/hydro)

	if(hydro.plant_status == HYDROTRAY_PLANT_DEAD)
		balloon_alert(src, "dead plant removed")
		hydro.set_seed(null)

	if(hydro.weedlevel > 0)
		balloon_alert(src, "weeds uprooted")
		hydro.set_weedlevel(0)
		return

	var/list/can_reagents = held_can?.reagents.reagent_list

	if(!length(can_reagents))
		return

	if((locate(/datum/reagent/water) in can_reagents) && (hydro.waterlevel < hydro.maxwater))
		INVOKE_ASYNC(held_can, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, hydro)
		return

/mob/living/basic/seedling/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()

	if(!. || !proximity_flag || held_can)
		return

	if(!istype(attack_target, /obj/item/reagent_containers/cup/watering_can))
		return

	var/obj/item/can_target = attack_target
	can_target.forceMove(src)
	held_can = can_target
	update_appearance()

/mob/living/basic/seedling/proc/change_combatant_state(state)
	combatant_state = state
	update_appearance()

/mob/living/basic/seedling/update_overlays()
	. = ..()
	if(stat == DEAD)
		. += petal_dead
		return

	switch(combatant_state)
		if(SEEDLING_STATE_NEUTRAL)
			. += petal_neutral
			if(held_can)
				. +=  mutable_appearance(icon, "seedling_can_overlay")
		if(SEEDLING_STATE_WARMUP)
			. += petal_warmup
		if(SEEDLING_STATE_ACTIVE)
			. += petal_active

/mob/living/basic/seedling/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	switch(combatant_state)
		if(SEEDLING_STATE_NEUTRAL)
			icon_state = "seedling"
		if(SEEDLING_STATE_WARMUP)
			icon_state = "seedling_charging"
		if(SEEDLING_STATE_ACTIVE)
			icon_state = "seedling_fire"

/mob/living/basic/seedling/proc/drop_can(mob/living/user)
	SIGNAL_HANDLER

	if(isnull(held_can))
		return
	dropItemToGround(held_can)
	return COMSIG_KB_ACTIVATED

/mob/living/basic/seedling/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != held_can)
		return
	held_can = null
	update_appearance()

/mob/living/basic/seedling/death(gibbed)
	. = ..()
	if(isnull(held_can))
		return
	held_can.forceMove(drop_location())

/mob/living/basic/seedling/meanie
	maxHealth = 400
	health = 400
	faction = list(FACTION_JUNGLE)
	ai_controller = /datum/ai_controller/basic_controller/seedling/meanie
	seedling_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack,
		/datum/pet_command/point_targetting/use_ability/solarbeam,
		/datum/pet_command/point_targetting/use_ability/rapidseeds,
	)

///abilities
/obj/projectile/seedling
	name = "solar energy"
	icon_state = "seedling"
	damage = 10
	damage_type = BURN
	light_range = 2
	armor_flag = ENERGY
	light_color = LIGHT_COLOR_DIM_YELLOW
	speed = 1.6
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	nondirectional_sprite = TRUE

/obj/projectile/seedling/on_hit(atom/target)
	if(!isliving(target))
		return ..()

	var/mob/living/living_target = target
	if(FACTION_JUNGLE in living_target.faction)
		return

	return ..()

/obj/effect/temp_visual/solarbeam_killsat
	name = "beam of solar energy"
	icon_state = "solar_beam"
	icon = 'icons/effects/beam.dmi'
	plane = LIGHTING_PLANE
	layer = LIGHTING_PRIMARY_LAYER
	duration = 3 SECONDS
	alpha = 200
	randomdir = FALSE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling
	name = "Solar Energy"
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "seedling"
	desc = "Fire small beams of solar energy."
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/seedling
	default_projectile_spread = 10
	shot_count = 10
	shot_delay = 0.2 SECONDS
	melee_cooldown_time = 0 SECONDS
	///how long we must charge up before firing off
	var/charge_up_timer = 3 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/seedling/seed_owner = owner
	if(seed_owner.combatant_state != SEEDLING_STATE_NEUTRAL)
		if(feedback)
			seed_owner.balloon_alert(seed_owner, "charging!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/Activate(atom/target)
	var/mob/living/basic/seedling/seed_owner = owner
	seed_owner.change_combatant_state(state = SEEDLING_STATE_WARMUP)
	addtimer(CALLBACK(src, PROC_REF(attack_sequence), owner, target), charge_up_timer)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/attack_sequence(mob/living/firer, atom/target)
	var/mob/living/basic/seedling/seed_owner = owner
	seed_owner.change_combatant_state(state = SEEDLING_STATE_ACTIVE)
	. = ..()
	addtimer(CALLBACK(seed_owner, TYPE_PROC_REF(/mob/living/basic/seedling, change_combatant_state), SEEDLING_STATE_NEUTRAL), 2 SECONDS)

/datum/action/cooldown/mob_cooldown/solarbeam
	name = "Solar Beam"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "solar_beam"
	desc = "Concenrtate the power of the sun onto your target!"
	cooldown_time = 30 SECONDS
	var/beam_charge_up = 3 SECONDS

/datum/action/cooldown/mob_cooldown/solarbeam/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/seedling/seed_owner = owner
	if(seed_owner.combatant_state != SEEDLING_STATE_NEUTRAL)
		if(feedback)
			seed_owner.balloon_alert(seed_owner, "charging!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/solarbeam/Activate(atom/target)
	var/mob/living/basic/seedling/seed_owner = owner
	seed_owner.change_combatant_state(state = SEEDLING_STATE_WARMUP)

	var/turf/target_turf = get_turf(target)
	playsound(owner, 'sound/effects/seedling_chargeup.ogg', 100, FALSE)

	var/obj/effect/temp_visual/solarbeam_killsat/owner_beam = new(get_turf(owner))
	animate(owner_beam, transform = matrix().Scale(1, 32), alpha = 255, time = beam_charge_up)

	var/obj/effect/temp_visual/solarbeam_killsat/target_beam = new(target_turf)
	animate(target_beam, transform = matrix().Scale(2, 1), alpha = 255, time = beam_charge_up)

	addtimer(CALLBACK(src, PROC_REF(launch_beam), owner, target_turf), beam_charge_up)
	StartCooldown()
	return TRUE

///the solarbeam will damage people, otherwise it will heal plants
/datum/action/cooldown/mob_cooldown/solarbeam/proc/launch_beam(mob/living/basic/seedling/firer, turf/target)
	for(var/atom/target_atom as anything in target)

		if(istype(target, /obj/machinery/hydroponics))
			var/obj/machinery/hydroponics/hydro = target_atom
			hydro.adjust_plant_health(-10)
			new /obj/effect/temp_visual/heal(get_turf(hydro), COLOR_VIBRANT_LIME)

		if(!isliving(target_atom))
			continue

		var/mob/living/living_target = target_atom
		living_target.adjust_fire_stacks(0.2)
		living_target.ignite_mob()
		living_target.adjustFireLoss(30)

	playsound(target, 'sound/magic/lightningbolt.ogg', 50, TRUE)
	firer.change_combatant_state(state = SEEDLING_STATE_NEUTRAL)

#undef SEEDLING_STATE_NEUTRAL
#undef SEEDLING_STATE_WARMUP
#undef SEEDLING_STATE_ACTIVE
