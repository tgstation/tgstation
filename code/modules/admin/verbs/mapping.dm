//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

ADMIN_VERB(mapping, camera_range_display, "Camera Range Display", "Iterate over all cameras in world and generate a camera map", R_DEBUG)
	if(tgui_alert(usr, "This can take a very long time and lock up the game!", "Don't do this on live", list("Okay", "Nevermind")) != "Okay")
		return

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

#ifdef TESTING
GLOBAL_LIST_EMPTY(dirty_vars)
ADMIN_VERB(mapping, dirty_varedits, "Dirty VarEdits", "", R_DEBUG)
	var/list/dat = list()
	dat += "<h3>Abandon all hope ye who enter here</h3><br><br>"
	for(var/thing in GLOB.dirty_vars)
		dat += "[thing]<br>"
		CHECK_TICK
	var/datum/browser/popup = new(usr, "dirty_vars", "Dirty Varedits", 900, 750)
	popup.set_content(dat.Join())
	popup.open()
#endif

ADMIN_VERB(mapping, camera_report, "Camera Report", "", R_DEBUG)
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
					if (W.dir == turn(C1.dir,180) || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at [ADMIN_VERBOSEJMP(C1)] Network: [json_encode(C1.network)]</font></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")

ADMIN_VERB(mapping, intercom_range_display, "Intercomm Range Display", "", R_DEBUG)
	var/static/intercom_range_display_status = FALSE
	//blame cyberboss if this breaks something //blamed
	intercom_range_display_status = !intercom_range_display_status

	for(var/obj/effect/abstract/marker/intercom/marker in GLOB.all_abstract_markers)
		qdel(marker)

	if(intercom_range_display_status)
		for(var/frequency in GLOB.all_radios)
			for(var/obj/item/radio/intercom/intercom in GLOB.all_radios[frequency])
				for(var/turf/turf in view(7,intercom.loc))
					new /obj/effect/abstract/marker/intercom(turf)

ADMIN_VERB(mapping, show_map_report_list, "Show Map Report List", "Display a list of map reports", R_DEBUG)
	var/dat = {"<b>List of all map reports:</b><br>"}

	for(var/datum/map_report/report as anything in GLOB.map_reports)
		dat += "[report.tag] ([report.original_path]) - <a href='?src=[REF(report)];[HrefToken()];show=1'>View</a><br>"

	usr << browse(dat, "window=map_reports")

ADMIN_VERB(mapping, show_roundstart_at_list, "Show Roundstart AT List", "Displays a list of active turfs at roundstart", R_DEBUG)
	var/dat = {"<b>Coordinate list of Active Turfs at Roundstart</b>
		<br>Real-time Active Turfs list you can see in Air Subsystem at active_turfs var<br>"}

	for(var/t in GLOB.active_turfs_startlist)
		var/turf/T = t
		dat += "[ADMIN_VERBOSEJMP(T)]\n"
		dat += "<br>"
	usr << browse(dat, "window=at_list")

ADMIN_VERB(mapping, show_roundstart_at_markers, "Show Roundstart AT Markers", "Places a marker on all active-at-roundstart turfs", R_DEBUG)
	var/count = 0
	for(var/obj/effect/abstract/marker/at/AT in GLOB.all_abstract_markers)
		qdel(AT)
		count++

	if(count)
		to_chat(usr, "[count] AT markers removed.", confidential = TRUE)
	else
		for(var/t in GLOB.active_turfs_startlist)
			new /obj/effect/abstract/marker/at(t)
			count++
		to_chat(usr, "[count] AT markers placed.", confidential = TRUE)

ADMIN_VERB(mapping, count_objects_on_zlevel, "Count Objects on ZLevel", "", R_DEBUG)
	var/level = input("Which z-level?","Level?") as text|null
	if(!level)
		return
	var/num_level = text2num(level)
	if(!num_level)
		return
	if(!isnum(num_level))
		return

	var/type_text = input("Which type path?","Path?") as text|null
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

ADMIN_VERB(mapping, count_all_objects, "Count All Objects", "", R_DEBUG)
	var/type_text = input("Which type path?","") as text|null
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

//This proc is intended to detect lag problems relating to communication procs
GLOBAL_VAR_INIT(say_disabled, FALSE)
// Why is this a mapping verb?
ADMIN_VERB(mapping, disable_all_communication_verbs, "Disable All Communication Verbs", "", R_DEBUG)
	GLOB.say_disabled = !GLOB.say_disabled
	var/message = "has [(GLOB.say_disabled ? "disabled" : "enabled")] all forms of communication"
	message_admins("[key_name_admin(usr)] [message]")
	log_admin("[key_name(usr)] [message]")

ADMIN_VERB(mapping,	generate_job_landmark_icons, "Generate Job Landmark Icons", "This generates the icon states for job starting location landmarks", R_DEBUG)
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
				randomize_human(D)
				D.dress_up_as_job(JB, TRUE)
				var/icon/I = icon(getFlatIcon(D), frame = 1)
				final.Insert(I, JB.title)
	qdel(D)
	//Also add the x
	for(var/x_number in 1 to 4)
		final.Insert(icon('icons/hud/screen_gen.dmi', "x[x_number == 1 ? "" : x_number]"), "x[x_number == 1 ? "" : x_number]")
	fcopy(final, "icons/mob/landmarks.dmi")

ADMIN_VERB(mapping, debug_zlevels, "Debug ZLevels", "", R_DEBUG)
	var/list/z_list = SSmapping.z_list
	var/list/messages = list()
	messages += "<b>World</b>: [world.maxx] x [world.maxy] x [world.maxz]<br><br>"

	var/list/linked_levels = list()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY

	for(var/z in 1 to max(world.maxz, z_list.len))
		if (z > z_list.len)
			messages += "<b>[z]</b>: Unmanaged (out of bounds)<br>"
			continue
		var/datum/space_level/S = z_list[z]
		if (!S)
			messages += "<b>[z]</b>: Unmanaged (null)<br>"
			continue
		var/linkage
		switch (S.linkage)
			if (UNAFFECTED)
				linkage = "no linkage"
			if (SELFLOOPING)
				linkage = "self-looping"
			if (CROSSLINKED)
				linkage = "linked at ([S.xi], [S.yi])"
				linked_levels += S
				min_x = min(min_x, S.xi)
				min_y = min(min_y, S.yi)
				max_x = max(max_x, S.xi)
				max_y = max(max_y, S.yi)
			else
				linkage = "unknown linkage '[S.linkage]'"

		messages += "<b>[z]</b>: [S.name], [linkage], traits: [json_encode(S.traits)]<br>"
		if (S.z_value != z)
			messages += "-- z_value is [S.z_value], should be [z]<br>"
		if (S.name == initial(S.name))
			messages += "-- name not set<br>"
		if (z > world.maxz)
			messages += "-- exceeds max z"

	var/grid[max_x - min_x + 1][max_y - min_y + 1]
	for(var/datum/space_level/S in linked_levels)
		grid[S.xi - min_x + 1][S.yi - min_y + 1] = S.z_value

	messages += "<br><table border='1'>"
	for(var/y in max_y to min_y step -1)
		var/list/part = list()
		for(var/x in min_x to max_x)
			part += "[grid[x - min_x + 1][y - min_y + 1]]"
		messages += "<tr><td>[part.Join("</td><td>")]</td></tr>"
	messages += "</table>"
	to_chat(usr, examine_block(messages.Join("")), confidential = TRUE)

ADMIN_VERB(mapping, count_station_food, "Count Station Food", "", R_DEBUG)
	var/list/foodcount = list()
	for(var/obj/item/food/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || SSmapping.level_trait(location.z, ZTRAIT_STATION))
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
	var/datum/browser/popup = new(usr, "fooddebug", "Station Food Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB(mapping, count_station_stacks, "Count Station Stacks", "", R_DEBUG)
	var/list/stackcount = list()
	for(var/obj/item/stack/fuck_me in world)
		var/turf/location = get_turf(fuck_me)
		if(!location || SSmapping.level_trait(location.z, ZTRAIT_STATION))
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
	var/datum/browser/popup = new(usr, "stackdebug", "Station Stack Count", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB(mapping, check_for_obstructed_atmopsherics, "Check For Obstructed Atmospherics", "Check all tiles with a vent or scrubber on it and ensure that nothing is covering it up", R_DEBUG)
	message_admins(span_adminnotice("[key_name_admin(usr)] is checking for obstructed atmospherics through the debug command."))
	var/list/results = list()
	results += "<h2><b>Anything that is considered to aesthetically obstruct an atmospherics machine (vent, scrubber, port) is listed below.</b> Please re-arrange to accomodate for this.</h2><br>"

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
		to_chat(src, "No obstructions detected.", confidential = TRUE)
	else
		var/datum/browser/popup = new(usr, "atmospherics_obstructions", "Atmospherics Obstructions", 900, 750)
		popup.set_content(results.Join())
		popup.open()
