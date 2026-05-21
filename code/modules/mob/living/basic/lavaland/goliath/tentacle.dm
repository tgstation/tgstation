/// A tentacle which grabs you if you don't get away from it
/obj/effect/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// Timer for our current action stage
	var/action_timer
	/// Time in which to grab people
	var/grapple_time = 10 SECONDS
	/// Lower bound of damage to inflict
	var/min_damage = 10
	/// Upper bound of damage to inflict
	var/max_damage = 15
	/// Type of legcuff we spawn
	var/trap_type = /obj/item/restraints/legcuffs/goliath_tentacle
	/// Mob who fired the tentacle
	var/mob/living/owner = null

/obj/effect/goliath_tentacle/Initialize(mapload, mob/living/goliath)
	. = ..()
	if (ismineralturf(loc))
		var/turf/closed/mineral/floor = loc
		floor.gets_drilled()
	if (!isopenturf(loc) || is_space_or_openspace(loc))
		return INITIALIZE_HINT_QDEL
	for (var/obj/effect/goliath_tentacle/tentacle in loc)
		if (tentacle != src)
			return INITIALIZE_HINT_QDEL
	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(animate_grab)), 0.7 SECONDS, TIMER_STOPPABLE)
	update_appearance(UPDATE_OVERLAYS)
	set_owner(goliath)

/obj/effect/goliath_tentacle/Destroy()
	deltimer(action_timer)
	return ..()

/obj/effect/goliath_tentacle/proc/set_owner(mob/living/goliath)
	if (owner)
		UnregisterSignal(owner, COMSIG_QDELETING)
	owner = goliath
	if (owner)
		RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(on_owner_del))

/obj/effect/goliath_tentacle/proc/on_owner_del(datum/source)
	SIGNAL_HANDLER
	owner = null
	retract()

/// Change to next icon state and set up grapple
/obj/effect/goliath_tentacle/proc/animate_grab()
	icon_state = "goliath_tentacle_wiggle"
	update_appearance(UPDATE_OVERLAYS)
	deltimer(action_timer)
	addtimer(CALLBACK(src, PROC_REF(grab)), 0.3 SECONDS, TIMER_STOPPABLE)

/// Grab everyone we share space with. If it's nobody, go home.
/obj/effect/goliath_tentacle/proc/grab()
	var/trapped_mobs = FALSE
	for (var/mob/living/victim in loc)
		if (victim.stat == DEAD || owner && victim.faction_check_atom(owner))
			continue
		if (HAS_TRAIT(victim, TRAIT_TENTACLE_IMMUNE) || SEND_SIGNAL(victim, COMSIG_GOLIATH_TENTACLED_GRABBED) & COMPONENT_GOLIATH_CANCEL_TENTACLE_GRAB)
			continue
		var/obj/item/restraints/legcuffs/goliath_tentacle/trap = new trap_type(loc, victim, src)
		if (QDELETED(trap))
			continue
		balloon_alert(victim, "grabbed")
		visible_message(span_danger("[src] grabs hold of [victim]!"))
		victim.apply_damage(rand(min_damage, max_damage), BRUTE, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG), wound_bonus = CANT_WOUND)
		trapped_mobs = TRUE

	for (var/obj/vehicle/sealed/mecha/mech in loc)
		mech.take_damage(rand(min_damage, max_damage), damage_type = BRUTE, damage_flag = MELEE, sound_effect = TRUE)

	// Already retracting
	if (icon_state == "goliath_tentacle_retract")
		return

	if (!trapped_mobs)
		retract()
		return

	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(retract)), grapple_time, TIMER_STOPPABLE)

/// Play exit animation.
/obj/effect/goliath_tentacle/proc/retract()
	if (icon_state == "goliath_tentacle_retract")
		return // Already retracting
	SEND_SIGNAL(src, COMSIG_GOLIATH_TENTACLE_RETRACTING)
	icon_state = "goliath_tentacle_retract"
	update_appearance(UPDATE_OVERLAYS)
	deltimer(action_timer)
	action_timer = QDEL_IN_STOPPABLE(src, 0.7 SECONDS)

/obj/effect/goliath_tentacle/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, effect_type = EMISSIVE_NO_BLOOM)
	. += emissive_appearance(icon, "[icon_state]_e_bloom", src)

/obj/effect/goliath_tentacle/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		retract()
		return TRUE

/// An alternative variant which drags the mob in towards the goliath
/obj/effect/goliath_tentacle/drag
	trap_type = /obj/item/restraints/legcuffs/goliath_tentacle/drag

/obj/item/restraints/legcuffs/goliath_tentacle
	name = "tentacle mass"
	desc = "A writhing tentacle constricting one of your limbs."
	icon_state = "goliath_tentacle"
	slowdown = 4
	breakouttime = 6 SECONDS
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	obj_flags = CONDUCTS_ELECTRICITY | CAN_BE_HIT
	item_flags = DROPDEL
	legcuff_state = "goliath_tentacle"
	uses_integrity = TRUE
	max_integrity = 75 // 3 PKC swings, 5 bayonet swings
	/// Tentacle we're attached to
	var/obj/effect/goliath_tentacle/tentacle
	/// Leash component linking the victim to the turf
	var/datum/component/leash/leash
	/// Beam between the victim and the tentacle tile
	var/datum/beam/beam_effect

/obj/item/restraints/legcuffs/goliath_tentacle/Initialize(mapload, mob/living/target, obj/effect/goliath_tentacle/tentacle)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORE_DEMOLITION, INNATE_TRAIT)
	src.tentacle = tentacle
	if (!target?.equip_to_slot_if_possible(src, ITEM_SLOT_LEGCUFFED, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		return INITIALIZE_HINT_QDEL

/obj/item/restraints/legcuffs/goliath_tentacle/Destroy(force)
	. = ..()
	if (tentacle)
		tentacle.retract()
		tentacle = null
	if (leash)
		UnregisterSignal(leash, COMSIG_QDELETING)
		QDEL_NULL(leash)
	QDEL_NULL(beam_effect)

/obj/item/restraints/legcuffs/goliath_tentacle/equipped(mob/living/user, slot, initial)
	. = ..()
	if (slot != ITEM_SLOT_LEGCUFFED || leash)
		return
	leash_target(user)

/obj/item/restraints/legcuffs/goliath_tentacle/proc/release(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/restraints/legcuffs/goliath_tentacle/proc/on_tentacle_left(datum/source)
	SIGNAL_HANDLER
	if (tentacle)
		UnregisterSignal(tentacle, list(COMSIG_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING))
		tentacle = null
	release()

/obj/item/restraints/legcuffs/goliath_tentacle/proc/leash_target(mob/living/user)
	leash = user.AddComponent(/datum/component/leash, owner = get_turf(user), distance = 1, silent = TRUE)
	beam_effect = user.Beam(get_turf(user), "goliath_tentacle", beam_type = /obj/effect/ebeam/goliath, emissive = FALSE)
	RegisterSignal(beam_effect.visuals, COMSIG_CLICK, PROC_REF(on_beam_click))
	RegisterSignals(user, list(SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), COMSIG_BRIMDUST_EXPLOSION), PROC_REF(release))
	RegisterSignals(tentacle, list(COMSIG_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING), PROC_REF(on_tentacle_left))
	RegisterSignal(leash, COMSIG_QDELETING, PROC_REF(release))

/obj/item/restraints/legcuffs/goliath_tentacle/proc/on_beam_click(atom/source, atom/location, control, params, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(process_beam_click), source, location, params, user)

/obj/item/restraints/legcuffs/goliath_tentacle/proc/process_beam_click(atom/source, atom/location, params, mob/user)
	if(world.time <= user.next_move)
		return

	var/obj/item/held_thing = user.get_active_held_item()
	if (!istype(held_thing))
		return

	var/turf/nearest_turf = null
	for (var/turf/line_turf in get_line(get_turf(src), get_turf(beam_effect.target)))
		if (line_turf.IsReachableBy(user))
			nearest_turf = line_turf
			break

	if (isnull(nearest_turf))
		return

	if (!user.can_perform_action(nearest_turf))
		nearest_turf.balloon_alert(user, "cannot reach!")
		return

	held_thing.melee_attack_chain(user, src, params2list(params))
	user.changeNext_move(held_thing.attack_speed)
	playsound(user, held_thing.hitsound || 'sound/effects/blob/attackblob.ogg', held_thing.get_clamped_volume(), TRUE, extrarange = held_thing.stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

/obj/item/restraints/legcuffs/goliath_tentacle/play_attack_sound(damage_amount, damage_type, damage_flag)
	return

/obj/item/restraints/legcuffs/goliath_tentacle/drag

/obj/item/restraints/legcuffs/goliath_tentacle/drag/Initialize(mapload, mob/living/target, obj/effect/goliath_tentacle/tentacle)
	. = ..()
	QDEL_IN(src, 15 SECONDS)
	if (. != INITIALIZE_HINT_QDEL)
		START_PROCESSING(SSprocessing, src)

/obj/item/restraints/legcuffs/goliath_tentacle/drag/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/item/restraints/legcuffs/goliath_tentacle/drag/process(seconds_per_tick)
	if (leash.distance <= 1)
		return PROCESS_KILL
	leash.set_distance(leash.distance - 1)

/obj/item/restraints/legcuffs/goliath_tentacle/drag/leash_target(mob/living/user)
	if (!tentacle?.owner)
		return ..()
	leash = user.AddComponent(/datum/component/leash, owner = tentacle.owner, distance = get_dist(user, tentacle.owner), silent = TRUE)
	beam_effect = user.Beam(tentacle.owner, "goliath_tentacle", beam_type = /obj/effect/ebeam/goliath, emissive = FALSE)
	RegisterSignal(beam_effect.visuals, COMSIG_CLICK, PROC_REF(on_beam_click))
	RegisterSignals(user, list(SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), COMSIG_BRIMDUST_EXPLOSION), PROC_REF(release))
	RegisterSignals(tentacle.owner, COMSIG_QDELETING, PROC_REF(on_tentacle_left))
	RegisterSignal(leash, COMSIG_QDELETING, PROC_REF(release))
	tentacle.retract()
	tentacle = null

/obj/effect/ebeam/goliath
	name = "goliath tentacle"
	mouse_opacity = MOUSE_OPACITY_ICON
