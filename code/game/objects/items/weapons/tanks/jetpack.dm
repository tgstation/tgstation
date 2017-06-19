/obj/item/weapon/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = "o2"
	var/on = FALSE
	var/stabilizers = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/weapon/tank/jetpack/New()
	..()
	if(gas_type)
		air_contents.assert_gas(gas_type)
		air_contents.gases[gas_type][MOLES] = (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)

	ion_trail = new
	ion_trail.set_up(src)

/obj/item/weapon/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			stabilizers = !stabilizers
			to_chat(user, "<span class='notice'>You turn the jetpack stabilization [stabilizers ? "on" : "off"].</span>")
	else
		toggle_internals(user)


/obj/item/weapon/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		turn_on()
		to_chat(user, "<span class='notice'>You turn the jetpack on.</span>")
	else
		turn_off()
		to_chat(user, "<span class='notice'>You turn the jetpack off.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/weapon/tank/jetpack/proc/turn_on()
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	ion_trail.start()

/obj/item/weapon/tank/jetpack/proc/turn_off()
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	ion_trail.stop()

/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/living/user)
	if(!on)
		return
	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off()
		return

	var/datum/gas_mixture/removed = air_contents.remove(num)
	if(removed.total_moles() < 0.005)
		turn_off()
		return

	var/turf/T = get_turf(user)
	T.assume_air(removed)

	return 1

/obj/item/weapon/tank/jetpack/suicide_act(mob/user)
	if (istype(user,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.forcesay("WHAT THE FUCK IS CARBON DIOXIDE?")
		H.visible_message("<span class='suicide'>[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!</span>")
		return (OXYLOSS)
	else
		..()

/obj/item/weapon/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/weapon/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/weapon/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/weapon/tank/jetpack/oxygen/captain
	name = "\improper Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.

/obj/item/weapon/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = "co2"


/obj/item/weapon/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	origin_tech = "materials=4;magnets=4;engineering=5"
	icon_state = "jetpack-mining"
	item_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/weapon/tank/internals/tank = null

/obj/item/weapon/tank/jetpack/suit/New()
	..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/weapon/tank/jetpack/suit/attack_self()
	return

/obj/item/weapon/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, "<span class='warning'>\The [src] must be connected to a hardsuit!</span>")
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/weapon/tank/internals))
		to_chat(user, "<span class='warning'>You need a tank in your suit storage!</span>")
		return
	..()

/obj/item/weapon/tank/jetpack/suit/turn_on()
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		return
	var/mob/living/carbon/human/H = loc.loc
	tank = H.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/tank/jetpack/suit/turn_off()
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/tank/jetpack/suit/process()
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		turn_off()
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off()
		return
	..()


//Return a jetpack that the mob can use
//Back worn jetpacks, hardsuit internal packs, and so on.
//Used in Process_Spacemove() and wherever you want to check for/get a jetpack	

/mob/proc/get_jetpack()
	return

/mob/living/carbon/get_jetpack()
	var/obj/item/weapon/tank/jetpack/J = back
	if(istype(J))
		return J

/mob/living/carbon/human/get_jetpack()
	var/obj/item/weapon/tank/jetpack/J = ..()
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	return J

/mob/has_gravity(turf/T)
	var/obj/item/weapon/tank/jetpack/J = get_jetpack()
	if(J && J.on)
		return FALSE
	return ..()