// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "navbeacon0"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	layer = LOW_OBJ_LAYER
	max_integrity = 500
	armor_type = /datum/armor/machinery_navbeacon
	circuit = /obj/item/circuitboard/machine/navbeacon

	/// true if controls are locked
	var/controls_locked = TRUE
	/// true if cover is locked
	var/cover_locked = TRUE
	/// location response text
	var/location = ""
	/// original location name, to allow resets
	var/original_location = ""
	/// associative list of transponder codes
	var/list/codes
	/// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"
	var/codes_txt = ""

	req_one_access = list(ACCESS_ENGINEERING, ACCESS_ROBOTICS)

/datum/armor/machinery_navbeacon
	melee = 70
	bullet = 70
	laser = 70
	energy = 70
	fire = 80
	acid = 80

/obj/machinery/navbeacon/Initialize(mapload)
	. = ..()

	original_location = location

	set_codes()

	glob_lists_register(init=TRUE)

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

/obj/machinery/navbeacon/Destroy()
	glob_lists_deregister()
	return ..()

/obj/machinery/navbeacon/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if (GLOB.navbeacons["[old_turf?.z]"])
		GLOB.navbeacons["[old_turf?.z]"] -= src
	if (GLOB.navbeacons["[new_turf?.z]"])
		GLOB.navbeacons["[new_turf?.z]"] += src
	return ..()

/obj/machinery/navbeacon/on_construction(mob/user)
	var/turf/our_turf = loc
	if(!isfloorturf(our_turf))
		return
	var/turf/open/floor/floor = our_turf
	floor.remove_tile(null, silent = TRUE, make_tile = TRUE, force_plating = TRUE)


///Set the transponder codes assoc list from codes_txt during initialization, or during reset
/obj/machinery/navbeacon/proc/set_codes()

	codes = list()

	if(!codes_txt)
		return

	var/list/entries = splittext(codes_txt, ";") // entries are separated by semicolons

	for(var/entry in entries)
		var/index = findtext(entry, "=") // format is "key=value"
		if(index)
			var/key = copytext(entry, 1, index)
			var/val = copytext(entry, index + length(entry[index]))
			codes[key] = val
		else
			codes[entry] = "[TRUE]"

///Removes the nav beacon from the global beacon lists
/obj/machinery/navbeacon/proc/glob_lists_deregister()
	if (GLOB.navbeacons["[z]"])
		GLOB.navbeacons["[z]"] -= src //Remove from beacon list, if in one.
	GLOB.deliverybeacons -= src
	GLOB.deliverybeacontags -= location

///Registers the navbeacon to the global beacon lists
/obj/machinery/navbeacon/proc/glob_lists_register(init=FALSE)
	if(!init)
		glob_lists_deregister()
	if(!codes)
		return
	if(codes[NAVBEACON_PATROL_MODE])
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if(codes[NAVBEACON_DELIVERY_MODE])
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/navbeacon/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/tool)
	if(!panel_open && cover_locked)
		balloon_alert(user, "hatch locked!")
		return TRUE
	return default_deconstruction_screwdriver(user, "navbeacon1","navbeacon0",tool)

/obj/machinery/navbeacon/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/turf/our_turf = loc
	if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	if (attacking_item.GetID())
		if(!panel_open)
			if (allowed(user))
				controls_locked = !controls_locked
				balloon_alert(user, "controls [controls_locked ? "locked" : "unlocked"]")
				SStgui.update_uis(src)
			else
				balloon_alert(user, "access denied")
		else
			balloon_alert(user, "panel open!")
		return

	return ..()

/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user)

/obj/machinery/navbeacon/attack_paw(mob/user, list/modifiers)
	return

/obj/machinery/navbeacon/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	var/turf/our_turf = loc
	if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NavBeacon")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/navbeacon/ui_data(mob/user)
	var/list/data = list()
	var/list/controls = list()

	controls["location"] = location
	controls["patrol_enabled"] = codes[NAVBEACON_PATROL_MODE] ? TRUE : FALSE
	controls["patrol_next"] = codes[NAVBEACON_PATROL_NEXT]
	controls["delivery_enabled"] = codes[NAVBEACON_DELIVERY_MODE] ? TRUE : FALSE
	controls["delivery_direction"] = dir2text(text2num(codes[NAVBEACON_DELIVERY_DIRECTION]))
	controls["cover_locked"] = cover_locked

	data["locked"] = controls_locked
	data["siliconUser"] = HAS_SILICON_ACCESS(user)
	data["controls"] = controls

	return data

/obj/machinery/navbeacon/ui_static_data(mob/user)
	var/list/data = list()
	var/list/static_controls = list()
	var/static/list/direction_options = list("none", dir2text(EAST), dir2text(NORTH), dir2text(SOUTH), dir2text(WEST))

	static_controls["direction_options"] = direction_options
	static_controls["has_codes"] = codes_txt ? TRUE : FALSE

	data["static_controls"] = static_controls
	return data

/obj/machinery/navbeacon/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user

	if(action == "lock" && allowed(user))
		controls_locked = !controls_locked
		return TRUE

	if(controls_locked && !HAS_SILICON_ACCESS(user))
		return

	switch(action)
		if("reset_codes")
			glob_lists_deregister()
			location = original_location
			set_codes()
			glob_lists_register()
			return TRUE
		if("toggle_cover")
			cover_locked = !cover_locked
			return TRUE
		if("toggle_patrol")
			toggle_code(NAVBEACON_PATROL_MODE)
			return TRUE
		if("toggle_delivery")
			toggle_code(NAVBEACON_DELIVERY_MODE)
			return TRUE
		if("set_location")
			var/input_text = tgui_input_text(user, "Enter the beacon's location tag", "Beacon Location", location, max_length = 20)
			if (!input_text || location == input_text)
				return
			glob_lists_deregister()
			location = input_text
			glob_lists_register()
			return TRUE
		if("set_patrol_next")
			var/next_patrol = codes[NAVBEACON_PATROL_NEXT]
			var/input_text = tgui_input_text(user, "Enter the tag of the next patrol location", "Beacon Location", next_patrol, max_length = 20)
			if (!input_text || location == input_text)
				return
			codes[NAVBEACON_PATROL_NEXT] = input_text
			return TRUE
		if("set_delivery_direction")
			codes[NAVBEACON_DELIVERY_DIRECTION] = "[text2dir(params["direction"])]"
			return TRUE

///Adds or removes a specific code
/obj/machinery/navbeacon/proc/toggle_code(code)
	if(codes[code])
		codes.Remove(code)
	else
		codes[code]="[TRUE]"
	glob_lists_register()
