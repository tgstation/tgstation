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

var/camera_range_display_status = 0
var/intercom_range_display_status = 0

/obj/effect/debugging/camera_range
	icon = '480x480.dmi'
	icon_state = "25percent"

	New()
		src.pixel_x = -224
		src.pixel_y = -224

/obj/effect/debugging/marker
	icon = 'areas.dmi'
	icon_state = "yellow"

/client/proc

	do_not_use_these()
		set category = "Mapping"
		set name = "-None of these are for ingame use!!"

		..()

	camera_view()
		set category = "Mapping"
		set name = "Camera Range Display"

		if(camera_range_display_status)
			camera_range_display_status = 0
		else
			camera_range_display_status = 1



		for(var/obj/effect/debugging/camera_range/C in world)
			del(C)

		if(camera_range_display_status)
			for(var/obj/machinery/camera/C in world)
				new/obj/effect/debugging/camera_range(C.loc)
		feedback_add_details("admin_verb","mCRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



	sec_camera_report()
		set category = "Mapping"
		set name = "Camera Report"

		if(!master_controller)
			alert(usr,"Master_controller not found.","Sec Camera Report")
			return 0

		var/list/obj/machinery/camera/CL = list()

		for(var/obj/machinery/camera/C in world)
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
		feedback_add_details("admin_verb","mCRP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	intercom_view()
		set category = "Mapping"
		set name = "Intercom Range Display"

		if(intercom_range_display_status)
			intercom_range_display_status = 0
		else
			intercom_range_display_status = 1

		for(var/obj/effect/debugging/marker/M in world)
			del(M)

		if(intercom_range_display_status)
			for(var/obj/item/device/radio/intercom/I in world)
				for(var/turf/T in orange(7,I))
					var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
					if (!(F in view(7,I.loc)))
						del(F)
		feedback_add_details("admin_verb","mIRD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	enable_debug_verbs()
		set category = "Debug"
		set name = "Debug verbs"
		src.verbs += /client/proc/do_not_use_these 			//-errorage
		src.verbs += /client/proc/camera_view 				//-errorage
		src.verbs += /client/proc/sec_camera_report 		//-errorage
		src.verbs += /client/proc/intercom_view 			//-errorage
		src.verbs += /client/proc/air_status //Air things
		src.verbs += /client/proc/Cell //More air things
		src.verbs += /client/proc/atmosscan //check plumbing
		src.verbs += /client/proc/count_objects_on_z_level
		src.verbs += /client/proc/count_objects_all
		src.verbs += /client/proc/cmd_assume_direct_control	//-errorage
		src.verbs += /client/proc/jump_to_dead_group
		src.verbs += /client/proc/startSinglo
		feedback_add_details("admin_verb","mDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	count_objects_on_z_level()
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
			world << line*/

		world << "There are [count] objects of type [type_path] on z-level [num_level]"
		feedback_add_details("admin_verb","mOBJZ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	count_objects_all()
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
			world << line*/

		world << "There are [count] objects of type [type_path] in the game world"
		feedback_add_details("admin_verb","mOBJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!