
GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = 0
	density = 1
	req_access = list(GLOB.access_engine_equip)
//	use_power = 0
	obj_integrity = 350
	max_integrity = 350
	integrity_failure = 80
	var/obj/item/weapon/tank/internals/plasma/loaded_tank = null
	var/last_power = 0
	var/active = 0
	var/locked = 0
	var/drainratio = 1

/obj/machinery/power/rad_collector/New()
	..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()

/obj/machinery/power/rad_collector/process()
	if(loaded_tank)
		if(!loaded_tank.air_contents.gases["plasma"])
			investigate_log("<font color='red'>out of fuel</font>.","singulo")
			eject()
		else
			loaded_tank.air_contents.gases["plasma"][MOLES] -= 0.001*drainratio
			loaded_tank.air_contents.garbage_collect()
	return


/obj/machinery/power/rad_collector/attack_hand(mob/user)
	if(..())
		return
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			"<span class='notice'>You turn the [src.name] [active? "on":"off"].</span>")
			var/fuel = loaded_tank.air_contents.gases["plasma"]
			fuel = fuel ? fuel[MOLES] : 0
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [user.key]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].","singulo")
			return
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return
..()

/obj/machinery/power/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(loaded_tank)
		if(!silent)
			to_chat(user, "<span class='warning'>Remove the plasma tank first!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/rad_collector/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		to_chat(user, "<span class='notice'>The [W.name] detects that [last_power]W were recently produced.</span>")
		return 1
	else if(istype(W, /obj/item/device/analyzer) && loaded_tank)
		atmosanalyzer_scan(loaded_tank.air_contents, user)
	else if(istype(W, /obj/item/weapon/tank/internals/plasma))
		if(!anchored)
			to_chat(user, "<span class='warning'>The [src] needs to be secured to the floor first!</span>")
			return 1
		if(loaded_tank)
			to_chat(user, "<span class='warning'>There's already a plasma tank loaded!</span>")
			return 1
		if(!user.drop_item())
			return 1
		loaded_tank = W
		W.forceMove(src)
		update_icons()
	else if(istype(W, /obj/item/weapon/crowbar))
		if(loaded_tank && !locked)
			eject()
			return 1
	else if(istype(W, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, W, 0)
		return 1
	else if(W.GetID())
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
			else
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is active!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
			return 1
	else
		return ..()


/obj/machinery/power/rad_collector/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		eject()
		stat |= BROKEN

/obj/machinery/power/rad_collector/proc/eject()
	locked = 0
	var/obj/item/weapon/tank/internals/plasma/Z = src.loaded_tank
	if (!Z)
		return
	Z.loc = get_turf(src)
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icons()

/obj/machinery/power/rad_collector/proc/receive_pulse(pulse_strength)
	if(loaded_tank && active)
		var/power_produced = loaded_tank.air_contents.gases["plasma"] ? loaded_tank.air_contents.gases["plasma"][MOLES] : 0
		power_produced *= pulse_strength*10
		add_avail(power_produced)
		last_power = power_produced
		return
	return


/obj/machinery/power/rad_collector/proc/update_icons()
	cut_overlays()
	if(loaded_tank)
		add_overlay("ptank")
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay("on")


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
