#define INTERSECTOR_CYCLES 30
#define RANGE_PER_CRYSTAL 20
#define RANGE_PER_TECH_TIER 20

/obj/machinery/computer/telescience
	name = "\improper Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/telesci_console
	var/sending = TRUE
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/power_off
	var/target_point //current teleport target
	var/last_target

	var/target_x = 0
	var/target_y = 0
	var/target_z = 1
	var/calibrated = FALSE
	var/calibrating = FALSE
	var/range = 15

	var/teleporting = FALSE
	var/starting_crystals = 3
	var/max_crystals = 5
	var/list/crystals = list()
	var/obj/item/device/gps/inserted_gps

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.forceMove(get_turf(src))
		inserted_gps = null
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	..()
	to_chat(user, "There are [crystals.len ? crystals.len : "no"] bluespace crystal\s in the crystal slots.")

/obj/machinery/computer/telescience/Initialize(mapload)
	..()
	if(mapload)
		for(var/i = 1; i <= starting_crystals; i++)
			crystals += new /obj/item/weapon/ore/bluespace_crystal/artificial(src) // starting crystals

/obj/machinery/computer/telescience/attack_paw(mob/user)
	to_chat(user, "<span class='warning'>You are too primitive to use this computer!</span>")
	return

/obj/machinery/computer/telescience/proc/update_range()
	range = initial(range) + RANGE_PER_CRYSTAL * LAZYLEN(crystals)
	range += RANGE_PER_TECH_TIER * telepad.telepower

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/ore/bluespace_crystal))
		if(crystals.len >= max_crystals)
			to_chat(user, "<span class='warning'>There are not enough crystal slots.</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		crystals += W
		W.forceMove(src)
		user.visible_message("[user] inserts [W] into \the [src]'s crystal slot.", "<span class='notice'>You insert [W] into \the [src]'s crystal slot.</span>")
		updateDialog()
	else if(istype(W, /obj/item/device/gps))
		if(!inserted_gps)
			if(!user.transferItemToLoc(W, src))
				return
			inserted_gps = W
			user.visible_message("[user] inserts [W] into \the [src]'s GPS device slot.", "<span class='notice'>You insert [W] into \the [src]'s GPS device slot.</span>")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			to_chat(user, "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>")
	else
		return ..()

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=\ref[src];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=\ref[src];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=\ref[src];set_x=1'>Set Parallel</A>"
		t += "<div class='statusDisplay'>[target_x]</div>"
		t += "<A href='?src=\ref[src];set_y=1'>Set Trasversal</A>"
		t += "<div class='statusDisplay'>[target_y]</div>"
		t += "<A href='?src=\ref[src];set_z=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[target_z ? target_z : "NULL"]</div>"

		t += "<BR><A href='?src=\ref[src];send=1'>Send</A>"
		t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
		t += "<BR><A href='?src=\ref[src];calibrate=1'>Calibrate</A>"
		t += "<BR><A href='?src=\ref[src];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(!target_point)
		temp_msg = "Telepad is not calibrated for any location."
		return

	if(telepad)
		var/turf/target = target_point
		var/area/A = get_area(target)
		flick("pad-beam", telepad)



		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		sleep(10) // in seconds
		if(!telepad)
			return
		if(telepad.stat & NOPOWER)
			return
		teleporting = FALSE

		// use a lot of power
		use_power(10)

		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()

		temp_msg = "Teleport successful.<BR>"
		temp_msg += "Data printed below."

		var/sparks = get_turf(target)
		var/datum/effect_system/spark_spread/y = new /datum/effect_system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()

		var/turf/source = target
		var/turf/dest = get_turf(telepad)
		var/log_msg = ""
		log_msg += ": [key_name(user)] has teleported "

		if(sending)
			source = dest
			dest = target

		flick("pad-beam", telepad)
		playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
		for(var/atom/movable/ROI in source)
			// if is anchored, don't let through
			if(ROI.anchored)
				if(isliving(ROI))
					var/mob/living/L = ROI
					if(L.buckled)
						// TP people on office chairs
						if(L.buckled.anchored)
							continue

						log_msg += "[key_name(L)] (on a chair), "
					else
						continue
				else if(!isobserver(ROI))
					continue
			if(ismob(ROI))
				var/mob/T = ROI
				log_msg += "[key_name(T)], "
			else
				log_msg += "[ROI.name]"
				if (istype(ROI, /obj/structure/closet))
					var/obj/structure/closet/C = ROI
					log_msg += " ("
					for(var/atom/movable/Q as mob|obj in C)
						if(ismob(Q))
							log_msg += "[key_name(Q)], "
						else
							log_msg += "[Q.name], "
					if (dd_hassuffix(log_msg, "("))
						log_msg += "empty)"
					else
						log_msg = dd_limittext(log_msg, length(log_msg) - 2)
						log_msg += ")"
				log_msg += ", "
			do_teleport(ROI, dest)

		if (dd_hassuffix(log_msg, ", "))
			log_msg = dd_limittext(log_msg, length(log_msg) - 2)
		else
			log_msg += "nothing"
		log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [target_z] ([A ? A.name : "null area"])"
		investigate_log(log_msg, "telesci")
		updateDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(target_x == null || target_y == null || target_z == null)
		temp_msg = "ERROR!<BR>Set a parallel, trasversal and sector."
		return
	if(target_z == ZLEVEL_CENTCOM || target_z < 1 || target_z > ZLEVEL_SPACEMAX)
		telefail()
		temp_msg = "ERROR! Sector is outside known time and space!"
		return
	if(calibrated)
		doteleport(user)
	else
		telefail()
		temp_msg = "ERROR!<BR>Calibration required."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.forceMove(get_turf(src))
		crystals -= I

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["set_x"])
		var/new_x = input("Please input desired parallel.", name, target_x) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		target_x = new_x

	if(href_list["set_y"])
		var/new_y = input("Please input desired trasversal.", name, target_y) as num
		if(..())
			return
		target_y = new_y

	if(href_list["set_z"])
		var/new_z = input("Please input desired sector.", name, target_z) as num
		if(..())
			return
		target_z = Clamp(round(new_z), 1, 10)

	if(href_list["ejectGPS"])
		if(inserted_gps)
			inserted_gps.loc = loc
			inserted_gps = null

	if(href_list["setMemory"])
		if(last_target && inserted_gps)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data was stored."

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["calibrate"])
		if(!calibrating)
			calibrate()
		else
			temp_msg = "ERROR!<BR>Calibration in progress."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateDialog()

/obj/machinery/computer/telescience/proc/calibrate()
	calibrating = TRUE
	calibrated = FALSE

	temp_msg = "Calibration in progress..."
	updateDialog()

	var/turf/target = locate(target_x, target_y, target_z)
	var/area/A = get_area(target)
	var/inter_sector = FALSE

	if(target_z != telepad.z)
		inter_sector = TRUE

	var/calibration_cycles
	var/calibration_time = 12 - (2 * telepad.efficiency) //0.5 second per tile, going down to 0.2 seconds per tile

	if(!inter_sector)
		var/dist_from_last = get_dist(target, last_target)
		var/dist_from_pad = get_dist(get_turf(telepad), target)
		var/effective_dist = min(dist_from_pad, dist_from_last*2)
		calibration_cycles = round(effective_dist / 2)
	else
		calibration_cycles = INTERSECTOR_CYCLES

	var/calibration_radius = round(calibration_cycles / 60) //Radius of the visual effect
	var/calibration_turfs = range(target, calibration_radius)

	for(var/i in 1 to calibration_cycles)
		var/turf/T = pick(calibration_turfs)
		new /obj/effect/overlay/temp/swarmer/integrate(get_turf(T))
		sleep(calibration_time)

	new /obj/effect/overlay/temp/emp/pulse(get_turf(target))

	temp_msg = "Calibration complete."
	updateDialog()

	target_point = target
	last_target = target

	calibrated = TRUE
	calibrating = FALSE

