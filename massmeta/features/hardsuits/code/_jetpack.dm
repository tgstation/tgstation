//////////////// JETPACK /////////////////////
/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	inhand_icon_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	var/datum/gas_mixture/tempair_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/active_user = null
	var/obj/item/clothing/suit/space/hardsuit/active_hardsuit = null

/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	tempair_contents = air_contents

/obj/item/tank/jetpack/suit/Destroy()
	if(on)
		turn_off()
	return ..()

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, span_warning("\The [src] must be connected to a hardsuit!"))
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank/internals))
		to_chat(user, span_warning("You need a tank in your suit storage!"))
		return
	return ..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return FALSE
	active_user = user
	tank = active_user.s_store
	air_contents = tank.return_air()
	. = ..()
	if(!.)
		active_user = null
		tank = null
		air_contents = null
		return
	active_hardsuit = loc
	RegisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED, PROC_REF(on_hardsuit_moved))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(active_user, COMSIG_QDELETING, PROC_REF(on_user_del))
	START_PROCESSING(SSobj, src)

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	if(active_hardsuit)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = null
	if(active_user)
		UnregisterSignal(user, COMSIG_QDELETING)
		active_user = null
	tank = null
	air_contents = tempair_contents
	return ..()

/obj/item/tank/jetpack/suit/process()
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(active_user)
		update_appearance()
		return
	excited = TRUE
	..()

/obj/item/tank/jetpack/suit/allow_thrust(num, use_fuel = TRUE)
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(active_user)
		return FALSE

	// We've got the gas, it's chill
	if(!use_fuel)
		return TRUE

	var/datum/gas_mixture/removed = remove_air(num)
	if(removed.total_moles() < 0.005)
		turn_off(active_user)
		return FALSE

	var/turf/T = get_turf(src)
	T.assume_air(removed)
	return TRUE

/// Called when the jetpack moves, presumably away from the hardsuit.
/obj/item/tank/jetpack/suit/proc/on_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit) && ishuman(loc.loc) && loc.loc == active_user)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = loc
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_hardsuit_moved))
		return
	turn_off(active_user)

/// Called when the hardsuit loc moves, presumably away from the human user.
/obj/item/tank/jetpack/suit/proc/on_hardsuit_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	turn_off(active_user)

/// Called when the human wearing the suit that contains this jetpack is deleted.
/obj/item/tank/jetpack/suit/proc/on_user_del(mob/living/carbon/human/source, force)
	SIGNAL_HANDLER
	turn_off(active_user)
