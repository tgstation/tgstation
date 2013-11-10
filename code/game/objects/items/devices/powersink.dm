// Powersink - used to drain station power

/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	origin_tech = "powerstorage=3;syndicate=5"
	var/drain_rate = 600000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating

	var/const/DISCONNECTED = 0
	var/const/CLAMPED_OFF = 1
	var/const/OPERATING = 2

	var/obj/structure/cable/attached		// the attached cable

/obj/item/device/powersink/update_icon()
	icon_state = "powersink[mode == OPERATING]"

/obj/item/device/powersink/proc/set_mode(value)
	if(value == mode)
		return
	switch(value)
		if(DISCONNECTED)
			attached = null
			if(mode == OPERATING)
				processing_objects.Remove(src)
			anchored = 0

		if(CLAMPED_OFF)
			if(!attached)
				return
			if(mode == OPERATING)
				processing_objects.Remove(src)
			anchored = 1

		if(OPERATING)
			if(!attached)
				return
			processing_objects.Add(src)
			anchored = 1

	mode = value
	update_icon()
	SetLuminosity(0)

/obj/item/device/powersink/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(mode == DISCONNECTED)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					user << "No exposed cable here to attach to."
				else
					set_mode(CLAMPED_OFF)
					user.visible_message( \
						"[user] attaches \the [src] to the cable.", \
						"You attach \the [src] to the cable.",
						"You hear some wires being connected to something.")
			else
				user << "Device must be placed over an exposed cable to attach to it."
		else
			set_mode(DISCONNECTED)
			user.visible_message( \
				"[user] detaches \the [src] from the cable.", \
				"You detach \the [src] from the cable.",
				"You hear some wires being disconnected from something.")
	else
		..()

/obj/item/device/powersink/attack_paw()
	return

/obj/item/device/powersink/attack_ai()
	return

/obj/item/device/powersink/attack_hand(var/mob/user)
	switch(mode)
		if(DISCONNECTED)
			..()

		if(CLAMPED_OFF)
			user.visible_message( \
				"[user] activates \the [src]!", \
				"You activate \the [src]!",
				"You hear a click.")
			set_mode(OPERATING)

		if(OPERATING)
			user.visible_message( \
				"[user] deactivates \the [src]!", \
				"You deactivate \the [src]!",
				"You hear a click.")
			set_mode(CLAMPED_OFF)

/obj/item/device/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)
		return

	var/datum/powernet/PN = attached.get_powernet()
	if(PN)
		SetLuminosity(5)

		// found a powernet, so drain up to max power from it

		var/drained = min ( drain_rate, PN.avail )
		PN.newload += drained
		power_drained += drained

		// if tried to drain more than available on powernet
		// now look for APCs and drain their cells
		if(drained < drain_rate)
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						A.cell.charge = max(0, A.cell.charge - 50)
						power_drained += 50

	if(power_drained > max_power * 0.95)
		playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)
	if(power_drained >= max_power)
		processing_objects.Remove(src)
		explosion(src.loc, 3,6,9,12)
		del(src)
