
/proc/debug_sources()
	GLOB.light_debug_enabled = TRUE
	var/list/sum = list()
	var/total = 0
	for(var/datum/light_source/source)
		source.debug()
		sum[source.source_atom.type] += 1
		total += 1

	sum = sortTim(sum, /proc/cmp_numeric_asc, TRUE)
	var/text = ""
	for(var/type in sum)
		text += "[type] = [sum[type]]\n"
	text += "total iterated: [total]"
	message_admins(text)

/proc/undebug_sources()
	GLOB.light_debug_enabled = FALSE
	for(var/datum/light_source/source)
		source.undebug()

/// Sets up this light source to be debugged, setting up in world buttons to control and move it
/// Also freezes it, so it can't change in future
/datum/light_source/proc/debug()
	if(QDELETED(src) || isturf(source_atom) || HAS_TRAIT(source_atom, TRAIT_LIGHTING_DEBUGGED))
		return
	ADD_TRAIT(source_atom, TRAIT_LIGHTING_DEBUGGED, REF(src))
	source_atom.add_filter("debug_light", 0, outline_filter(2, COLOR_CENTCOM_BLUE))
	var/static/uid = 0
	if(!source_atom.render_target)
		source_atom.render_target = "light_debug_[uid]"
		uid++
	var/atom/movable/render_step/color/above_light = new(null, source_atom, "#ffffff23")
	SET_PLANE_EXPLICIT(above_light, ABOVE_LIGHTING_PLANE, source_atom)
	source_atom.add_overlay(above_light)
	QDEL_NULL(above_light)
	var/atom/movable/lie_to_areas = source_atom
	// Freeze our light would you please
	source_atom.light_flags |= LIGHT_FROZEN
	lie_to_areas.vis_contents += new /atom/movable/screen/light_button/toggle(source_atom)
	lie_to_areas.vis_contents += new /atom/movable/screen/light_button/edit(source_atom)
	lie_to_areas.vis_contents += new /atom/movable/screen/light_button/move(source_atom)

/// Disables light debugging, so you can let a scene fall to what it visually should be, or just fix admin fuckups
/datum/light_source/proc/undebug()
	if(QDELETED(src) || isturf(source_atom) || !HAS_TRAIT(source_atom, TRAIT_LIGHTING_DEBUGGED))
		return
	REMOVE_TRAIT(source_atom, TRAIT_LIGHTING_DEBUGGED, REF(src))
	source_atom.remove_filter("debug_light")
	// Removes the glow overlay via stupid, sorry
	var/atom/movable/render_step/color/above_light = new(null, source_atom, "#ffffff23")
	SET_PLANE_EXPLICIT(above_light, ABOVE_LIGHTING_PLANE, source_atom)
	source_atom.cut_overlay(above_light)
	QDEL_NULL(above_light)
	var/atom/movable/lie_to_areas = source_atom
	// Freeze our light would you please
	source_atom.light_flags &= ~LIGHT_FROZEN
	for(var/atom/movable/screen/light_button/button in lie_to_areas.vis_contents)
		qdel(button)

/atom/movable/screen/light_button
	icon = 'icons/testing/lighting_debug.dmi'
	plane = HUD_PLANE
	alpha = 100
	var/datum/weakref/last_hovored_ref

/atom/movable/screen/light_button/Initialize(mapload)
	. = ..()
	layer = loc.layer
	RegisterSignal(loc, COMSIG_PARENT_QDELETING, PROC_REF(delete_self))

/atom/movable/screen/light_button/proc/delete_self(datum/source)
	SIGNAL_HANDLER
	qdel(src)

// Entered and Exited won't fire while you're dragging something, because you're still "holding" it
// Very much byond logic, but I want nice for my highlighting, so we fake it with drag
// Copypasta from action buttons
/atom/movable/screen/light_button/MouseDrag(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(IS_WEAKREF_OF(over_object, last_hovored_ref))
		return
	var/atom/old_object
	if(last_hovored_ref)
		old_object = last_hovored_ref?.resolve()
	else // If there's no current ref, we assume it was us. We also treat this as our "first go" location
		old_object = src

	if(old_object)
		old_object.MouseExited(over_location, over_control, params)

	last_hovored_ref = WEAKREF(over_object)
	over_object.MouseEntered(over_location, over_control, params)

/atom/movable/screen/light_button/MouseDrop(over_object)
	. = ..()
	last_hovored_ref = null

/atom/movable/screen/light_button/MouseEntered(location, control, params)
	. = ..()
	animate(src, alpha = 255, time = 2)

/atom/movable/screen/light_button/MouseExited(location, control, params)
	. = ..()
	animate(src, alpha = initial(alpha), time = 2)

/atom/movable/screen/light_button/toggle
	name = "Toggle Light"
	desc = "Click to turn the light on/off"
	icon_state = "light_enable"

/atom/movable/screen/light_button/toggle/Initialize(mapload)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_UPDATE_LIGHT_ON, PROC_REF(on_changed))
	update_appearance()

/atom/movable/screen/light_button/toggle/Click(location, control, params)
	. = ..()
	if(!check_rights_for(usr.client, R_DEBUG))
		return
	var/atom/movable/parent = loc
	var/old_light_flags = parent.light_flags
	parent.light_flags &= ~LIGHT_FROZEN
	loc.set_light(l_on = !loc.light_on)
	parent.light_flags = old_light_flags

/atom/movable/screen/light_button/toggle/proc/on_changed()
	SIGNAL_HANDLER
	update_appearance()

/atom/movable/screen/light_button/toggle/update_icon_state()
	. = ..()
	if(loc.light_on)
		icon_state = "light_enable"
	else
		icon_state = "light_disable"

/atom/movable/screen/light_button/edit
	name = "Edit Light"
	desc = "Click to open an editing menu for the light"
	icon_state = "light_focus"

/atom/movable/screen/light_button/edit/Click(location, control, params)
	. = ..()
	ui_interact(usr)

/atom/movable/screen/light_button/edit/ui_state(mob/user)
	return GLOB.debug_state

/atom/movable/screen/light_button/edit/can_interact()
	return TRUE

/atom/movable/screen/light_button/edit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LightController")
		ui.open()

/atom/movable/screen/light_button/edit/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/lights))

/atom/movable/screen/light_button/edit/ui_data()
	var/list/data = list()

	var/atom/parent = loc
	var/list/light_info = list()
	light_info["name"] = full_capitalize(parent.name)
	light_info["on"] = parent.light_on
	light_info["power"] = parent.light_power
	light_info["range"] = parent.light_range
	light_info["color"] = parent.light_color
	light_info["angle"] = parent.light_angle
	data["light_info"] = light_info
	data["on"] = parent.light_on
	data["direction"] = parent.dir

	return data

/atom/movable/screen/light_button/edit/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	data["templates"] = list()
	data["category_ids"] = list()
	for(var/id in GLOB.light_types)
		var/datum/light_template/template = GLOB.light_types[id]
		var/list/insert = list()
		var/list/light_info = list()
		light_info["name"] = template.name
		light_info["power"] = template.power
		light_info["range"] = template.range
		light_info["color"] = template.color
		light_info["angle"] = template.angle
		insert["light_info"] = light_info
		insert["description"] = template.desc
		insert["id"] = template.id
		insert["category"] = template.category
		if(!data["category_ids"][template.category])
			data["category_ids"][template.category] = list()
		data["category_ids"][template.category] += id
		data["templates"][template.id] = insert

	var/datum/light_template/first_template = GLOB.light_types[GLOB.light_types[1]]
	data["default_id"] = first_template.id
	data["default_category"] = first_template.category
	return data

/atom/movable/screen/light_button/edit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/atom/parent = loc
	var/old_light_flags = parent.light_flags
	parent.light_flags &= ~LIGHT_FROZEN
	switch(action)
		if("set_on")
			parent.set_light(l_on = params["value"])
		if("change_color")
			var/chosen_color = input(ui.user, "Pick new color", "[parent]", parent.light_color) as color|null
			if(chosen_color)
				parent.set_light(l_color = chosen_color)
		if("set_power")
			parent.set_light(l_power = params["value"])
		if("set_range")
			parent.set_light(l_range = params["value"])
		if("set_angle")
			// We use dir instead of light dir because anything directional should have its lightdir tied
			// And this way we can update the sprite too
			parent.set_light(l_angle = params["value"])
		if("set_dir")
			parent.setDir(params["value"])
		if("mirror_template")
			var/datum/light_template/template = GLOB.light_types[params["id"]]
			template.mirror_onto(parent)

	parent.light_flags = old_light_flags
	return TRUE

/atom/movable/screen/light_button/move
	name = "Move Light"
	desc = "Drag to move the light around"
	icon_state = "light_move"
	mouse_drag_pointer = 'icons/effects/mouse_pointers/light_drag.dmi'

/atom/movable/screen/light_button/move/MouseDrop(over_object)
	. = ..()
	if(!ismovable(loc))
		return
	var/atom/movable/movable_owner = loc
	movable_owner.forceMove(get_turf(over_object))
