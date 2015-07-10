/obj/item/weapon/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = 4.0
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	action_button_name = "Toggle Jetpack"
	var/datum/effect/effect/system/ion_trail_follow/ion_trail
	var/on = 0.0
	var/stabilization_on = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer

/obj/item/weapon/tank/jetpack/New()
	..()
	ion_trail = new /datum/effect/effect/system/ion_trail_follow()
	ion_trail.set_up(src)


/obj/item/weapon/tank/jetpack/verb/toggle_rockets()
	set name = "Toggle Jetpack Stabilization"
	set category = "Object"
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	src.stabilization_on = !( src.stabilization_on )
	usr << "<span class='notice'>You toggle the stabilization [stabilization_on? "on":"off"].</span>"
	return


/obj/item/weapon/tank/jetpack/verb/toggle()
	set name = "Toggle Jetpack"
	set category = "Object"
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	on = !on
	if(on)
		icon_state = "[icon_state]-on"
	//	item_state = "[item_state]-on"
		ion_trail.start()
	else
		icon_state = initial(icon_state)
	//	item_state = initial(item_state)
		ion_trail.stop()
	usr << "<span class='notice'>You toggle the jetpack [on? "on":"off"].</span>"
	return


/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/living/user as mob)
	if(!(src.on))
		return 0
	if((num < 0.005 || src.air_contents.total_moles() < num))
		src.ion_trail.stop()
		return 0

	var/datum/gas_mixture/G = src.air_contents.remove(num)

	var/allgases = G.carbon_dioxide + G.nitrogen + G.oxygen + G.toxins	//fuck trace gases	-Pete
	if(allgases >= 0.005)
		return 1

	qdel(G)
	return

/obj/item/weapon/tank/jetpack/ui_action_click()
	toggle()


/obj/item/weapon/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/weapon/tank/jetpack/void/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/obj/item/weapon/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/weapon/tank/jetpack/oxygen/New()
	..()
	air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)

/obj/item/weapon/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = 3

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"

/obj/item/weapon/tank/jetpack/carbondioxide/New()
	..()
	ion_trail = new /datum/effect/effect/system/ion_trail_follow()
	ion_trail.set_up(src)
	air_contents.carbon_dioxide = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C)


/obj/item/weapon/tank/jetpack/suit
	name = "suit inbuilt jetpack"
	desc = "A device that will use your internals tank as a gas source for propulsion."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"
	var/obj/item/weapon/tank/internals/tank = null
	action_button_name = "Toggle Jetpack"
	action_button_internal = 1

/obj/item/weapon/tank/jetpack/suit/New()
	..()
	SSobj.processing -= src
	air_contents = null

/obj/item/weapon/tank/jetpack/suit/toggle()
	set name = "Toggle Jetpack"
	set category = "Object"

	if(istype(loc.loc,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc.loc

		if(!H.wear_suit)
			H << "<span class='warning'>You must be wearing the suit to use the inbuilt jetpack!</span>"
			return
		if(!istype(H.s_store,/obj/item/weapon/tank/internals))
			H << "<span class='warning'>You must have a tank in your suit's storage to use the inbuilt jetpack!</span>"
			return
		if(usr.stat || !usr.canmove || usr.restrained())
			return

		on = !on
		if(on)
			ion_trail.start()
			tank = H.s_store
			air_contents = tank.air_contents
			SSobj.processing |= src
			icon_state = "[icon_state]-on"
		else
			turn_off()
		H << "<span class='notice'>You toggle the inbuilt jetpack [on? "on":"off"].</span>"

/obj/item/weapon/tank/jetpack/suit/proc/turn_off()
	on = 0
	SSobj.processing -= src
	ion_trail.stop()
	air_contents = null
	tank = null
	icon_state = initial(icon_state)

/obj/item/weapon/tank/jetpack/suit/process()
	if(!istype(loc.loc,/mob/living/carbon/human))
		turn_off()
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off()
		return
	..()
