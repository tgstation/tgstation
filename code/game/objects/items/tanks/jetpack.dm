/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	atom_size = ITEM_SIZE_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = /datum/gas/oxygen
	var/on = FALSE
	var/stabilizers = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	ion_trail = new
	ion_trail.auto_process = FALSE
	ion_trail.set_up(src)

/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/tank/jetpack/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/tank/jetpack/equipped(mob/user, slot, initial)
	. = ..()
	if(on && slot != ITEM_SLOT_BACK)
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
			stabilizers = !stabilizers
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilizers ? "on" : "off"]."))
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
	update_action_buttons()


/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(!allow_thrust(0.01, user))
		return FALSE
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	ion_trail.start()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/move_react)
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, .proc/pre_move_react)
	RegisterSignal(user, COMSIG_MOVABLE_SPACEMOVE, .proc/spacemove_react)
	if(full_speed)
		user.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)
	return TRUE


/obj/item/tank/jetpack/proc/turn_off(mob/user)
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	ion_trail.stop()
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)
		UnregisterSignal(user, COMSIG_MOVABLE_SPACEMOVE)
		user.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/tank/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER
	if(!on)//If jet dont work, it dont work
		return
	if(!user || !user.client)//Don't allow jet self using
		return
	if(!isturf(user.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(user.movement_type & FLOATING) || user.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(user.pulledby)//You don't must use jet if someone pull you
		return
	if(user.throwing)//You don't must use jet if you thrown
		return
	if(length(user.client.keys_held & user.client.movement_keys))//You use jet when press keys. yes.
		allow_thrust(0.01, user)

/obj/item/tank/jetpack/proc/pre_move_react(mob/user)
	SIGNAL_HANDLER
	ion_trail.oldposition = get_turf(src)

/obj/item/tank/jetpack/proc/spacemove_react(mob/user, movement_dir)
	SIGNAL_HANDLER

	if(on && (movement_dir || stabilizers))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user)
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return

	var/datum/gas_mixture/removed = remove_air(num)
	if(removed.total_moles() < 0.005)
		turn_off(user)
		return

	var/turf/T = get_turf(user)
	T.assume_air(removed)
	ion_trail.generate_effect()

	return TRUE

/obj/item/tank/jetpack/suicide_act(mob/user)
	if (istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say("WHAT THE FUCK IS CARBON DIOXIDE?")
		H.visible_message(span_suicide("[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!"))
		return (OXYLOSS)
	else
		..()

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	inhand_icon_state = "jetpack-improvised"
	worn_icon = null
	worn_icon_state = "jetpack-improvised"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE //moves at modsuit jetpack speeds

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user)
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
	inhand_icon_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	atom_size = ITEM_SIZE_NORMAL

/obj/item/tank/jetpack/oxygen/captain
	name = "captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	inhand_icon_state = "jetpack-captain"
	atom_size = ITEM_SIZE_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

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
