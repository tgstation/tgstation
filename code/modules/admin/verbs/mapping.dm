ADMIN_VERB_VISIBILITY(camera_view, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(camera_view, R_DEBUG, "Camera Range Display", "Shows the range of cameras on the station.", ADMIN_CATEGORY_MAPPING)
	var/on = FALSE
	for(var/turf/T in world)
		if(T.maptext)
			on = TRUE
		T.maptext = null

	if(!on)
		var/list/seen = list()
		for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
			for(var/turf/T in C.can_see())
				seen[T]++
		for(var/turf/T in seen)
			T.maptext = MAPTEXT(seen[T])
	BLACKBOX_LOG_ADMIN_VERB("Show Camera Range")

#ifdef TESTING
GLOBAL_LIST_EMPTY(dirty_vars)

ADMIN_VERB_VISIBILITY(see_dirty_varedits, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(see_dirty_varedits, R_DEBUG, "Dirty Varedits", "Shows all dirty varedits.", ADMIN_CATEGORY_MAPPING)
	var/list/dat = list()
	dat += "<h3>Abandon all hope ye who enter here</h3><br><br>"
	for(var/thing in GLOB.dirty_vars)
		dat += "[thing]<br>"
		CHECK_TICK
	var/datum/browser/popup = new(user, "dirty_vars", "Dirty Varedits", 900, 750)
	popup.set_content(dat.Join())
	popup.open()
#endif

ADMIN_VERB_VISIBILITY(sec_camera_report, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(sec_camera_report, R_DEBUG, "Camera Report", "Get a printout of all camera issues.", ADMIN_CATEGORY_MAPPING)
	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
		CL += C

	var/output = {"<B>Camera Abnormalities Report</B><HR>
<B>The following abnormalities have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for cameras at [ADMIN_VERBOSEJMP(C1)] and [ADMIN_VERBOSEJMP(C2)] - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [json_encode(C1.network)] and [json_encode(C2.network)]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>Overlapping cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [json_encode(C1.network)] and [json_encode(C2.network)]</li>"
		var/turf/T = get_step(C1,C1.dir)
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille) in T))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if (W.dir == REVERSE_DIR(C1.dir) || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at [ADMIN_VERBOSEJMP(C1)] Network: [json_encode(C1.network)]</font></li>"

	output += "</ul>"
	user << browse(output,"window=airreport;size=1000x500")
	BLACKBOX_LOG_ADMIN_VERB("Show Camera Report")

ADMIN_VERB_VISIBILITY(intercom_view, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(intercom_view, R_DEBUG, "Intercom Range Display", "Shows the range of intercoms on the station.", ADMIN_CATEGORY_MAPPING)
	var/static/intercom_range_display_status = FALSE
	intercom_range_display_status = !intercom_range_display_status

	for(var/obj/effect/abstract/marker/intercom/marker in GLOB.all_abstract_markers)
		qdel(marker)

	if(intercom_range_display_status)
		for(var/frequency in GLOB.all_radios)
			for(var/obj/item/radio/intercom/intercom in GLOB.all_radios[frequency])
				for(var/turf/turf in view(7,intercom.loc))
					new /obj/effect/abstract/marker/intercom(turf)
	BLACKBOX_LOG_ADMIN_VERB("Show Intercom Range")

ADMIN_VERB_VISIBILITY(show_map_reports, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(show_map_reports, R_DEBUG, "Show Map Reports", "Displays a list of map reports.", ADMIN_CATEGORY_MAPPING)
	var/dat = {"<b>List of all map reports:</b><br>"}

	for(var/datum/map_report/report as anything in GLOB.map_reports)
		dat += "[report.tag] ([report.original_path]) - <a href='byond://?src=[REF(report)];[HrefToken()];show=1'>View</a><br>"

	user << browse(dat, "window=map_reports")

ADMIN_VERB_VISIBILITY(cmd_show_at_list, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(cmd_show_at_list, R_DEBUG, "Show roundstart AT list", "Displays a list of active turfs coordinates at roundstart.", ADMIN_CATEGORY_MAPPING)
	var/dat = {"<b>Coordinate list of Active Turfs at Roundstart</b>
		<br>Real-time Active Turfs list you can see in Air Subsystem at active_turfs var<br>"}

	for(var/t in GLOB.active_turfs_startlist)
		var/turf/T = t
		dat += "[ADMIN_VERBOSEJMP(T)]\n"
		dat += "<br>"

	user << browse(dat, "window=at_list")

	BLACKBOX_LOG_ADMIN_VERB("Show Roundstart Active Turfs")

ADMIN_VERB_VISIBILITY(cmd_show_at_markers, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(cmd_show_at_markers, R_DEBUG, "Show roundstart AT markers", "Places a marker on all active-at-roundstart turfs.", ADMIN_CATEGORY_MAPPING)
	var/count = 0
	for(var/obj/effect/abstract/marker/at/AT in GLOB.all_abstract_markers)
		qdel(AT)
		count++

	if(count)
		to_chat(user, "[count] AT markers removed.", confidential = TRUE)
	else
		for(var/t in GLOB.active_turfs_startlist)
			new /obj/effect/abstract/marker/at(t)
			count++
		to_chat(user, "[count] AT markers placed.", confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Show Roundstart Active Turf Markers")

ADMIN_VERB(enable_mapping_verbs, R_DEBUG, "Enable Mapping Verbs", "Enable all mapping verbs.", ADMIN_CATEGORY_MAPPING)
	SSadmin_verbs.update_visibility_flag(user, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG, TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Enable Debug Verbs")

ADMIN_VERB_VISIBILITY(disable_mapping_verbs, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(disable_mapping_verbs, R_DEBUG, "Disable Mapping Verbs", "Disable all mapping verbs.", ADMIN_CATEGORY_MAPPING)
	SSadmin_verbs.update_visibility_flag(user, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG, FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Disable Debug Verbs")

ADMIN_VERB_VISIBILITY(count_objects_on_z_level, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(count_objects_on_z_level, R_DEBUG, "Count Objects On Z-Level", "Counts the number of objects of a certain type on a specific z-level.", ADMIN_CATEGORY_MAPPING)
	var/level = input(user, "Which z-level?","Level?") as text|null
	if(!level)
		return
	var/num_level = text2num(level)
	if(!num_level)
		return
	if(!isnum(num_level))
		return

	var/type_text = input(user, "Which type path?","Path?") as text|null
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B?.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level]", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Count Objects Zlevel")

ADMIN_VERB_VISIBILITY(count_objects_all, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(count_objects_all, R_DEBUG, "Count Objects All", "Counts the number of objects of a certain type in the game world.", ADMIN_CATEGORY_MAPPING)
	var/type_text = input(user, "Which type path?","") as text|null
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++

	to_chat(world, "There are [count] objects of type [type_path] in the game world", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Count Objects All")

GLOBAL_VAR_INIT(say_disabled, FALSE)
ADMIN_VERB_VISIBILITY(disable_communication, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(disable_communication, R_DEBUG, "Disable all communication verbs", "Disables all communication verbs.", ADMIN_CATEGORY_MAPPING)
	GLOB.say_disabled = !GLOB.say_disabled
	if(GLOB.say_disabled)
		message_admins("[key_name_admin(user)] used 'Disable all communication verbs', killing all communication methods.")
	else
		message_admins("[key_name_admin(user)] used 'Disable all communication verbs', restoring all communication methods.")

ADMIN_VERB_VISIBILITY(create_mapping_job_icons, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(create_mapping_job_icons, R_DEBUG, "Generate job landmarks icons", "Generates job starting location landmarks.", ADMIN_CATEGORY_MAPPING)
	var/icon/final = icon()
	var/mob/living/carbon/human/dummy/D = new(locate(1,1,1)) //spawn on 1,1,1 so we don't have runtimes when items are deleted
	D.setDir(SOUTH)
	for(var/job in subtypesof(/datum/job))
		var/datum/job/JB = new job
		switch(JB.title)
			if(JOB_AI)
				final.Insert(icon('icons/mob/silicon/ai.dmi', "ai", SOUTH, 1), "AI")
			if(JOB_CYBORG)
				final.Insert(icon('icons/mob/silicon/robots.dmi', "robot", SOUTH, 1), "Cyborg")
			else
				for(var/obj/item/I in D)
					qdel(I)
				randomize_human_normie(D)
				D.dress_up_as_job(
					equipping = JB,
					visual_only = TRUE,
					consistent = TRUE,
				)
				var/icon/I = icon(getFlatIcon(D), frame = 1)
				final.Insert(I, JB.title)
	qdel(D)
	//Also add the x
	for(var/x_number in 1 to 4)
		final.Insert(icon('icons/hud/screen_gen.dmi', "x[x_number == 1 ? "" : x_number]"), "x[x_number == 1 ? "" : x_number]")
	fcopy(final, "icons/mob/landmarks.dmi")

ADMIN_VERB_VISIBILITY(debug_z_levels, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(debug_z_levels, R_DEBUG, "Debug Z-Levels", "Displays a list of all z-levels and their linkages.", ADMIN_CATEGORY_MAPPING)
	to_chat(user, boxed_message(gather_z_level_information(append_grid = TRUE)), confidential = TRUE)

/// Returns all necessary z-level information. Argument `append_grid` allows the user to see a table showing all of the z-level linkages, which is only visible and useful in-game.
/proc/gather_z_level_information(append_grid = FALSE)
	var/list/messages = list()

	var/list/z_list = SSmapping.z_list
	messages += "\n<b>World</b>: [world.maxx] x [world.maxy] x [world.maxz]\n"

	var/list/linked_levels = list()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY

	for(var/z in 1 to max(world.maxz, z_list.len))
		if (z > z_list.len)
			messages += "<b>[z]</b>: Unmanaged (out of bounds)"
			continue
		var/datum/space_level/level = z_list[z]
		if (!level)
			messages += "<b>[z]</b>: Unmanaged (null)"
			continue
		var/linkage
		switch (level.linkage)
			if (UNAFFECTED)
				linkage = "no linkage"
			if (SELFLOOPING)
				linkage = "self-looping"
			if (CROSSLINKED)
				linkage = "linked at ([level.xi], [level.yi])"
				linked_levels += level
				min_x = min(min_x, level.xi)
				min_y = min(min_y, level.yi)
				max_x = max(max_x, level.xi)
				max_y = max(max_y, level.yi)
			else
				linkage = "unknown linkage '[level.linkage]'"

		messages += "<b>[z]</b>: [level.name], [linkage], traits: [json_encode(level.traits)]"
		if (level.z_value != z)
			messages += "-- z_value is [level.z_value], should be [z]"
		if (level.name == initial(level.name))
			messages += "-- name not set"
		if (z > world.maxz)
			messages += "-- exceeds max z"

	var/grid[max_x - min_x + 1][max_y - min_y + 1]
	for(var/datum/space_level/linked_level in linked_levels)
		grid[linked_level.xi - min_x + 1][linked_level.yi - min_y + 1] = linked_level.z_value

	if(append_grid)
		messages += "<br><table border='1'>"
		for(var/y in max_y to min_y step -1)
			var/list/part = list()
			for(var/x in min_x to max_x)
				part += "[grid[x - min_x + 1][y - min_y + 1]]"
			messages += "<tr><td>[part.Join("</td><td>")]</td></tr>"
		messages += "</table>"

	return messages.Join("\n")

ADMIN_VERB_VISIBILITY(station_food_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(station_food_debug, R_DEBUG, "Count Station Food", "Counts the number of food items on the station.", ADMIN_CATEGORY_MAPPING)
	var/list/foodcount = list()
	for(var/obj/item/food/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || !SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		LAZYADDASSOC(foodcount, fuck_me.type, 1)

	var/table_header = "<tr><th>Name</th> <th>Type</th> <th>Amount</th>"
	var/table_contents = list()
	for(var/atom/type as anything in foodcount)
		var/foodname = initial(type.name)
		var/count = foodcount[type]
		table_contents += "<tr><td>[foodname]</td> <td>[type]</td> <td>[count]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[table_header][jointext(table_contents, "")]</table>"
	var/datum/browser/popup = new(user.mob, "fooddebug", "Station Food Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB_VISIBILITY(station_stack_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(station_stack_debug, R_DEBUG, "Count Station Stacks", "Count the stacks of materials on station.", ADMIN_CATEGORY_MAPPING)
	var/list/stackcount = list()
	for(var/obj/item/stack/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || !SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		LAZYADDASSOC(stackcount, fuck_me.type, fuck_me.amount)

	var/table_header = "<tr><th>Name</th> <th>Type</th> <th>Amount</th>"
	var/table_contents = list()
	for(var/atom/type as anything in stackcount)
		var/stackname = initial(type.name)
		var/count = stackcount[type]
		table_contents += "<tr><td>[stackname]</td> <td>[type]</td> <td>[count]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[table_header][jointext(table_contents, "")]</table>"
	var/datum/browser/popup = new(user.mob, "stackdebug", "Station Stack Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB_VISIBILITY(check_for_obstructed_atmospherics, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(check_for_obstructed_atmospherics, R_DEBUG, "Check For Obstructed Atmospherics", "Checks for obstructions on atmospherics machines.", ADMIN_CATEGORY_MAPPING)
	message_admins(span_adminnotice("[key_name_admin(user)] is checking for obstructed atmospherics through the debug command."))
	BLACKBOX_LOG_ADMIN_VERB("Check For Obstructed Atmospherics")

	var/list/results = list()

	results += "<h2><b>Anything that is considered to aesthetically obstruct an atmospherics machine (vent, scrubber, port) is listed below.</b> Please re-arrange to accommodate for this.</h2><br>"

	// Ignore out stuff we see in normal and standard mapping that we don't care about (false alarms). Typically stuff that goes directionally off turfs or other undertile objects that we don't want to care about.
	var/list/ignore_list = list(
		/obj/effect,
		/obj/item/shard, // it's benign enough to where we don't need to error, yet common enough to filter. fuck.
		/obj/machinery/airalarm,
		/obj/machinery/atmospherics/components/unary, //don't wanna flag on the vent or scrubber itself.
		/obj/machinery/atmospherics/pipe,
		/obj/machinery/button,
		/obj/machinery/camera,
		/obj/machinery/door_buttons,
		/obj/machinery/door/window, // i kind of wish we didn't have to do it but we have some particularly compact areas that we need to be wary of
		/obj/machinery/duct,
		/obj/machinery/firealarm,
		/obj/machinery/flasher,
		/obj/machinery/light_switch,
		/obj/machinery/light,
		/obj/machinery/navbeacon,
		/obj/machinery/newscaster,
		/obj/machinery/portable_atmospherics,
		/obj/machinery/power/apc,
		/obj/machinery/power/terminal,
		/obj/machinery/sparker,
		/obj/machinery/status_display,
		/obj/machinery/turretid,
		/obj/structure/cable,
		/obj/structure/disposalpipe,
		/obj/structure/extinguisher_cabinet,
		/obj/structure/lattice,
		/obj/structure/sign,
		/obj/structure/urinal, // the reason why this one gets to live and not the shower/sink is because it's pretty firmly on a wall.
		/obj/structure/window/reinforced,
	)

	for(var/turf/iterated_turf in world)
		var/obj/machinery/atmospherics/components/unary/device = locate() in iterated_turf.contents
		if(!device)
			continue
		var/list/obj/obstruction = locate(/obj) in iterated_turf.contents
		if(!is_type_in_list(obstruction, ignore_list))
			results += "There is an obstruction on top of an atmospherics machine at: [ADMIN_VERBOSEJMP(iterated_turf)].<br>"

	if(results.len == 1) // only the header is in the list, we're good
		to_chat(user, "No obstructions detected.", confidential = TRUE)
	else
		var/datum/browser/popup = new(user.mob, "atmospherics_obstructions", "Atmospherics Obstructions", 900, 750)
		popup.set_content(results.Join())
		popup.open()

ADMIN_VERB_VISIBILITY(modify_lights, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(modify_lights, R_DEBUG, "Toggle Light Debug", "Toggles light debug mode.", ADMIN_CATEGORY_MAPPING)
	if(GLOB.light_debug_enabled)
		undebug_sources()
		return

	for(var/obj/machinery/light/fix_up as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
		// Only fix lights that started out fixed
		if(initial(fix_up.status) == LIGHT_OK)
			fix_up.fix()
		CHECK_TICK
	debug_sources()

ADMIN_VERB_VISIBILITY(visualize_lights, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(visualize_lights, R_DEBUG, "Visualize Lighting Corners", "Visualizes the corners of all lights on the station.", ADMIN_CATEGORY_MAPPING)
	display_corners()
