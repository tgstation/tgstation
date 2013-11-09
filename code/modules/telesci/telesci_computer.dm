/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/rotation_off
	var/power_off

	var/rotation
	var/angle
	var/power = 25

	// Based on the power used
	var/teleport_cooldown = 0
	var/list/power_options = list(50, 200, 500) //

/obj/machinery/computer/telescience/New()
	..()
	teles_left = rand(8,12)
	rotation_off = rand(-10,10)
	power_off = rand(-10,10)
	initialize()

/obj/machinery/computer/telescience/initialize()
	..()
	telepad = locate() in range(src, 7)

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)

	var/t = "<div class='statusDisplay'>[temp_msg]</div>"
	t += "<A href='?src=\ref[src];setrotation=1'>Set Rotation</A>"
	t += "<div class='statusDisplay'>[rotation ? rotation : "NULL"]°</div>"
	t += "<A href='?src=\ref[src];setangle=1'>Set Angle</A>:"
	t += "<div class='statusDisplay'>[angle ? angle : "NULL"]°</div>"
	t += "<span class='linkOn'>Set Power</span>:"
	t += "<div class='statusDisplay'>"

	for(var/pwr in power_options)
		if(power == pwr)
			t += "<span class='linkOn'>[pwr]</span>"
			continue
		t += "<A href='?src=\ref[src];setpower=[pwr]'>[pwr]</A>"

	t += "</div>"
	t += "<A href='?src=\ref[src];setz=1'>Set Z Level</A>:"
	t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

	t += "<BR><BR><A href='?src=\ref[src];send=1'>Send</A>"
	t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
	t += "<BR><BR><A href='?src=\ref[src];recal=1'>Recalibrate</A>"

	// Information about the last teleport
	t += "<BR><div class='statusDisplay'>"
	if(!last_tele_data)
		t += "No teleport data found."
	else
		t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])"
		t += "Distance: [last_tele_data.distance]ft<BR>"
		t += "Time: [last_tele_data.time]secs<BR>"
	t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/L = get_turf(E)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(telepad)
		var/truePower = Clamp(power - power_off, 0, 1000)
		var/trueRotation = SimplifyDegrees(rotation - rotation_off)
		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, angle, truePower)

		var/trueX = proj_data.dest_x
		var/trueY = proj_data.dest_y

		var/turf/target = locate(trueX, trueY, z_co)
		var/area/A = get_area(target)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, telepad)
		s.start()
		flick("pad-beam", telepad)
		temp_msg = "Teleport successful."
		investigate_log("[key_name(usr)]/[user] has teleported with Telescience at [trueX],[trueY],[z_co], in [A.name].","telesci")
		var/sparks = get_turf(target)
		var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()
		var/turf/source = target
		var/turf/dest = get_turf(telepad)
		if(sending)
			source = dest
			dest = target
		for(var/atom/movable/ROI in source)
			if(!ismob(ROI) && ROI.anchored) continue
			do_teleport(ROI, dest, 0)
		last_tele_data = proj_data

// TO DO: add projectile_trajectory to telesci

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "Error: set a angle, rotation and z level."
		return
	if(rotation < 0 || rotation > 360)
		telefail()
		temp_msg = "Error: Rotation is less than 0 or greater than 360."
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "Error: Angle is less than 1 or greater than 90."
		return
	if(z_co == 2 || z_co < 1 || z_co > 7)
		telefail()
		temp_msg = "Error: Z is less than 1, greater than 7, or equal to 2."
		return
	if(teles_left > 0)
		teles_left -= 1
		doteleport(user)
	else
		telefail()
		return
	return

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(href_list["setrotation"])
		var/new_rot = input("Please input desired rotation in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = Clamp(new_rot, 1, 9999)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired angle in degrees.", name, angle) as num
		if(..())
			return
		angle = Clamp(new_angle, 1, 9999)

	if(href_list["setpower"])
		var/pwr = href_list["setpower"]
		if(pwr in power_options)
			power = pwr

	if(href_list["setz"])
		var/new_z = input("Please input desired Z coordinate.", name, z_co) as num
		if(..())
			return
		z_co = Clamp(new_z, 1, 9999)

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		teles_left = rand(9,12)
		rotation_off = rand(-10,10)
		power_off = rand(-10,10)
		sparks()
		temp_msg = "Calibration successful."

	updateDialog()