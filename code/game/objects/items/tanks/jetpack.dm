/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	/// What gas our jetpack is filled with on initialize
	var/gas_type = /datum/gas/oxygen
	/// If the jetpack is currently active
	var/on = FALSE
	/// If the jetpack will stop when you stop moving
	var/stabilize = FALSE
	/// If our jetpack is disabled, from getting EMPd
	var/disabled = FALSE
	/// Callback for the jetpack component
	var/thrust_callback

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_SUITSTORE)
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	configure_jetpack(stabilize)

/obj/item/tank/jetpack/Destroy()
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilize - Should this jetpack be stabalized
 */
/obj/item/tank/jetpack/proc/configure_jetpack(stabilize)
	src.stabilize = stabilize

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_JETPACK_ACTIVATED, \
		COMSIG_JETPACK_DEACTIVATED, \
		JETPACK_ACTIVATION_FAILED, \
		thrust_callback, \
		/datum/effect_system/trail_follow/ion \
	)

/obj/item/tank/jetpack/item_action_slot_check(slot)
	if(slot & slot_flags)
		return TRUE

/obj/item/tank/jetpack/equipped(mob/user, slot, initial)
	. = ..()
	if(on && !(slot & slot_flags))
		turn_off(user)

/obj/item/tank/jetpack/dropped(mob/user, silent)
	. = ..()
	if(on)
		turn_off(user)

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		var/datum/gas_mixture/our_mix = return_air()
		our_mix.assert_gas(gas_type)
		our_mix.gases[gas_type][MOLES] = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			configure_jetpack(!stabilize)
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilize ? "on" : "off"]."))
	else
		toggle_internals(user)

/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		if(turn_on(user))
			to_chat(user, span_notice("You turn the jetpack on."))
		else
			to_chat(user, span_notice("You fail to turn the jetpack on."))
			return
	else
		turn_off(user)
		to_chat(user, span_notice("You turn the jetpack off."))

	update_item_action_buttons()

/obj/item/tank/jetpack/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][on ? "-on" : ""]"

/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(disabled)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_JETPACK_ACTIVATED, user) & JETPACK_ACTIVATION_FAILED)
		return FALSE
	on = TRUE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	SEND_SIGNAL(src, COMSIG_JETPACK_DEACTIVATED, user)
	on = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/tank/jetpack/proc/allow_thrust(num, use_fuel = TRUE)
	if(!ismob(loc))
		return FALSE
	var/mob/user = loc

	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return FALSE

	// We've got the gas, it's chill
	if(!use_fuel)
		return TRUE

	var/datum/gas_mixture/removed = remove_air(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return FALSE

	var/turf/T = get_turf(src)
	T.assume_air(removed)
	return TRUE

/obj/item/tank/jetpack/suicide_act(mob/living/user)
	if (!ishuman(user))
		return
	var/mob/living/carbon/human/suffocater = user
	suffocater.say("WHAT THE FUCK IS CARBON DIOXIDE?")
	suffocater.visible_message(span_suicide("[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!"))
	return OXYLOSS

/obj/item/tank/jetpack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(ismob(loc) && (item_flags & IN_INVENTORY))
		var/mob/wearer = loc
		turn_off(wearer)
	else
		turn_off()
	update_item_action_buttons()
	disabled = TRUE
	addtimer(CALLBACK(src, PROC_REF(remove_emp)), 4 SECONDS)

///Removes the disabled flag after getting EMPd
/obj/item/tank/jetpack/proc/remove_emp()
	disabled = FALSE

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	inhand_icon_state = "jetpack-improvised"
	worn_icon = null
	worn_icon_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty

/obj/item/tank/jetpack/improvised/allow_thrust(num)
	if(!ismob(loc))
		return FALSE

	var/mob/user = loc
	if(rand(0,250) == 0)
		to_chat(user, span_notice("You feel your jetpack's engines cut out."))
		turn_off(user)
		return
	return ..()

/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	inhand_icon_state = "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	inhand_icon_state = "jetpack-black"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	inhand_icon_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	inhand_icon_state = "jetpack-sec"



/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	inhand_icon_state = "jetpack-black"
	distribute_pressure = 0
	gas_type = /datum/gas/carbon_dioxide
