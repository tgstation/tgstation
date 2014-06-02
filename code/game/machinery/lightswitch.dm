// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/on
	//	luminosity = 1

/obj/machinery/light_switch/New()
	..()
	name = "[areaMaster.name] light switch"
	on = areaMaster.lightswitch
	updateicon()

/obj/machinery/light_switch/proc/updateicon()
	if (stat & NOPOWER)
		icon_state = "light-p"
	else
		icon_state = on ? "light1" : "light0"

/obj/machinery/light_switch/examine()
	set src in oview(1)
	if(usr && !usr.stat)
		usr << "A light switch. It is [on? "on" : "off"]."


/obj/machinery/light_switch/attack_paw(mob/user)
	src.attack_hand(user)

/obj/machinery/light_switch/attack_ghost(var/mob/dead/observer/G)
	if(!G.can_poltergeist())
		G << "Your poltergeist abilities are still cooling down."
		return 0
	return ..()

/obj/machinery/light_switch/attack_hand(mob/user)

	on = !on

	for(var/area/A in areaMaster.related)
		A.lightswitch = on
		A.updateicon()

		for(var/obj/machinery/light_switch/L in A)
			L.on = on
			L.updateicon()

	areaMaster.power_change()

/obj/machinery/light_switch/power_change()
	if(powered(LIGHT))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)