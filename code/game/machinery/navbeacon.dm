// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	base_icon_state = "navbeacon"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	layer = LOW_OBJ_LAYER
	max_integrity = 500
	armor = list(MELEE = 70, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)

	var/open = FALSE // true if cover is open
	var/locked = TRUE // true if controls are locked
	var/freq = FREQ_NAV_BEACON
	var/location = "" // location response text
	var/list/codes // assoc. list of transponder codes
	var/codes_txt = "" // codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_one_access = list(ACCESS_ENGINEERING, ACCESS_ROBOTICS)

/obj/machinery/navbeacon/Initialize(mapload)
	. = ..()

	set_codes()

	glob_lists_register(init=TRUE)

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

/obj/machinery/navbeacon/Destroy()
	glob_lists_deregister()
	return ..()

/obj/machinery/navbeacon/on_changed_z_level(turf/old_turf, turf/new_turf)
	if (GLOB.navbeacons["[old_turf?.z]"])
		GLOB.navbeacons["[old_turf?.z]"] -= src
	if (GLOB.navbeacons["[new_turf?.z]"])
		GLOB.navbeacons["[new_turf?.z]"] += src
	..()

// set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = new()

	var/list/entries = splittext(codes_txt, ";") // entries are separated by semicolons

	for(var/e in entries)
		var/index = findtext(e, "=") // format is "key=value"
		if(index)
			var/key = copytext(e, 1, index)
			var/val = copytext(e, index + length(e[index]))
			codes[key] = val
		else
			codes[e] = "1"

/obj/machinery/navbeacon/proc/glob_lists_deregister()
	if (GLOB.navbeacons["[z]"])
		GLOB.navbeacons["[z]"] -= src //Remove from beacon list, if in one.
	GLOB.deliverybeacons -= src
	GLOB.deliverybeacontags -= location

/obj/machinery/navbeacon/proc/glob_lists_register(init=FALSE)
	if(!init)
		glob_lists_deregister()
	if(!codes)
		return
	if(codes["patrol"])
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if(codes["delivery"])
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

// update the icon_state
/obj/machinery/navbeacon/update_icon_state()
	icon_state = "[base_icon_state][open]"
	return ..()

/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	open = !open
	user.visible_message(span_notice("[user] [open ? "opens" : "closes"] the beacon's cover."), span_notice("You [open ? "open" : "close"] the beacon's cover."))
	update_appearance()
	tool.play_tool_sound(src, 50)
	return TRUE

/obj/machinery/navbeacon/attackby(obj/item/I, mob/user, params)
	var/turf/T = loc
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	else if (istype(I, /obj/item/card/id) || istype(I, /obj/item/modular_computer/tablet))
		if(open)
			if (src.allowed(user))
				src.locked = !src.locked
				to_chat(user, span_notice("Controls are now [src.locked ? "locked" : "unlocked"]."))
			else
				to_chat(user, span_danger("Access denied."))
			updateDialog()
		else
			to_chat(user, span_warning("You must open the cover first!"))
	else
		return ..()

/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user, 1)

/obj/machinery/navbeacon/attack_paw(mob/user, list/modifiers)
	return

/obj/machinery/navbeacon/ui_interact(mob/user)
	. = ..()
	var/ai = isAI(user)
	var/turf/T = loc
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	if(!open && !ai) // can't alter controls if not open, unless you're an AI
		to_chat(user, span_warning("The beacon's control cover is closed!"))
		return


	var/t

	if(locked && !ai)
		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
		t+= "<UL></TT>"

	else

		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>

<HR>
Location: <A href='byond://?src=[REF(src)];locedit=1'>[location ? location : "None"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
			t += " <A href='byond://?src=[REF(src)];edit=1;code=[key]'>Edit</A>"
			t += " <A href='byond://?src=[REF(src)];delete=1;code=[key]'>Delete</A><BR>"
		t += " <A href='byond://?src=[REF(src)];add=1;'>Add New</A><BR>"
		t+= "<UL></TT>"

	var/datum/browser/popup = new(user, "navbeacon", "Navigation Beacon", 300, 400)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/navbeacon/Topic(href, href_list)
	if(..())
		return
	if(open && !locked)
		usr.set_machine(src)

		if(href_list["locedit"])
			var/newloc = stripped_input(usr, "Enter New Location", "Navigation Beacon", location, MAX_MESSAGE_LEN)
			if(newloc)
				location = newloc
				glob_lists_register()
				updateDialog()

		else if(href_list["edit"])
			var/codekey = href_list["code"]

			var/newkey = stripped_input(usr, "Enter Transponder Code Key", "Navigation Beacon", codekey)
			if(!newkey)
				return

			var/codeval = codes[codekey]
			var/newval = stripped_input(usr, "Enter Transponder Code Value", "Navigation Beacon", codeval)
			if(!newval)
				newval = codekey
				return

			codes.Remove(codekey)
			codes[newkey] = newval
			glob_lists_register()

			updateDialog()

		else if(href_list["delete"])
			var/codekey = href_list["code"]
			codes.Remove(codekey)
			glob_lists_register()
			updateDialog()

		else if(href_list["add"])

			var/newkey = stripped_input(usr, "Enter New Transponder Code Key", "Navigation Beacon")
			if(!newkey)
				return

			var/newval = stripped_input(usr, "Enter New Transponder Code Value", "Navigation Beacon")
			if(!newval)
				newval = "1"
				return

			if(!codes)
				codes = new()

			codes[newkey] = newval
			glob_lists_register()

			updateDialog()
