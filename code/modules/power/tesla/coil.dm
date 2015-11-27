/obj/machinery/power/tesla_coil
	name = "Tesla Coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil"
	anchored = 0
	density = 1
	var/power_loss = 2
	var/being_shocked = 0

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			anchored = 1
			user.visible_message("[user.name] secures the [src.name].", \
				"<span class='notice'>You secure the external bolts.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			connect_to_network()
		else if(anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			anchored = 0
			user.visible_message("[user.name] unsecures the [src.name].", \
				"<span class='notice'>You unsecure the external bolts.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			disconnect_from_network()

/obj/machinery/power/tesla_coil/proc/tesla_act(var/power)
	being_shocked = 1
	var/power_produced = power / power_loss
	add_avail(power_produced)
	flick("coilhit", src)
	tesla_zap(src, 3, power_produced)
	spawn(10)
		being_shocked = 0