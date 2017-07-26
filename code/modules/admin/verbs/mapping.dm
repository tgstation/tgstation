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

GLOBAL_PROTECT(admin_verbs_debug_mapping)
GLOBAL_LIST_INIT(admin_verbs_debug_mapping, list(
	/client/proc/camera_view, 				//-errorage
	/client/proc/sec_camera_report, 		//-errorage
	/client/proc/intercom_view, 			//-errorage
	/client/proc/air_status, //Air things
	/client/proc/Cell, //More air things
	/client/proc/atmosscan, //check plumbing
	/client/proc/powerdebug, //check power
	/client/proc/count_objects_on_z_level,
	/client/proc/count_objects_all,
	/client/proc/cmd_assume_direct_control,	//-errorage
	/client/proc/startSinglo,
	/client/proc/set_server_fps,	//allows you to set the ticklag.
	/client/proc/cmd_admin_grantfullaccess,
	/client/proc/cmd_admin_areatest,
	/client/proc/cmd_admin_rejuvenate,
	/datum/admins/proc/show_traitor_panel,
	/client/proc/disable_communication,
	/client/proc/print_pointers,
	/client/proc/cmd_show_at_list,
	/client/proc/cmd_show_at_markers,
	/client/proc/manipulate_organs
))

/obj/effect/debugging/mapfix_marker
	name = "map fix marker"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "mapfixmarker"
	desc = "I am a mappers mistake."

/obj/effect/debugging/marker
	icon = 'icons/turf/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Move()
	return 0

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	var/on = FALSE
	for(var/turf/T in world)
		if(T.maptext)
			on = TRUE
		T.maptext = null

	if(!on)
		var/list/seen = list()
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			for(var/turf/T in C.can_see())
				seen[T]++
		for(var/turf/T in seen)
			T.maptext = "[seen[T]]"
	SSblackbox.add_details("admin_verb","Show Camera Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	if(!Master)
		alert(usr,"Master_controller not found.","Sec Camera Report")
		return 0

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		CL += C

	var/output = {"<B>CAMERA ANNOMALITIES REPORT</B><HR>
<B>The following annomalities have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) and \[[C2.x], [C2.y], [C2.z]\] ([C2.loc.loc]) - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density )
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if (W.dir == turn(C1.dir,180) || W.dir in list(5,6,9,10) )
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Network: [C1.network]</color></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")
	SSblackbox.add_details("admin_verb","Show Camera Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	var/static/intercom_range_display_status = FALSE
	intercom_range_display_status = !intercom_range_display_status //blame cyberboss if this breaks something

	for(var/obj/effect/debugging/marker/M in world)
		qdel(M)

	if(intercom_range_display_status)
		for(var/obj/item/device/radio/intercom/I in world)
			for(var/turf/T in orange(7,I))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if (!(F in view(7,I.loc)))
					qdel(F)
	SSblackbox.add_details("admin_verb","Show Intercom Range") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_show_at_list()
	set category = "Mapping"
	set name = "Show roundstart AT list"
	set desc = "Displays a list of active turfs coordinates at roundstart"

	var/dat = {"<b>Coordinate list of Active Turfs at Roundstart</b>
	 <br>Real-time Active Turfs list you can see in Air Subsystem at active_turfs var<br>"}

	for(var/t in GLOB.active_turfs_startlist)
		var/turf/T = t
		dat += "[ADMIN_COORDJMP(T)]\n"
		dat += "<br>"

	usr << browse(dat, "window=at_list")

	SSblackbox.add_details("admin_verb","Show Roundstart Active Turfs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_show_at_markers()
	set category = "Mapping"
	set name = "Show roundstart AT markers"
	set desc = "Places a marker on all active-at-roundstart turfs"

	var/count = 0
	for(var/obj/effect/abstract/marker/at/AT in GLOB.all_abstract_markers)
		qdel(AT)
		count++

	if(count)
		to_chat(usr, "[count] AT markers removed.")
	else
		for(var/t in GLOB.active_turfs_startlist)
			new /obj/effect/abstract/marker/at(t)
			count++
		to_chat(usr, "[count] AT markers placed.")

	SSblackbox.add_details("admin_verb","Show Roundstart Active Turf Markers")

/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs - Enable"
	if(!check_rights(R_DEBUG))
		return
	verbs -= /client/proc/enable_debug_verbs
	verbs.Add(/client/proc/disable_debug_verbs, GLOB.admin_verbs_debug_mapping)
	SSblackbox.add_details("admin_verb","Enable Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/disable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs - Disable"
	verbs.Remove(/client/proc/disable_debug_verbs, GLOB.admin_verbs_debug_mapping)
	verbs += /client/proc/enable_debug_verbs
	SSblackbox.add_details("admin_verb", "Disable Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"
	var/level = input("Which z-level?","Level?") as text
	if(!level) return
	var/num_level = text2num(level)
	if(!num_level) return
	if(!isnum(num_level)) return

	var/type_text = input("Which type path?","Path?") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level]")
	SSblackbox.add_details("admin_verb","Count Objects Zlevel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		to_chat(world, line)*/

	to_chat(world, "There are [count] objects of type [type_path] in the game world")
	SSblackbox.add_details("admin_verb","Count Objects All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//This proc is intended to detect lag problems relating to communication procs
GLOBAL_VAR_INIT(say_disabled, FALSE)
/client/proc/disable_communication()
	set category = "Mapping"
	set name = "Disable all communication verbs"

	GLOB.say_disabled = !GLOB.say_disabled
	if(GLOB.say_disabled)
		message_admins("[src.ckey] used 'Disable all communication verbs', killing all communication methods.")
	else
		message_admins("[src.ckey] used 'Disable all communication verbs', restoring all communication methods.")
