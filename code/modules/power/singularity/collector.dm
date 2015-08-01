//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33
var/global/list/rad_collectors = list()

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)
//	use_power = 0
	var/obj/item/weapon/tank/internals/plasma/ptank = null
	var/last_power = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

/obj/machinery/power/rad_collector/New()
	..()
	rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	rad_collectors -= src
	..()

/obj/machinery/power/rad_collector/process()
	if(ptank)
		if(ptank.air_contents.toxins <= 0)
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			ptank.air_contents.toxins = 0
			eject()
		else
			ptank.air_contents.toxins -= 0.001*drainratio
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			"<span class='notice'>You turn the [src.name] [active? "on":"off"].</span>")
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [ptank?"Fuel: [round(ptank.air_contents.toxins/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
			return
		else
			user << "<span class='warning'>The controls are locked!</span>"
			return
..()


/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		user << "<span class='notice'>The [W.name] detects that [last_power]W were recently produced.</span>"
		return 1
	else if(istype(W, /obj/item/device/analyzer) && ptank)
		atmosanalyzer_scan(ptank.air_contents, user)
	else if(istype(W, /obj/item/weapon/tank/internals/plasma))
		if(!src.anchored)
			user << "<span class='warning'>The [src] needs to be secured to the floor first!</span>"
			return 1
		if(src.ptank)
			user << "<span class='warning'>There's already a plasma tank loaded!</span>"
			return 1
		if(!user.drop_item())
			return 1
		src.ptank = W
		W.loc = src
		update_icons()
	else if(istype(W, /obj/item/weapon/crowbar))
		if(ptank && !src.locked)
			eject()
			return 1
	else if(istype(W, /obj/item/weapon/wrench))
		if(ptank)
			user << "<span class='warning'>Remove the plasma tank first!</span>"
			return 1
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
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			if(active)
				src.locked = !src.locked
				user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "<span class='warning'>The controls can only be locked when \the [src] is active!</span>"
		else
			user << "<span class='danger'>Access denied.</span>"
			return 1
	else if(istype(W, /obj/item/weapon/tankmanip))
		var/obj/item/weapon/tankmanip/T = W
		if (T.tanks)
			if(!src.anchored)
				user << "<span class='warning'>The [src] needs to be secured to the floor first!</span>"
				return 1
			if(src.ptank)
				user << "<span class='warning'>There is already a tank in the collector!</span>"
				return 1
			playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
			var/obj/item/weapon/tank/internals/plasma/intank = T.storedtanks[1]
			src.ptank = intank
			intank.loc = src
			T.tanks--
			T.storedtanks.Remove(intank)
			intank = null
			update_icons()
			T.update_icon()
			return
	else
		..()
		return 1


/obj/machinery/power/rad_collector/ex_act(severity, target)
	switch(severity)
		if(2, 3)
			eject()
	return ..()


/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	if (!ptank)
		return
	ptank.loc = get_turf(src)
	ptank.layer = initial(ptank.layer)
	src.ptank = null
	if(active)
		toggle_power()
	else
		update_icons()
	return

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(ptank && active)
		var/power_produced = 0
		power_produced = ptank.air_contents.toxins*pulse_strength*20
		add_avail(power_produced)
		last_power = power_produced
		return
	return


/obj/machinery/power/rad_collector/proc/update_icons()
	overlays.Cut()
	if(ptank)
		overlays += image('icons/obj/singularity.dmi', "ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		overlays += image('icons/obj/singularity.dmi', "on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icons()
	return

