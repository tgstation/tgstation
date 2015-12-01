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
	var/obj/item/weapon/tank/plasma/P = null
	var/last_power = 0
	var/active = 0
	var/locked = 0
	var/drain_ratio = 3.5 //3.5 times faster than original.
	ghost_read = 0
	ghost_write = 0

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/power/rad_collector/New()
	..()
	rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	rad_collectors -= src
	eject()
	..()

/obj/machinery/power/rad_collector/process()
	if (P)
		if (P.air_contents.toxins <= 0)
			investigation_log(I_SINGULO,"<font color='red'>out of fuel</font>.")
			P.air_contents.toxins = 0
			eject()
		else if(!active)
			return
		else
			P.air_contents.toxins -= (0.001 * drain_ratio)
			P.air_contents.update_values()

/obj/machinery/power/rad_collector/attack_hand(mob/user as mob)
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("<span class='notice'>[user] turns the [src] [active? "on":"off"].</span>", \
			"<span class='notice'>You turn the [src] [active? "on":"off"].</span>")
			investigation_log(I_SINGULO,"turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [P?"Fuel: [round(P.air_contents.toxins/0.29)]%":"<font color='red'>It is empty</font>"].")
			return
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return
..()

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user)
	if(..())
		return 1
	else if(istype(W, /obj/item/device/analyzer) || istype(W, /obj/item/device/multitool))
		if(active)
			to_chat(user, "<span class='notice'>\The [W] registers that [format_watts(last_power)] is being produced every cycle.</span>")
		else
			to_chat(user, "<span class='notice'>\The [W] registers that the unit is currently not producing power.</span>")
		return 1
	else if(istype(W, /obj/item/weapon/tank/plasma))
		if(!src.anchored)
			to_chat(user, "<span class='warning'>\The [src] needs to be secured to the floor first.</span>")
			return 1
		if(src.P)
			to_chat(user, "<span class='warning'>A plasma tank is already loaded.</span>")
			return 1
		user.drop_item(W, src)
		src.P = W
		update_icons()
	else if(istype(W, /obj/item/weapon/crowbar))
		if(P && !src.locked)
			eject()
			return 1
	else if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "<span class='notice'>The controls are now [src.locked ? "locked." : "unlocked."]</span>")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is active</span>")
		else
			to_chat(user, "<span class='warning'>Access denied!</span>")
			return 1
	else
		return

/obj/machinery/power/rad_collector/wrenchAnchor(mob/user)
	if(P)
		to_chat(user, "<span class='warning'>Remove the plasma tank first.</span>")
		return
	if(..() == 1)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
			last_power = 0
		return 1
	return -1

/obj/machinery/power/rad_collector/ex_act(severity)
	switch(severity)
		if(2, 3)
			eject()

	return ..()

/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	last_power = 0

	if(isnull(P))
		return

	P.loc = get_turf(src)
	P.layer = initial(P.layer)
	P = null

	if(active)
		toggle_power()
	else
		update_icons()

/obj/machinery/power/rad_collector/proc/receive_pulse(const/pulse_strength)
	if (P && active)
		var/power_produced = P.air_contents.toxins * pulse_strength * 3.5 // original was 20, nerfed to 2 now 3.5 should get you about 500kw
		add_avail(power_produced)
		last_power = power_produced

/obj/machinery/power/rad_collector/proc/update_icons()
	overlays.len = 0
	if(P)
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
		last_power = 0

	update_icons()

