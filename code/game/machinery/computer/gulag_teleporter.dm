//computer that handle the points and teleports the prisoner
/obj/machinery/computer/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp"
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(access_security)
	circuit = /obj/item/weapon/circuitboard/computer/gulag_teleporter_console
	var/default_goal = 200
	var/obj/item/weapon/card/id/prisoner/id = null
	var/obj/machinery/gulag_teleporter/teleporter = null
	var/obj/structure/gulag_beacon/beacon = null
	var/mob/living/carbon/human/prisoner = null
	var/datum/data/record/temporary_record = null

/obj/machinery/computer/gulag_teleporter_computer/New()
	..()
	addtimer(src, "scan_machinery", 5)

/obj/machinery/computer/gulag_teleporter_computer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id/prisoner))
		if(!id)
			if(!user.drop_item())
				return
			W.loc = src
			id = W
			user << "<span class='notice'>You insert [W].</span>"
			return
		else
			user << "<span class='notice'>There's an ID inserted already.</span>"
	return ..()

/obj/machinery/computer/gulag_teleporter_computer/proc/equip_id()
	if(id && prisoner)
		prisoner.equip_to_appropriate_slot(id)
		id = null

/obj/machinery/computer/gulag_teleporter_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gulag_console", name, 455, 430, master_ui, state)
		ui.open()

/obj/machinery/computer/gulag_teleporter_computer/ui_data(mob/user)
	var/list/data = list()

	var/list/prisoner_list = list()
	var/can_teleport = FALSE

	if(teleporter && (teleporter.occupant && ishuman(teleporter.occupant)))
		prisoner = teleporter.occupant
		prisoner_list["name"] = prisoner.name
		if(id)
			can_teleport = TRUE
		if(!isnull(data_core.general))
			for(var/r in data_core.security)
				var/datum/data/record/R = r
				if(R.fields["name"] == prisoner_list["name"])
					temporary_record = R
					prisoner_list["crimstat"] = temporary_record.fields["criminal"]

	data["prisoner"] = prisoner_list

	if(teleporter)
		data["teleporter"] = teleporter
		data["teleporter_location"] = "([teleporter.x], [teleporter.y], [teleporter.z])"
		data["teleporter_lock"] = teleporter.locked
	if(beacon)
		data["beacon"] = beacon
		data["beacon_location"] = "([beacon.x], [beacon.y], [beacon.z])"
	if(id)
		data["id"] = id
		data["id_name"] = id.registered_name
		data["goal"] = id.goal
	data["can_teleport"] = can_teleport

	return data

/obj/machinery/computer/gulag_teleporter_computer/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("scan_teleporter")
			teleporter = findteleporter()
		if("scan_beacon")
			beacon = findbeacon()
		if("handle_id")
			if(id)
				if(!usr.get_active_hand())
					usr.put_in_hands(id)
					id = null
				else
					id.loc = get_turf(src)
					id = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id/prisoner))
					if(!usr.drop_item())
						return
					I.loc = src
					id = I
		if("set_goal")
			var/new_goal = input("Set the amount of points:", "Points", id.goal) as num|null
			if(!isnum(new_goal))
				return
			if(!new_goal)
				new_goal = default_goal
			id.goal = Clamp(new_goal, 0, 1000) //maximum 1000 points
		if("teleporter_lock")
			teleporter.locked = !teleporter.locked
		if("teleport")
			if(!(teleporter && beacon))
				return
			teleport()

/obj/machinery/computer/gulag_teleporter_computer/proc/scan_machinery()
	teleporter = findteleporter()
	beacon = findbeacon()

/obj/machinery/computer/gulag_teleporter_computer/proc/findteleporter()
	var/obj/machinery/gulag_teleporter/teleporterf = null

	for(dir in cardinal)
		teleporterf = locate(/obj/machinery/gulag_teleporter, get_step(src, dir))
		if(teleporterf && teleporterf.is_operational())
			return teleporterf

/obj/machinery/computer/gulag_teleporter_computer/proc/findbeacon()
	return locate(/obj/structure/gulag_beacon)

/obj/machinery/computer/gulag_teleporter_computer/proc/teleport()
	teleporter.handle_prisoner(id, temporary_record)
	prisoner.loc = get_turf(beacon)
	prisoner.Weaken(2) // small travel dizziness
	teleporter.toggle_open()
	id = null
	temporary_record = null