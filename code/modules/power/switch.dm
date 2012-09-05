//This is a power switch. When turned on it looks at the cables around the tile that it's on and notes which cables are trying to connect to it.
//After it knows this it creates the number of cables from the center to each of the cables attempting to conenct. These cables cannot be removed
//with wirecutters. When the switch is turned off it removes all the cables on the tile it's on.
//The switch uses a 5s delay to prevent powernet change spamming.
/*
/obj/structure/powerswitch
	name = "power switch"
	desc = "A switch that controls power."
	icon = 'icons/obj/power.dmi'
	icon_state = "switch-dbl-up"
	var/icon_state_on = "switch-dbl-down"
	var/icon_state_off = "switch-dbl-up"
	flags = FPRINT
	density = 0
	anchored = 1
	var/on = 0  //up is off, down is on
	var/busy = 0 //set to 1 when you start pulling

/obj/structure/powerswitch/simple
	icon_state = "switch-up"
	icon_state_on = "switch-down"
	icon_state_off = "switch-up"


/obj/structure/powerswitch/examine()
	..()
	if(on)
		usr << "The switch is in the on position"
	else
		usr << "The switch is in the off position"

/obj/structure/powerswitch/attack_ai(mob/user)
	user << "\red You're an AI. This is a manual switch. It's not going to work."
	return

/obj/structure/powerswitch/attack_hand(mob/user)

	if(busy)
		user << "\red This switch is already being toggled."
		return

	..()

	busy = 1
	for(var/mob/O in viewers(user))
		O.show_message(text("\red [user] started pulling the [src]."), 1)

	if(do_after(user, 50))
		set_state(!on)
		for(var/mob/O in viewers(user))
			O.show_message(text("\red [user] flipped the [src] into the [on ? "on": "off"] position."), 1)
	busy = 0

/obj/structure/powerswitch/proc/set_state(var/state)
	on = state
	if(on)
		icon_state = icon_state_on
		var/list/connection_dirs = list()
		for(var/direction in list(1,2,4,8,5,6,9,10))
			for(var/obj/structure/cable/C in get_step(src,direction))
				if(C.d1 == turn(direction, 180) || C.d2 == turn(direction, 180))
					connection_dirs += direction
					break

		for(var/direction in connection_dirs)
			var/obj/structure/cable/C = new/obj/structure/cable(src.loc)
			C.d1 = 0
			C.d2 = direction
			C.icon_state = "[C.d1]-[C.d2]"
			C.power_switch = src

			var/datum/powernet/PN = new()
			PN.number = powernets.len + 1
			powernets += PN
			C.netnum = PN.number
			PN.cables += C

			C.mergeConnectedNetworks(C.d2)
			C.mergeConnectedNetworksOnTurf()

	else
		icon_state = icon_state_off
		for(var/obj/structure/cable/C in src.loc)
			del(C)
*/