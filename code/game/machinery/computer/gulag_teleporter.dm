//computer that handle the points and teleports the prisoner
/obj/machinery/computer/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/computer/gulag_teleporter_console
	var/default_goal = 200
	var/obj/item/card/id/prisoner/id = null
	var/obj/machinery/gulag_teleporter/teleporter = null
	var/obj/structure/gulag_beacon/beacon = null
	var/mob/living/carbon/human/prisoner = null
	var/datum/data/record/temporary_record = null

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/gulag_teleporter_computer/Initialize()
	. = ..()
	scan_machinery()

/obj/machinery/computer/gulag_teleporter_computer/Destroy()
	if(id)
		id.forceMove(get_turf(src))
	return ..()

/obj/machinery/computer/gulag_teleporter_computer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/card/id/prisoner))
		if(!id)
			if (!user.transferItemToLoc(W,src))
				return
			id = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
			return
		else
			to_chat(user, "<span class='notice'>There's an ID inserted already.</span>")
	return ..()

/obj/machinery/computer/gulag_teleporter_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gulag_console", name, 455, 440, master_ui, state)
		ui.open()

/obj/machinery/computer/gulag_teleporter_computer/ui_data(mob/user)
	var/list/data = list()

	var/list/prisoner_list = list()
	var/can_teleport = FALSE

	if(teleporter && (teleporter.occupant && ishuman(teleporter.occupant)))
		prisoner = teleporter.occupant
		prisoner_list["name"] = prisoner.real_name
		if(id)
			can_teleport = TRUE
		if(!isnull(GLOB.data_core.general))
			for(var/r in GLOB.data_core.security)
				var/datum/data/record/R = r
				if(R.fields["name"] == prisoner_list["name"])
					temporary_record = R
					prisoner_list["crimstat"] = temporary_record.fields["criminal"]

	data["prisoner"] = prisoner_list

	if(teleporter)
		data["teleporter"] = teleporter
		data["teleporter_location"] = "([teleporter.x], [teleporter.y], [teleporter.z])"
		data["teleporter_lock"] = teleporter.locked
		data["teleporter_state_open"] = teleporter.state_open
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
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("scan_teleporter")
			teleporter = findteleporter()
		if("scan_beacon")
			beacon = findbeacon()
		if("handle_id")
			if(id)
				usr.put_in_hands(id)
				id = null
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/card/id/prisoner)
				if(I)
					if(!usr.transferItemToLoc(I, src))
						return
					id = I
		if("set_goal")
			var/new_goal = input("Set the amount of points:", "Points", id.goal) as num|null
			if(!isnum(new_goal))
				return
			if(!new_goal)
				new_goal = default_goal
			if (new_goal > 1000)
				to_chat(usr, "The entered amount of points is too large. Points have instead been set to the maximum allowed amount.")
			id.goal = CLAMP(new_goal, 0, 1000) //maximum 1000 points
		if("toggle_open")
			if(teleporter.locked)
				to_chat(usr, "The teleporter is locked")
				return
			teleporter.toggle_open()
		if("teleporter_lock")
			if(teleporter.state_open)
				to_chat(usr, "Close the teleporter before locking!")
				return
			teleporter.locked = !teleporter.locked
		if("teleport")
			if(!teleporter || !beacon)
				return
			addtimer(CALLBACK(src, .proc/teleport, usr), 5)

/obj/machinery/computer/gulag_teleporter_computer/proc/scan_machinery()
	teleporter = findteleporter()
	beacon = findbeacon()

/obj/machinery/computer/gulag_teleporter_computer/proc/findteleporter()
	var/obj/machinery/gulag_teleporter/teleporterf = null

	for(var/direction in GLOB.cardinals)
		teleporterf = locate(/obj/machinery/gulag_teleporter, get_step(src, direction))
		if(teleporterf && teleporterf.is_operational())
			return teleporterf

/obj/machinery/computer/gulag_teleporter_computer/proc/findbeacon()
	return locate(/obj/structure/gulag_beacon)

/obj/machinery/computer/gulag_teleporter_computer/proc/teleport(mob/user)
	if(!id) //incase the ID was removed after the transfer timer was set.
		say("Warning: Unable to transfer prisoner without a valid Prisoner ID inserted!")
		return
	var/id_goal_not_set
	if(!id.goal)
		id_goal_not_set = TRUE
		id.goal = default_goal
		say("[id]'s ID card goal defaulting to [id.goal] points.")
	log_game("[key_name(user)] teleported [key_name(prisoner)] to the Labor Camp [COORD(beacon)] for [id_goal_not_set ? "default goal of ":""][id.goal] points.")
	teleporter.handle_prisoner(id, temporary_record)
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	prisoner.forceMove(get_turf(beacon))
	prisoner.Paralyze(40) // small travel dizziness
	to_chat(prisoner, "<span class='warning'>The teleportation makes you a little dizzy.</span>")
	new /obj/effect/particle_effect/sparks(get_turf(prisoner))
	playsound(src, "sparks", 50, 1)
	if(teleporter.locked)
		teleporter.locked = FALSE
	teleporter.toggle_open()
	id = null
	temporary_record = null
