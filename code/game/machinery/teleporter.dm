/obj/machinery/computer/teleporter
	name = "Teleporter Control Console"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/teleporter
	var/obj/item/device/gps/locked = null
	var/regime_set = "Teleporter"
	var/id = null
	var/obj/machinery/teleport/station/power_station
	var/calibrating
	var/turf/target //Used for one-time-use teleport cards (such as clown planet coordinates.)
						 //Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	..()

/obj/machinery/computer/teleporter/Initialize()
	..()
	link_power_station()

/obj/machinery/computer/teleporter/Destroy()
	if (power_station)
		power_station.teleporter_console = null
		power_station = null
	return ..()

/obj/machinery/computer/teleporter/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/computer/teleporter/attackby(obj/I, mob/living/user, params)
	if(istype(I, /obj/item/device/gps))
		var/obj/item/device/gps/L = I
		if(L.locked_location && !(stat & (NOPOWER|BROKEN)))
			if(!user.transferItemToLoc(L, src))
				user << "<span class='warning'>\the [I] is stuck to your hand, you cannot put it in \the [src]!</span>"
				return
			locked = L
			user << "<span class='caution'>You insert the GPS device into the [name]'s slot.</span>"
	else
		return ..()

/obj/machinery/computer/teleporter/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/teleporter/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/teleporter/interact(mob/user)
	var/data = "<h3>Teleporter Status</h3>"
	if(!power_station)
		data += "<div class='statusDisplay'>No power station linked.</div>"
	else if(!power_station.teleporter_hub)
		data += "<div class='statusDisplay'>No hub linked.</div>"
	else
		data += "<div class='statusDisplay'>Current regime: [regime_set]<BR>"
		data += "Current target: [(!target) ? "None" : "[get_area(target)] [(regime_set != "Gate") ? "" : "Teleporter"]"]<BR>"
		if(calibrating)
			data += "Calibration: <font color='yellow'>In Progress</font>"
		else if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			data += "Calibration: <font color='green'>Optimal</font>"
		else
			data += "Calibration: <font color='red'>Sub-Optimal</font>"
		data += "</div><BR>"

		data += "<A href='?src=\ref[src];regimeset=1'>Change regime</A><BR>"
		data += "<A href='?src=\ref[src];settarget=1'>Set target</A><BR>"
		if(locked)
			data += "<BR><A href='?src=\ref[src];locked=1'>Get target from memory</A><BR>"
			data += "<A href='?src=\ref[src];eject=1'>Eject GPS device</A><BR>"
		else
			data += "<BR><span class='linkOff'>Get target from memory</span><BR>"
			data += "<span class='linkOff'>Eject GPS device</span><BR>"

		data += "<BR><A href='?src=\ref[src];calibrate=1'>Calibrate Hub</A>"

	var/datum/browser/popup = new(user, "teleporter", name, 400, 400)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/computer/teleporter/Topic(href, href_list)
	if(..())
		return

	if(href_list["eject"])
		eject()
		updateDialog()
		return

	if(!check_hub_connection())
		say("Error: Unable to detect hub.")
		return
	if(calibrating)
		say("Error: Calibration in progress. Stand by.")
		return

	if(href_list["regimeset"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		reset_regime()
	if(href_list["settarget"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		set_target(usr)
	if(href_list["locked"])
		power_station.engaged = 0
		power_station.teleporter_hub.update_icon()
		power_station.teleporter_hub.calibrated = 0
		target = get_turf(locked.locked_location)
	if(href_list["calibrate"])
		if(!target)
			say("Error: No target set to calibrate to.")
			return
		if(power_station.teleporter_hub.calibrated || power_station.teleporter_hub.accurate >= 3)
			say("Hub is already calibrated!")
			return
		say("Processing hub calibration to target...")

		calibrating = 1
		spawn(50 * (3 - power_station.teleporter_hub.accurate)) //Better parts mean faster calibration
			calibrating = 0
			if(check_hub_connection())
				power_station.teleporter_hub.calibrated = 1
				say("Calibration complete.")
			else
				say("Error: Unable to detect hub.")
			updateDialog()

	updateDialog()

/obj/machinery/computer/teleporter/proc/check_hub_connection()
	if(!power_station)
		return
	if(!power_station.teleporter_hub)
		return
	return 1

/obj/machinery/computer/teleporter/proc/reset_regime()
	target = null
	if(regime_set == "Teleporter")
		regime_set = "Gate"
	else
		regime_set = "Teleporter"

/obj/machinery/computer/teleporter/proc/eject()
	if(locked)
		locked.loc = loc
		locked = null

/obj/machinery/computer/teleporter/proc/set_target(mob/user)
	var/list/L = list()
	var/list/areaindex = list()
	if(regime_set == "Teleporter")
		for(var/obj/item/device/radio/beacon/R in teleportbeacons)
			var/turf/T = get_turf(R)
			if(!T)
				continue
			if(T.z == ZLEVEL_CENTCOM || T.z > ZLEVEL_SPACEMAX)
				continue
			L[avoid_assoc_duplicate_keys(T.loc.name, areaindex)] = R

		for(var/obj/item/weapon/implant/tracking/I in tracked_implants)
			if(!I.imp_in || !ismob(I.loc))
				continue
			else
				var/mob/M = I.loc
				if(M.stat == DEAD)
					if(M.timeofdeath + 6000 < world.time)
						continue
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z == ZLEVEL_CENTCOM)
					continue
				L[avoid_assoc_duplicate_keys(M.real_name, areaindex)] = I

		var/desc = input("Please select a location to lock in.", "Locking Computer") as null|anything in L
		target = L[desc]

	else
		var/list/S = power_station.linked_stations
		if(!S.len)
			user << "<span class='alert'>No connected stations located.</span>"
			return
		for(var/obj/machinery/teleport/station/R in S)
			var/turf/T = get_turf(R)
			if(!T || !R.teleporter_hub || !R.teleporter_console)
				continue
			if(T.z == ZLEVEL_CENTCOM || T.z > ZLEVEL_SPACEMAX)
				continue
			L[avoid_assoc_duplicate_keys(T.loc.name, areaindex)] = R
		var/desc = input("Please select a station to lock in.", "Locking Computer") as null|anything in L
		target = L[desc]
		if(target)
			var/obj/machinery/teleport/station/trg = target
			trg.linked_stations |= power_station
			trg.stat &= ~NOPOWER
			if(trg.teleporter_hub)
				trg.teleporter_hub.stat &= ~NOPOWER
				trg.teleporter_hub.update_icon()
			if(trg.teleporter_console)
				trg.teleporter_console.stat &= ~NOPOWER
				trg.teleporter_console.update_icon()

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/machines/teleporter.dmi'
	density = 1
	anchored = 1

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation

/obj/machinery/teleport/hub/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/teleporter_hub(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/teleporter_hub
	name = "Teleporter Hub (Machine Board)"
	build_path = /obj/machinery/teleport/hub
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 3,
							/obj/item/weapon/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/teleport/hub/Initialize()
	..()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accurate = A

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		power_station = locate(/obj/machinery/teleport/station, get_step(src, dir))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	if(z == ZLEVEL_CENTCOM)
		M << "You can't use this here."
	if(is_ready())
		teleport(M)
		use_power(5000)
	return

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		if(power_station && power_station.engaged)
			power_station.engaged = 0 //hub with panel open is off, so the station must be informed.
			update_icon()
		return
	if(exchange_parts(user, W))
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (!com)
		return
	if (!com.target)
		visible_message("<span class='alert'>Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (istype(M, /atom/movable))
		if(do_teleport(M, com.target))
			if(!calibrated && prob(30 - ((accurate) * 10))) //oh dear a problem
				if(ishuman(M))//don't remove people from the round randomly you jerks
					var/mob/living/carbon/human/human = M
					if(human.dna && human.dna.species.id == "human")
						M  << "<span class='italics'>You hear a buzzing in your ears.</span>"
						human.set_species(/datum/species/fly)

					human.apply_effect((rand(120 - accurate * 40, 180 - accurate * 60)), IRRADIATE, 0)
			calibrated = 0
	return

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(is_ready())
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/hub/power_change()
	..()
	update_icon()

/obj/machinery/teleport/hub/proc/is_ready()
	. = !panel_open && !(stat & (BROKEN|NOPOWER)) && power_station && power_station.engaged && !(power_station.stat & (BROKEN|NOPOWER))

/obj/machinery/teleport/hub/syndicate/New()
	..()
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	RefreshParts()


/obj/machinery/teleport/station
	name = "station"
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/teleporter_station(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/teleporter_station
	name = "Teleporter Station (Machine Board)"
	build_path = /obj/machinery/teleport/station
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
							/obj/item/weapon/ore/bluespace_crystal = 2,
							/obj/item/weapon/stock_parts/capacitor = 2,
							/obj/item/weapon/stock_parts/console_screen = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/machinery/teleport/station/Initialize()
	..()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, dir))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, dir))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_icon()
		teleporter_hub = null
	if (teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(panel_open)
			M.buffer = src
			user << "<span class='caution'>You download the data to the [W.name]'s buffer.</span>"
		else
			if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
				if(linked_stations.len < efficiency)
					linked_stations.Add(M.buffer)
					M.buffer = null
					user << "<span class='caution'>You upload the data from the [W.name]'s buffer.</span>"
				else
					user << "<span class='alert'>This station can't hold more information, try to use better parts.</span>"
		return
	else if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_icon()
		return

	else if(exchange_parts(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return

	else if(istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			link_console_and_hub()
			user << "<span class='caution'>You reconnect the station to nearby machinery.</span>"
			return
	else
		return ..()

/obj/machinery/teleport/station/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/teleport/station/attack_hand(mob/user)
	if(!panel_open)
		toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console )
		return
	if (teleporter_console.target)
		if(teleporter_hub.panel_open || teleporter_hub.stat & (BROKEN|NOPOWER))
			visible_message("<span class='alert'>The teleporter hub isn't responding.</span>")
		else
			src.engaged = !src.engaged
			use_power(5000)
			visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	else
		visible_message("<span class='alert'>No target detected.</span>")
		src.engaged = 0
	teleporter_hub.update_icon()
	src.add_fingerprint(user)
	return

/obj/machinery/teleport/station/power_change()
	..()
	update_icon()
	if(teleporter_hub)
		teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(stat & (BROKEN|NOPOWER))
		icon_state = "controller-p"
	else
		icon_state = "controller"
