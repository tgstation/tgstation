GLOBAL_LIST_EMPTY(GPS_list)
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016. Alt+click to toggle power."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=1;bluespace=2"
	unique_rename = TRUE
	var/gpstag = "COM0"
	var/emped = FALSE
	var/turf/locked_location
	var/tracking = TRUE
	var/updating = TRUE //Automatic updating of GPS list. Can be set to manual by user.
	var/global_mode = TRUE //If disabled, only GPS signals of the same Z level are shown


/obj/item/device/gps/Initialize()
	..()
	GLOB.GPS_list += src
	name = "global positioning system ([gpstag])"
	add_overlay("working")

/obj/item/device/gps/Destroy()
	GLOB.GPS_list -= src
	return ..()

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	cut_overlay("working")
	add_overlay("emp")
	addtimer(CALLBACK(src, .proc/reboot), 300, TIMER_OVERRIDE) //if a new EMP happens, remove the old timer so it doesn't reactivate early
	SStgui.close_uis(src) //Close the UI control if it is open.

/obj/item/device/gps/proc/reboot()
	emped = FALSE
	cut_overlay("emp")
	add_overlay("working")

/obj/item/device/gps/AltClick(mob/user)
	toggletracking(user)

/obj/item/device/gps/proc/toggletracking(mob/user)
	if(!user.canUseTopic(src, be_close=TRUE))
		return //user not valid to use gps
	if(emped)
		to_chat(user, "It's busted!")
		return
	if(tracking)
		cut_overlay("working")
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
		tracking = FALSE
	else
		add_overlay("working")
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
		tracking = TRUE


/obj/item/device/gps/ui_interact(mob/user, ui_key = "gps", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(emped)
		to_chat(user, "[src] fizzles weakly.")
		return
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/gps_window_height = 300 + GLOB.GPS_list.len * 20 // Variable window height, depending on how many GPS units there are to show
		ui = new(user, src, ui_key, "gps", "Global Positioning System", 600, gps_window_height, master_ui, state) //width, height
		ui.open()

	ui.set_autoupdate(state = updating)


/obj/item/device/gps/ui_data(mob/user)
	var/list/data = list()
	data["power"] = tracking
	data["tag"] = gpstag
	data["updating"] = updating
	data["globalmode"] = global_mode
	if(!tracking || emped) //Do not bother scanning if the GPS is off or EMPed
		return data

	var/turf/curr = get_turf(src)
	data["current"] = "[get_area_name(curr)] ([curr.x], [curr.y], [curr.z])"

	var/list/signals = list()
	data["signals"] = list()

	for(var/gps in GLOB.GPS_list)
		var/obj/item/device/gps/G = gps
		if(G.emped || !G.tracking || G == src)
			continue
		var/turf/pos = get_turf(G)
		if(!global_mode && pos.z != curr.z)
			continue
		var/area/gps_area = get_area_name(G)
		var/list/signal = list()
		signal["entrytag"] = G.gpstag //Name or 'tag' of the GPS
		signal["area"] = format_text(gps_area)
		signal["coord"] = "[pos.x], [pos.y], [pos.z]"
		if(pos.z == curr.z) //Distance/Direction calculations for same z-level only
			signal["dist"] = max(get_dist(curr, pos), 0) //Distance between the src and remote GPS turfs
			signal["degrees"] = round(Get_Angle(curr, pos)) //0-360 degree directional bearing, for more precision.
			var/direction = uppertext(dir2text(get_dir(curr, pos))) //Direction text (East, etc). Not as precise, but still helpful.
			if(!direction)
				direction = "CENTER"
				signal["degrees"] = "N/A"
			signal["direction"] = direction

		signals += list(signal) //Add this signal to the list of signals
	data["signals"] = signals
	return data



/obj/item/device/gps/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("rename")
			var/a = input("Please enter desired tag.", name, gpstag) as text
			a = copytext(sanitize(a), 1, 20)
			gpstag = a
			. = TRUE
		if("power")
			toggletracking(usr)
			. = TRUE
		if("updating")
			updating = !updating
			. = TRUE
		if("globalmode")
			global_mode = !global_mode
			. = TRUE

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = input("Please enter desired tag.", name, gpstag) as text
		a = uppertext(copytext(sanitize(a), 1, 5))
		if(in_range(src, usr))
			gpstag = a
			name = "global positioning system ([gpstag])"
			attack_self(usr)

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/device/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/device/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags_1 = NODROP_1

/obj/item/device/gps/internal
	icon_state = null
	flags_1 = ABSTRACT_1
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/device/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/device/gps/internal/base
	gpstag = "NT_AUX"
	desc = "A homing signal from Nanotrasen's mining base."

/obj/item/device/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/device/gps/visible_debug/Initialize()
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/device/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/device/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/device/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()