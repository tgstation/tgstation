// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	layer = LOW_OBJ_LAYER
	max_integrity = 500
	armor_type = /datum/armor/machinery_navbeacon
	circuit = /obj/item/circuitboard/machine/navbeacon

	/// true if controls are locked
	var/locked = TRUE
	/// location response text
	var/location = ""
	/// assoc. list of transponder codes
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

///Set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = list()

	var/list/entries = splittext(codes_txt, ";") // entries are separated by semicolons

	for(var/entry in entries)
		var/index = findtext(entry, "=") // format is "key=value"
		if(index)
			var/key = copytext(entry, 1, index)
			var/val = copytext(entry, index + length(entry[index]))
			codes[key] = val
		else
			codes[entry] = "1"

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
	if(codes["patrol"])
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if(codes["delivery"])
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/navbeacon/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "navbeacon1","navbeacon0",tool)

/obj/machinery/navbeacon/attackby(obj/item/I, mob/user, params)
	var/turf/T = loc
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	if (isidcard(I) || istype(I, /obj/item/modular_computer/pda))
		if(!panel_open)
			if (allowed(user))
				locked = !locked
				balloon_alert(user, "controls [locked ? "locked" : "unlocked"]")
			else
				balloon_alert(user, "access denied")
			updateDialog()
		else
			balloon_alert(user, "panel open!")
		return

	return ..()

/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user)

/obj/machinery/navbeacon/attack_paw(mob/user, list/modifiers)
	return

/obj/machinery/navbeacon/ui_interact(mob/user)
	. = ..()
	var/ai = isAI(user)
	var/turf/our_turf = loc
	if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return // prevent intraction when T-scanner revealed

	var/data

	if(locked && !ai)
		data = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			data += "<LI>[key] ... [codes[key]]"
		data+= "<UL></TT>"

	else

		data = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>

<HR>
Location: <A href='byond://?src=[REF(src)];locedit=1'>[location ? location : "None"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			data += "<LI>[key] ... [codes[key]]"
			data += " <A href='byond://?src=[REF(src)];edit=1;code=[key]'>Edit</A>"
			data += " <A href='byond://?src=[REF(src)];delete=1;code=[key]'>Delete</A><BR>"
		data += " <A href='byond://?src=[REF(src)];add=1;'>Add New</A><BR>"
		data += "<UL></TT>"

	var/datum/browser/popup = new(user, "navbeacon", "Navigation Beacon", 300, 400)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/navbeacon/Topic(href, href_list)
	if(..())
		return
	if(isAI(usr) || (!panel_open && !locked))
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
