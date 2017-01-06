///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency

/obj/machinery/telepad/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/telesci_pad(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/telesci_pad
	name = "Telepad (Machine Board)"
	build_path = /obj/machinery/telepad
	origin_tech = "programming=4;engineering=3;plasmatech=4;bluespace=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/telepad/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E

/obj/machinery/telepad/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "pad-idle", I))
		return

	if(panel_open)
		if(istype(I, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = I
			M.buffer = src
			user << "<span class='caution'>You save the data in the [I.name]'s buffer.</span>"
			return 1

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()


//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0
/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = 0
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			user << "<span class='caution'>\The [src] can now be moved.</span>"
		else if(!anchored)
			anchored = 1
			user << "<span class='caution'>\The [src] is now secured.</span>"
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(stage == 0)
			playsound(src, W.usesound, 50, 1)
			user << "<span class='caution'>You unscrew the telepad's tracking beacon.</span>"
			stage = 1
		else if(stage == 1)
			playsound(src, W.usesound, 50, 1)
			user << "<span class='caution'>You screw in the telepad's tracking beacon.</span>"
			stage = 0
	else if(istype(W, /obj/item/weapon/weldingtool) && stage == 1)
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start disassembling [src]...</span>"
			if(do_after(user,20*WT.toolspeed, target = src))
				if(!WT.isOn())
					return
				user << "<span class='notice'>You disassemble [src].</span>"
				new /obj/item/stack/sheet/metal(get_turf(src))
				new /obj/item/stack/sheet/glass(get_turf(src))
				qdel(src)
	else
		return ..()

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	origin_tech = "bluespace=3"

/obj/item/device/telepad_beacon/attack_self(mob/user)
	if(user)
		user << "<span class='caution'>Locked In</span>"
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	flags = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 2
	throw_range = 5
	var/rcharges = 10
	var/obj/machinery/pad = null
	var/last_charge = 30
	var/mode = 0
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = 0
	var/teleporting = 0

/obj/item/weapon/rcs/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/rcs/examine(mob/user)
	..()
	user << "There are [rcharges] charge\s left."

/obj/item/weapon/rcs/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
/obj/item/weapon/rcs/process()
	if(rcharges > 10)
		rcharges = 10
	if(last_charge == 0)
		rcharges++
		last_charge = 30
	else
		last_charge--

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		if(mode == 0)
			mode = 1
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			user << "<span class='caution'>The telepad locator has become uncalibrated.</span>"
		else
			mode = 0
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			user << "<span class='caution'>You calibrate the telepad locator.</span>"

/obj/item/weapon/rcs/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		user << "<span class='caution'>You emag the RCS. Click on it to toggle between modes.</span>"
