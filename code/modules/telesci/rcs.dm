/var/list/obj/machinery/telepad_cargo/cargo_telepads = list()

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

/obj/machinery/telepad_cargo/New()
	global.cargo_telepads += src
	..()

/obj/machinery/telepad_cargo/Destroy()
	global.cargo_telepads -= src
	return ..()

/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswrench(W))
		anchored = 0
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class = 'caution'> The [src] can now be moved.</span>")
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class = 'caution'> The [src] is now secured.</span>")
	if(isscrewdriver(W))
		if(stage == 0)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			to_chat(user, "<span class = 'caution'>You unscrew the telepad's tracking beacon.</span>")
			stage = 1
		else if(stage == 1)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			to_chat(user, "<span class = 'caution'>You screw in the telepad's tracking beacon.</span>")
			stage = 0
	if(istype(W, /obj/item/weapon/weldingtool) && stage == 1)
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		to_chat(user, "<span class = 'caution'>You disassemble the telepad.</span>")
		var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
		M.amount = 1
		new /obj/item/stack/sheet/glass/glass(get_turf(src))
		qdel(src)

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=3"

/obj/item/device/telepad_beacon/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class = 'caution'> Locked In</span>")
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

#define MODE_NORMAL 0
#define MODE_RANDOM 1

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	flags = FPRINT
	siemens_coefficient = 1
	force = 10
	throwforce  = 10
	throw_speed = 1
	throw_range = 5
	var/obj/item/weapon/cell/high/cell = null
	var/mode    = MODE_NORMAL
	var/emagged = FALSE
	var/send_cost = 1500
	var/tmp/teleporting = FALSE

/obj/item/weapon/rcs/New()
	..()
	cell = new (src)

/obj/item/weapon/rcs/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>There are [round(cell.charge / send_cost)] charges left.</span>")

/obj/item/weapon/rcs/Destroy()
	if (cell)
		qdel(cell)
		cell = null
	..()

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		mode = !mode
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		if(mode == MODE_NORMAL)
			to_chat(user, "<span class = 'caution'>You calibrate the telepad locator.</span>")
		else
			to_chat(user, "<span class = 'caution'> The telepad locator has become uncalibrated.</span>")


/obj/item/weapon/rcs/attackby(var/obj/item/W, var/mob/user)
	if(isEmag(W) && !emagged)
		emagged = 1
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		to_chat(user, "<span class = 'caution'>You emag the RCS. Click on it to toggle between modes.</span>")

/obj/item/weapon/rcs/preattack(var/obj/structure/closet/crate/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if (!istype(target) || target.opened || !proximity_flag || !cell || teleporting)
		return

	if (cell.charge < send_cost)
		to_chat(user, "<span class='warning'>Out of charges.</span>")
		return 1

	// Get location to teleport to.
	var/turf/teleport_target
	if (mode == MODE_NORMAL)
		var/list/obj/machinery/telepad_cargo/input_list = list()
		var/list/area/area_index = list()
		for (var/obj/machinery/telepad_cargo/telepad in cargo_telepads)
			var/turf/T = get_turf(telepad)
			if (!T)
				continue

			var/area_name = T.loc.name
			if (area_index[area_name])
				area_name = "[area_name] ([++area_index[area_name]])"
			else
				area_index[area_name] = 1

			input_list[area_name] = telepad

		var/inputted = input("Which telepad to teleport to?", "RCS") as null | anything in input_list
		if (!inputted || !user || user.isUnconscious() || !target || !user.Adjacent(target) || teleporting || cell.charge < send_cost)
			return 1

		var/obj/machinery/telepad_cargo/telepad = input_list[inputted]
		if (!telepad || !telepad.loc)
			return 1

		teleport_target = get_turf(telepad)

	else if (mode == MODE_RANDOM)
		teleport_target = locate(rand(50, 450), rand(50, 450), 6)

	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='notic'>Teleporting \the [target]...</span>")
	teleporting = TRUE
	if (!do_after(user, target, 50))
		teleporting = FALSE
		return 1

	teleporting = FALSE
	do_teleport(target, teleport_target)
	/*var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()*/
	cell.use(send_cost)
	to_chat(user, "<span class='notice'>Teleport successful. [round(cell.charge / send_cost)] charge\s left.</span>")
	return 1

#undef MODE_NORMAL
#undef MODE_RANDOM
