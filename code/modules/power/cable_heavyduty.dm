/obj/item/stack/cable_coil/heavyduty
	name = "heavy cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"

/obj/structure/cable/heavyduty
	icon = 'icons/obj/power_cond_heavy.dmi'
	name = "large power cable"
	desc = "This cable is tough. It cannot be cut with simple hand tools."
	layer = 2.39 //Just below pipes, which are at 2.4

/obj/structure/cable/heavyduty/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))
		user << "<span class='notice'>These cables are too tough to be cut with those [W.name].</span>"
		return
	else if(W.type == /obj/item/stack/cable_coil)
		user << "<span class='notice'>You will need heavier cables to connect to these.</span>"
		return
	else
		..()

/obj/structure/cable/heavyduty/cableColor(var/colorC)
	_color = "red"
	l_color = "red"
	return
