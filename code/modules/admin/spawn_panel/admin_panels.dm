#define WHERE_FLOOR_BELOW_MOB "Current location"
#define WHERE_SUPPLY_BELOW_MOB "Current location (droppod)"
#define WHERE_MOB_HAND "In own mob's hand"
#define WHERE_MARKED_OBJECT "At a marked object"

#define WHERE_TARGETED_LOCATION "Targeted location"
#define WHERE_TARGETED_LOCATION_POD "Targeted location (droppod)"
#define WHERE_TARGETED_MOB_HAND "In targeted mob's hand"

#define PRECISE_MODE_OFF "Off"
#define PRECISE_MODE_TARGET "Target"
#define PRECISE_MODE_MARK "Mark"
#define PRECISE_MODE_COPY "Copy"

#define OFFSET_ABSOLUTE "Absolute offset"
#define OFFSET_RELATIVE "Relative offset"

ADMIN_VERB(spawn_panel, R_SPAWN, "Spawn Panel", "Spawn Panel (TGUI).", ADMIN_CATEGORY_GAME)
	var/static/datum/spawnpanel/ui = new
	ui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Spawn Panel")

/datum/spawnpanel
	var/where_dropdown_value = WHERE_FLOOR_BELOW_MOB
	var/selected_object = ""
	var/copied_type = null
	var/selected_object_icon = null
	var/selected_object_icon_state = null
	var/custom_icon = null
	var/custom_icon_state = null
	var/custom_icon_size = 100
	var/list/available_icon_states = null
	var/object_count = 1
	var/object_name
	var/object_desc
	var/dir = 1
	var/offset = ""
	var/offset_type = "relative"
	var/precise_mode = FALSE

/datum/spawnpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnPanel")
		ui.open()

/datum/spawnpanel/ui_close(mob/user)
	. = ..()
	if (precise_mode && precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)

/datum/spawnpanel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/spawnpanel/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pick-icon")
			var/icon/new_icon = input("Select a new icon file:", "Icon") as null|icon
			if(new_icon)
				custom_icon = new_icon
				available_icon_states = icon_states(custom_icon)
				return TRUE
		if("reset-icon")
			custom_icon = null
			custom_icon_state = null
			if(selected_object)
				var/path = text2path(selected_object)
				if(path)
					var/atom/temp = path
					selected_object_icon = initial(temp.icon)
					selected_object_icon_state = initial(temp.icon_state)
					available_icon_states = icon_states(selected_object_icon)
			return TRUE
		if("pick-icon-state")
			custom_icon_state = params["new_state"]
			return TRUE
		if("reset-icon-state")
			custom_icon_state = null
			if(selected_object)
				var/path = text2path(selected_object)
				if(path)
					var/atom/temp = path
					selected_object_icon_state = initial(temp.icon_state)
			return TRUE
		if("set-icon-size")
			custom_icon_size = params["size"]
			return TRUE
		if("reset-icon-size")
			custom_icon_size = 100
			return TRUE
		if("get-icon-states")
			var/icon_to_use = custom_icon || selected_object_icon
			if(icon_to_use)
				available_icon_states = icon_states(icon_to_use)
			return TRUE
		if("selected-object-changed")
			selected_object = params?["newObj"]
			if(selected_object)
				var/path = text2path(selected_object)
				if(path)
					var/atom/temp = path
					selected_object_icon = initial(temp.icon)
					selected_object_icon_state = initial(temp.icon_state)
					if(!custom_icon)
						available_icon_states = icon_states(selected_object_icon)
			return TRUE
		if("create-object-action")
			spawn_item(list(
				object_list = selected_object,
				object_count = text2num(params["object_count"]) || 1,
				offset = params["offset"],
				object_dir = text2num(params["dir"]) || 1,
				object_name = params["object_name"],
				object_where = params["where_dropdown_value"] || WHERE_FLOOR_BELOW_MOB,
				offset_type = params["offset_type"] || OFFSET_RELATIVE,
				custom_icon = params["custom_icon"],
				custom_icon_state = params["custom_icon_state"],
				custom_icon_size = params["custom_icon_size"]
				),
				usr
			)
		if("toggle-precise-mode")
			var/precise_type = params["newPreciseType"]
			if(precise_type == PRECISE_MODE_TARGET && params["where_dropdown_value"])
				where_dropdown_value = params["where_dropdown_value"]
			toggle_precise_mode(precise_type)
			return TRUE
		if("update-settings")
			if(params["object_count"])
				object_count = text2num(params["object_count"])
			if(params["dir"])
				dir = text2num(params["dir"])
			if(params["offset"])
				offset = params["offset"]
			if(params["object_name"])
				object_name = params["object_name"]
			if(params["where_dropdown_value"])
				where_dropdown_value = params["where_dropdown_value"]
			if(params["offset_type"])
				offset_type = params["offset_type"]
			return TRUE

/datum/spawnpanel/proc/toggle_precise_mode(precise_type)
	precise_mode = precise_type
	var/client/admin_client = usr.client
	if (!admin_client)
		return

	admin_client.mouse_up_icon = null
	admin_client.mouse_down_icon = null
	admin_client.mouse_override_icon = null
	admin_client.click_intercept = null

	if (precise_mode != PRECISE_MODE_OFF)
		admin_client.mouse_up_icon = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'
		admin_client.mouse_down_icon = 'icons/effects/mouse_pointers/supplypod_pickturf_down.dmi'
		admin_client.mouse_override_icon = admin_client.mouse_up_icon
		admin_client.mouse_pointer_icon = admin_client.mouse_override_icon
		admin_client.click_intercept = src

		winset(admin_client, "mapwindow.map", "right-click=true")
	else
		winset(admin_client, "mapwindow.map", "right-click=false")

	var/mob/holder_mob = admin_client.mob
	holder_mob?.update_mouse_pointer()

/datum/spawnpanel/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)

	if(right_click)
		toggle_precise_mode(PRECISE_MODE_OFF)
		SStgui.update_uis(src)
		return TRUE

	if(left_click)
		if(istype(target,/atom/movable/screen))
			return FALSE

		var/turf/clicked_turf = get_turf(target)
		if(!clicked_turf)
			return FALSE

		switch(precise_mode)
			if(PRECISE_MODE_TARGET)
				var/list/spawn_params = list(
					"object_list" = selected_object,
					"object_count" = object_count,
					"offset" = "0,0,0",
					"object_dir" = dir,
					"object_name" = object_name,
					"object_desc" = object_desc,
					"offset_type" = OFFSET_ABSOLUTE,
					"object_where" = where_dropdown_value,
					"object_reference" = target,
					"object_icon" = null,
					"object_icon_state" = null,
					"object_icon_size" = null
				)

				if(where_dropdown_value == WHERE_TARGETED_LOCATION || where_dropdown_value == WHERE_TARGETED_LOCATION_POD)
					spawn_params["X"] = clicked_turf.x
					spawn_params["Y"] = clicked_turf.y
					spawn_params["Z"] = clicked_turf.z

				spawn_item(spawn_params, user)

			if(PRECISE_MODE_MARK)
				var/client/admin_client = user.client
				admin_client.mark_datum(target)
				to_chat(user, span_notice("Marked object: [icon2html(target, user)] [span_bold("[target]")]"))
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

			if(PRECISE_MODE_COPY)
				var/target_type = target.type
				to_chat(user, span_notice("Picked object: [icon2html(target, user)] [span_bold("[target]")]"))
				copied_type = "[target_type]"
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

		return TRUE

/datum/spawnpanel/ui_data(mob/user)
	var/data = list()
	data["icon"] = custom_icon || selected_object_icon
	data["iconState"] = custom_icon_state || selected_object_icon_state
	data["iconSize"] = custom_icon_size
	var/list/states = list()
	if(available_icon_states)
		for(var/state in available_icon_states)
			states += state
	data["iconStates"] = states
	data["precise_mode"] = precise_mode
	data["selected_object"] = selected_object
	data["copied_type"] = copied_type
	return data

/datum/spawnpanel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawnpanel),
	)

/datum/spawnpanel/proc/spawn_item(list/spawn_params, mob/user)
	if(!check_rights(R_SPAWN) || !spawn_params)
		return

	var/path = text2path(spawn_params["object_list"])

	if(!path || (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob)))
		return

	var/amount = clamp(text2num(spawn_params["object_count"]), 1, ADMIN_SPAWN_CAP)

	var/offset_raw = spawn_params["offset"]
	var/list/offset = splittext(offset_raw, ",")
	var/X = 0
	var/Y = 0
	var/Z = 0

	if(spawn_params["X"] && spawn_params["Y"] && spawn_params["Z"])
		X = spawn_params["X"]
		Y = spawn_params["Y"]
		Z = spawn_params["Z"]
	else
		if(offset.len > 0)
			X = text2num(offset[1]) || 0

		if(offset.len > 1)
			Y = text2num(offset[2]) || 0

		if(offset.len > 2)
			Z = text2num(offset[3]) || 0

	var/obj_dir = text2num(spawn_params["object_dir"]) || 1
	var/atom_name = sanitize(spawn_params["object_name"])
	var/where = spawn_params["object_where"]
	var/atom/target

	if(where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND)
		var/atom/target_reference
		switch(where)
			if(WHERE_TARGETED_MOB_HAND)
				target_reference = spawn_params["object_reference"]

			if(WHERE_MOB_HAND)
				target_reference = user

		if(!target_reference)
			to_chat(user, span_warning("No target reference provided."))
			return

		if(!ismob(target_reference))
			to_chat(user, span_warning("The targeted atom is not a mob."))
			return

		if(!iscarbon(target_reference) && !iscyborg(target_reference))
			to_chat(user, span_warning("Can only spawn in hand when the target is a carbon mob or cyborg."))
			where = WHERE_FLOOR_BELOW_MOB
		target = target_reference

	else if(where == WHERE_MARKED_OBJECT)
		if(!user.client.holder.marked_datum)
			to_chat(user, span_warning("You don't have any object marked."))
			return
		else if(!istype(user.client.holder.marked_datum, /atom))
			to_chat(user, span_warning("The object you have marked cannot be used as a target. Target must be of type /atom."))
			return
		else
			target = get_turf(user.client.holder.marked_datum)

	else
		switch(spawn_params["offset_type"])
			if(OFFSET_ABSOLUTE)
				target = locate(X, Y, Z)

			if(OFFSET_RELATIVE)
				var/turf/relative_turf
				var/atom/user_loc = user.loc

				if (user_loc)
					relative_turf = get_turf(user_loc)

				if (!relative_turf)
					if(isobserver(user))
						var/mob/dead/observer/user_observer = user
						relative_turf = get_turf(user_observer.client?.eye) || get_turf(user_observer)
					if (!relative_turf)
						relative_turf = locate(1, 1, 1)

				if (!relative_turf)
					to_chat(user, span_warning("Could not determine a valid relative location."))
					return

				target = locate(relative_turf.x + X, relative_turf.y + Y, relative_turf.z + Z)

	if(!target)
		return

	var/use_droppod = where == WHERE_SUPPLY_BELOW_MOB || where == WHERE_TARGETED_LOCATION_POD

	var/obj/structure/closet/supplypod/centcompod/pod
	if(use_droppod)
		pod = new()

	for(var/i in 1 to amount)
		if(ispath(path, /turf))
			var/turf/original_turf = target
			var/turf/created_turf = original_turf.ChangeTurf(path)
			if(created_turf && atom_name)
				created_turf.name = atom_name
			continue

		var/atom/created_atom

		if(use_droppod)
			created_atom = new path(pod)
		else
			created_atom = new path(target)

		if(QDELETED(created_atom))
			return

		created_atom.flags_1 |= ADMIN_SPAWNED_1

		if(spawn_params["custom_icon"])
			created_atom.icon = spawn_params["custom_icon"]
		if(spawn_params["custom_icon_state"])
			created_atom.icon_state = spawn_params["custom_icon_state"]
		if(spawn_params["custom_icon_size"])
			if(ismob(created_atom))
				var/mob/living/created_mob = created_atom
				created_mob.current_size = spawn_params["custom_icon_size"] / 100

		if(obj_dir)
			created_atom.setDir(obj_dir)

		if(atom_name)
			created_atom.name = atom_name
			if(ismob(created_atom))
				var/mob/created_mob = created_atom
				created_mob.real_name = atom_name

		if((where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND) && isliving(target) && isitem(created_atom))
			var/mob/living/living_target = target
			var/obj/item/created_item = created_atom
			living_target.put_in_hands(created_item)

			if(iscyborg(living_target))
				var/mob/living/silicon/robot/target_robot = living_target
				if(target_robot.model)
					target_robot.model.add_module(created_item, TRUE, TRUE)
					target_robot.activate_module(created_item)

	if(pod)
		new /obj/effect/pod_landingzone(target, pod)

	log_admin("[key_name(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [path]")
	if(ispath(path, /mob))
		message_admins("[key_name_admin(user)] created [amount == 1 ? "an instance" : "[amount] instances"] of [path]")

#undef WHERE_FLOOR_BELOW_MOB
#undef WHERE_SUPPLY_BELOW_MOB
#undef WHERE_MOB_HAND
#undef WHERE_MARKED_OBJECT
#undef WHERE_TARGETED_LOCATION
#undef WHERE_TARGETED_LOCATION_POD
#undef WHERE_TARGETED_MOB_HAND
#undef PRECISE_MODE_OFF
#undef PRECISE_MODE_TARGET
#undef PRECISE_MODE_MARK
#undef PRECISE_MODE_COPY
#undef OFFSET_ABSOLUTE
#undef OFFSET_RELATIVE
