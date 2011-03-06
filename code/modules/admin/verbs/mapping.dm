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

/obj/debugging/camera_range
	icon = '480x480.dmi'
	icon_state = "25percent"

	New()
		src.pixel_x = -224
		src.pixel_y = -224

/obj/debugging/marker
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



		for(var/obj/debugging/camera_range/C in world)
			del(C)

		if(camera_range_display_status)
			for(var/obj/machinery/camera/C in world)
				new/obj/debugging/camera_range(C.loc)



	sec_camera_report()
		set category = "Mapping"
		set name = "Sec Camera Report"

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

		output += "</ul>"
		usr << browse(output,"window=airreport;size=1000x500")

	intercom_view()
		set category = "Mapping"
		set name = "Intercom Range Display"

		if(intercom_range_display_status)
			intercom_range_display_status = 0
		else
			intercom_range_display_status = 1

		for(var/obj/debugging/marker/M in world)
			del(M)

		if(intercom_range_display_status)
			for(var/obj/item/device/radio/intercom/I in world)
				for(var/turf/T in orange(7,I))
					var/obj/debugging/marker/F = new/obj/debugging/marker(T)
					if (!(F in view(7,I.loc)))
						del(F)