/obj/machinery/gulag_item_reclaimer
	name = "equipment reclaimer station"
	desc = "Used to reclaim your items after you finish your sentence at the labor camp"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_taken"
	req_access = list(GLOB.access_security) //reqaccess to access all stored items
	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 100
	active_power_usage = 2500
	var/list/stored_items = list()
	var/obj/item/weapon/card/id/prisoner/inserted_id = null
	var/obj/machinery/gulag_teleporter/linked_teleporter = null

/obj/machinery/gulag_item_reclaimer/Destroy()
	for(var/i in contents)
		var/obj/item/I = i
		I.forceMove(get_turf(src))
	if(linked_teleporter)
		linked_teleporter.linked_reclaimer = null
	if(inserted_id)
		inserted_id.forceMove(get_turf(src))
		inserted_id = null
	return ..()

/obj/machinery/gulag_item_reclaimer/emag_act(mob/user)
	if(!emagged) // emagging lets anyone reclaim all the items
		req_access = list()
		emagged = 1

/obj/machinery/gulag_item_reclaimer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/id/prisoner))
		if(!inserted_id)
			if(!user.drop_item())
				return
			I.forceMove(src)
			inserted_id = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			return
		else
			to_chat(user, "<span class='notice'>There's an ID inserted already.</span>")
	return ..()

/obj/machinery/gulag_item_reclaimer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gulag_item_reclaimer", name, 455, 440, master_ui, state)
		ui.open()

/obj/machinery/gulag_item_reclaimer/ui_data(mob/user)
	var/list/data = list()
	var/can_reclaim = FALSE

	if(allowed(user))
		can_reclaim = TRUE

	if(inserted_id)
		data["id"] = inserted_id
		data["id_name"] = inserted_id.registered_name
		if(inserted_id.points >= inserted_id.goal)
			can_reclaim = TRUE

	var/list/mobs = list()
	for(var/i in stored_items)
		var/mob/thismob = i
		var/list/mob_info = list()
		mob_info["name"] = thismob.real_name
		mob_info["mob"] = "\ref[thismob]"
		mobs += list(mob_info)

	data["mobs"] = mobs


	data["can_reclaim"] = can_reclaim

	return data

/obj/machinery/gulag_item_reclaimer/ui_act(action, list/params)
	switch(action)
		if("handle_id")
			if(inserted_id)
				if(!usr.get_active_held_item())
					usr.put_in_hands(inserted_id)
					inserted_id = null
				else
					inserted_id.forceMove(get_turf(src))
					inserted_id = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if(istype(I, /obj/item/weapon/card/id/prisoner))
					if(!usr.drop_item())
						return
					I.forceMove(src)
					inserted_id = I
		if("release_items")
			var/mob/M = locate(params["mobref"])
			if(M == usr || allowed(usr))
				drop_items(M)
			else
				to_chat(usr, "Access denied.")

/obj/machinery/gulag_item_reclaimer/proc/drop_items(mob/user)
	if(!stored_items[user])
		return
	for(var/i in stored_items[user])
		var/obj/item/W = i
		stored_items[user] -= W
		W.forceMove(get_turf(src))
	stored_items -= user