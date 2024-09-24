#define SEEDLING_STATE_NEUTRAL 0
#define SEEDLING_STATE_WARMUP 1
#define SEEDLING_STATE_ACTIVE 2

/**
 * A mobile plant with a rapid ranged attack.
 * It can pick up watering cans and look after plants.
 */
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
	base_pixel_y = -14
	pixel_x = -14
	base_pixel_x = -14
	response_harm_continuous = "strikes"
	response_harm_simple = "strike"
	melee_damage_lower = 30
	melee_damage_upper = 30
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 25
	mob_size = MOB_SIZE_LARGE
	faction = list(FACTION_PLANTS)
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	ai_controller = /datum/ai_controller/basic_controller/seedling
	///the state of combat we are in
	var/combatant_state = SEEDLING_STATE_NEUTRAL
	///the colors our petals can have
	var/static/list/possible_colors = list(COLOR_RED, COLOR_YELLOW, COLOR_OLIVE, COLOR_CYAN)
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

/mob/living/basic/seedling/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling = BB_RAPIDSEEDS_ABILITY,
		/datum/action/cooldown/mob_cooldown/solarbeam = BB_SOLARBEAM_ABILITY,
	)

	grant_actions_by_list(innate_actions)

	var/petal_color = pick(possible_colors)

	petal_neutral = mutable_appearance(icon, "[icon_state]_overlay")
	petal_neutral.color = petal_color

	petal_warmup = mutable_appearance(icon, "[icon_state]_charging_overlay")
	petal_warmup.color = petal_color

	petal_active = mutable_appearance(icon, "[icon_state]_fire_overlay")
	petal_active.color = petal_color

	petal_dead = mutable_appearance(icon, "[icon_state]_dead_overlay")
	petal_dead.color = petal_color

	AddElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	AddComponent(/datum/component/obeys_commands, seedling_commands)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	RegisterSignal(src, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(drop_can))
	update_appearance()

/mob/living/basic/seedling/proc/pre_attack(mob/living/puncher, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/machinery/hydroponics))
		treat_hydro_tray(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(isnull(held_can))
		return

	if(istype(target, /obj/structure/sink) || istype(target, /obj/structure/reagent_dispensers))
		INVOKE_ASYNC(held_can, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target)
		return COMPONENT_HOSTILE_NO_ATTACK


///seedlings can water trays, remove weeds, or remove dead plants
/mob/living/basic/seedling/proc/treat_hydro_tray(obj/machinery/hydroponics/hydro)

	if(hydro.plant_status == HYDROTRAY_PLANT_DEAD)
		balloon_alert(src, "dead plant removed")
		hydro.set_seed(null)
		return

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

/mob/living/basic/seedling/proc/change_combatant_state(state)
	combatant_state = state
	update_appearance()

/mob/living/basic/seedling/attackby(obj/item/can, mob/living/carbon/human/user, list/modifiers)
	if(istype(can, /obj/item/reagent_containers/cup/watering_can) && isnull(held_can))
		can.forceMove(src)
		return

	return ..()

/mob/living/basic/seedling/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /obj/item/reagent_containers/cup/watering_can))
		held_can = arrived
		update_appearance()

	return ..()

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

/mob/living/basic/seedling/Destroy()
	QDEL_NULL(held_can)
	return ..()

/mob/living/basic/seedling/meanie
	maxHealth = 400
	health = 400
	faction = list(FACTION_JUNGLE, FACTION_PLANTS)
	ai_controller = /datum/ai_controller/basic_controller/seedling/meanie
	seedling_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/point_targeting/use_ability/solarbeam,
		/datum/pet_command/point_targeting/use_ability/rapidseeds,
	)

//abilities
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
	shared_cooldown = NONE
	///how long we must charge up before firing off
	var/charge_up_timer = 3 SECONDS
	///is the owner of this ability a seedling?
	var/is_seedling = FALSE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	is_seedling = istype(owner, /mob/living/basic/seedling)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!is_seedling)
		return TRUE
	var/mob/living/basic/seedling/seed_owner = owner
	if(seed_owner.combatant_state != SEEDLING_STATE_NEUTRAL)
		if(feedback)
			seed_owner.balloon_alert(seed_owner, "charging!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/Activate(atom/target)
	if(is_seedling)
		var/mob/living/basic/seedling/seed_owner = owner
		seed_owner.change_combatant_state(state = SEEDLING_STATE_WARMUP)
	addtimer(CALLBACK(src, PROC_REF(attack_sequence), owner, target), charge_up_timer)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/seedling/attack_sequence(mob/living/firer, atom/target)
	if(is_seedling)
		var/mob/living/basic/seedling/seed_owner = owner
		seed_owner.change_combatant_state(state = SEEDLING_STATE_ACTIVE)
		addtimer(CALLBACK(seed_owner, TYPE_PROC_REF(/mob/living/basic/seedling, change_combatant_state), SEEDLING_STATE_NEUTRAL), 4 SECONDS)

	return ..()


/datum/action/cooldown/mob_cooldown/solarbeam
	name = "Solar Beam"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "solar_beam"
	desc = "Concentrate the power of the sun onto your target!"
	cooldown_time = 30 SECONDS
	shared_cooldown = NONE
	///how long will it take for us to charge up the beam
	var/beam_charge_up = 3 SECONDS
	///is the owner of this ability a seedling?
	var/is_seedling = FALSE

/datum/action/cooldown/mob_cooldown/solarbeam/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	is_seedling = istype(owner, /mob/living/basic/seedling)

/datum/action/cooldown/mob_cooldown/solarbeam/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!is_seedling)
		return TRUE
	var/mob/living/basic/seedling/seed_owner = owner
	if(seed_owner.combatant_state != SEEDLING_STATE_NEUTRAL)
		if(feedback)
			seed_owner.balloon_alert(seed_owner, "charging!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/solarbeam/Activate(atom/target)
	if(is_seedling)
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
/datum/action/cooldown/mob_cooldown/solarbeam/proc/launch_beam(mob/living/firer, turf/target_turf)
	for(var/atom/target_atom as anything in target_turf)

		if(istype(target_atom, /obj/machinery/hydroponics))
			var/obj/machinery/hydroponics/hydro = target_atom
			hydro.adjust_plant_health(10)
			new /obj/effect/temp_visual/heal(target_turf, COLOR_HEALING_CYAN)

		if(!isliving(target_atom))
			continue

		var/mob/living/living_target = target_atom
		living_target.adjust_fire_stacks(0.2)
		living_target.ignite_mob()
		living_target.adjustFireLoss(30)

	playsound(target_turf, 'sound/effects/magic/lightningbolt.ogg', 50, TRUE)
	if(!is_seedling)
		return
	var/mob/living/basic/seedling/seed_firer = firer
	seed_firer.change_combatant_state(state = SEEDLING_STATE_NEUTRAL)

#undef SEEDLING_STATE_NEUTRAL
#undef SEEDLING_STATE_WARMUP
#undef SEEDLING_STATE_ACTIVE
