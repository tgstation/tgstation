GLOBAL_LIST_INIT(live_teleporters, list())

/obj/item/mcobject/teleporter
	name = "teleporter component"
	base_icon_state = "comp_tele"
	icon_state = "comp_tele"

	COOLDOWN_DECLARE(teleporter_cooldown)
	var/teleID = "tele1"
	var/send_only = FALSE
	var/image/teleporter_light


/obj/item/mcobject/teleporter/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("activate", activate)
	MC_ADD_INPUT("setID", set_id_msg)
	MC_ADD_CONFIG("Set Teleporter ID", set_id)
	MC_ADD_CONFIG("Toggle Send Only", toggle_send_only)

	teleporter_light = image('goon/icons/obj/mechcomp.dmi', icon_state="telelight")
	teleporter_light.alpha = 200

	GLOB.live_teleporters += src

/obj/item/mcobject/teleporter/Destroy(force)
	. = ..()
	GLOB.live_teleporters -= src

/obj/item/mcobject/teleporter/proc/toggle_send_only()
	send_only = !send_only
	if(send_only)
		say("Will now only send targets!")
		return TRUE
	say("Will now send and recieve targets")
	return TRUE

/obj/item/mcobject/teleporter/proc/set_id_msg(datum/mcmessage/input)
	teleID = input.cmd
	say("Teleport ID Changed:[teleID]")
	return TRUE

/obj/item/mcobject/teleporter/proc/set_id(mob/user, obj/item/tool)
	var/idx = tgui_input_text(user, "Set index", "Configure Component", teleID)
	if(isnull(idx))
		return

	teleID = idx
	to_chat(span_notice("You set [src]'s id to [teleID]."))
	return TRUE

/obj/item/mcobject/teleporter/proc/activate()
	if(!COOLDOWN_FINISHED(src, teleporter_cooldown))
		return

	var/list/valid_teleport_locations = list()
	for(var/obj/item/mcobject/teleporter/live_teleporter in GLOB.live_teleporters)
		if(src == live_teleporter)
			continue
		if(!live_teleporter.anchored)
			continue
		if((live_teleporter.teleID != teleID) || live_teleporter.send_only || !are_zs_connected(src, live_teleporter))
			continue
		if(!COOLDOWN_FINISHED(live_teleporter, teleporter_cooldown))
			continue
		valid_teleport_locations.Add(live_teleporter)

	if(length(valid_teleport_locations))
		var/obj/item/mcobject/teleporter/picked = pick(valid_teleport_locations)
		show_effect()
		picked.show_effect()
		for(var/atom/movable/movable_atom in src.loc)
			if(src == movable_atom)
				continue
			if(movable_atom.anchored)
				continue
			do_teleport(movable_atom, get_turf(picked), no_effects = TRUE)
		COOLDOWN_START(src, teleporter_cooldown, 5 SECONDS)
		COOLDOWN_START(picked, teleporter_cooldown, 5 SECONDS)
		return TRUE
	return

/obj/item/mcobject/teleporter/proc/show_effect()
	addtimer(CALLBACK(src, PROC_REF(hide_effect)), 5 SECONDS)
	flick("ucomp_tele1", src)
	src.vis_contents += teleporter_light

/obj/item/mcobject/teleporter/proc/hide_effect()
	src.vis_contents -= teleporter_light
