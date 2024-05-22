/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/machines/teleporter.dmi'
	density = TRUE

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	base_icon_state = "tele"
	circuit = /obj/item/circuitboard/machine/teleporter_hub
	var/accuracy = 0
	var/obj/machinery/teleport/station/power_station
	var/calibrated = FALSE//Calibration prevents mutation

/obj/machinery/teleport/hub/Initialize(mapload)
	. = ..()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		power_station.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	. = ..()
	var/A = 0
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		A += matter_bin.tier
	accuracy = A

/obj/machinery/teleport/hub/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Probability of malfunction decreased by <b>[(accuracy*25)-25]%</b>.")

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(var/direction in GLOB.cardinals)
		power_station = locate(/obj/machinery/teleport/station, get_step(src, direction))
		if(power_station)
			power_station.link_console_and_hub()
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(atom/movable/AM)
	if(is_centcom_level(z))
		to_chat(AM, span_warning("You can't use this here!"))
		return
	if(is_ready())
		playsound(loc, "sound/effects/portal_travel.ogg", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		teleport(AM)

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		if(power_station?.engaged)
			power_station.engaged = 0 //hub with panel open is off, so the station must be informed.
			update_appearance()
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (QDELETED(com))
		return
	var/atom/target
	if(com.target_ref)
		target = com.target_ref.resolve()
	if (!target)
		com.target_ref = null
		visible_message(span_alert("Cannot authenticate locked on coordinates. Please reinstate coordinate matrix."))
		return
	if(!ismovable(M))
		return
	var/turf/start_turf = get_turf(M)
	if(!do_teleport(M, target, channel = TELEPORT_CHANNEL_BLUESPACE))
		return
	use_energy(active_power_usage)
	new /obj/effect/temp_visual/portal_animation(start_turf, src, M)
	if(!calibrated && ishuman(M) && prob(30 - ((accuracy) * 10))) //oh dear a problem
		var/mob/living/carbon/human/human = M
		if(!(human.mob_biotypes & (MOB_ROBOTIC|MOB_MINERAL|MOB_UNDEAD|MOB_SPIRIT)))
			var/datum/species/species_to_transform = /datum/species/fly
			if(check_holidays(MOTH_WEEK))
				species_to_transform = /datum/species/moth
			if(human.dna && human.dna.species.id != initial(species_to_transform.id))
				to_chat(M, span_hear("You hear a buzzing in your ears."))
				human.set_species(species_to_transform)
				human.log_message("was turned into a [initial(species_to_transform.name)] through [src].", LOG_GAME)
	calibrated = FALSE

/obj/machinery/teleport/hub/update_icon_state()
	icon_state = "[base_icon_state][panel_open ? "-o" : (is_ready() ? 1 : 0)]"
	return ..()

/obj/machinery/teleport/hub/proc/is_ready()
	. = !panel_open && !(machine_stat & (BROKEN|NOPOWER)) && power_station && power_station.engaged && !(power_station.machine_stat & (BROKEN|NOPOWER))

/obj/machinery/teleport/hub/syndicate/Initialize(mapload)
	. = ..()
	var/obj/item/stock_parts/matter_bin/super/super_bin = new(src)
	LAZYADD(component_parts, super_bin)
	RefreshParts()

/obj/machinery/teleport/station
	name = "teleporter station"
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	base_icon_state = "controller"
	circuit = /obj/item/circuitboard/machine/teleporter_station
	var/engaged = FALSE
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/Initialize(mapload)
	. = ..()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	. = ..()
	var/E
	for(var/datum/stock_part/capacitor/C in component_parts)
		E += C.tier
	efficiency = E - 1

/obj/machinery/teleport/station/examine(mob/user)
	. = ..()
	if(!panel_open)
		. += span_notice("The panel is <i>screwed</i> in, obstructing the linking device and wiring panel.")
	else
		. += span_notice("The <i>linking</i> device is now able to be <i>scanned</i> with a multitool.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: This station can be linked to <b>[efficiency]</b> other station(s).")

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(var/direction in GLOB.cardinals)
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, direction))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(var/direction in GLOB.cardinals)
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, direction))
		if(teleporter_console)
			teleporter_console.link_power_station()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_appearance()
		teleporter_hub = null
	if (teleporter_console)
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(panel_open)
			M.set_buffer(src)
			balloon_alert(user, "saved to multitool buffer")
		else
			if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
				if(linked_stations.len < efficiency)
					linked_stations.Add(M.buffer)
					M.set_buffer(null)
					balloon_alert(user, "data uploaded from buffer")
				else
					to_chat(user, span_alert("This station can't hold more information, try to use better parts."))
		return
	else if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_appearance()
		return

	else if(default_deconstruction_crowbar(W))
		return
	else
		return ..()

/obj/machinery/teleport/station/interact(mob/user)
	toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(machine_stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console )
		return
	if (teleporter_console.target_ref?.resolve())
		if(teleporter_hub.panel_open || teleporter_hub.machine_stat & (BROKEN|NOPOWER))
			to_chat(user, span_alert("The teleporter hub isn't responding."))
		else
			engaged = !engaged
			use_energy(active_power_usage)
			to_chat(user, span_notice("Teleporter [engaged ? "" : "dis"]engaged!"))
	else
		teleporter_console.target_ref = null
		to_chat(user, span_alert("No target detected."))
		engaged = FALSE
	teleporter_hub.update_appearance()
	add_fingerprint(user)

/obj/machinery/teleport/station/power_change()
	. = ..()
	if(teleporter_hub)
		teleporter_hub.update_appearance()

/obj/machinery/teleport/station/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]-o"
		return ..()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "[base_icon_state]-p"
		return ..()
	if(teleporter_console?.calibrating)
		icon_state = "[base_icon_state]-c"
		return ..()
	icon_state = base_icon_state
	return ..()
