//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This controls the density of the particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_box"
	reference = "control_box"
	anchored = 0
	density = 1
	use_power = 0
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = 0
	dir = 1
	var/strength_upper_limit = 2
	var/interface_control = 1
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/parts = null
	var/datum/wires/particle_acc/control_box/wires = null

/obj/machinery/particle_accelerator/control_box/New()
	wires = new(src)
	connected_parts = list()
	..()

/obj/machinery/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	..()

/obj/machinery/particle_accelerator/control_box/attack_hand(mob/user)
	if(construction_state >= 3)
		interact(user)
	else if(construction_state == 2) // Wires exposed
		wires.Interact(user)

/obj/machinery/particle_accelerator/control_box/update_state()
	if(construction_state < 3)
		use_power = 0
		assembled = 0
		active = 0
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon()
		connected_parts = list()
		return
	if(!part_scan())
		use_power = 1
		active = 0
		connected_parts = list()

	return

/obj/machinery/particle_accelerator/control_box/update_icon()
	if(active)
		icon_state = "[reference]p1"
	else
		if(use_power)
			if(assembled)
				icon_state = "[reference]p"
			else
				icon_state = "u[reference]p"
		else
			switch(construction_state)
				if(0)
					icon_state = "[reference]"
				if(1)
					icon_state = "[reference]"
				if(2)
					icon_state = "[reference]w"
				else
					icon_state = "[reference]c"
	return

/obj/machinery/particle_accelerator/control_box/Topic(href, href_list)
	if(..())
		return

	if(!interface_control)
		usr << "<span class='error'>ERROR: Request timed out. Check wire contacts.</span>"
		return

	if( href_list["close"] )
		usr << browse(null, "window=pacontrol")
		usr.unset_machine()
		return
	if(href_list["togglep"])
		if(!wires.IsIndexCut(PARTICLE_TOGGLE_WIRE))
			src.toggle_power()

	else if(href_list["scan"])
		src.part_scan()

	else if(href_list["strengthup"])
		if(!wires.IsIndexCut(PARTICLE_STRENGTH_WIRE))
			add_strength()

	else if(href_list["strengthdown"])
		if(!wires.IsIndexCut(PARTICLE_STRENGTH_WIRE))
			remove_strength()

	src.updateDialog()
	src.update_icon()
	return


/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/obj/structure/particle_accelerator/part in connected_parts)
		part.strength = strength
		part.update_icon()

/obj/machinery/particle_accelerator/control_box/proc/add_strength(s)
	if(assembled)
		strength++
		if(strength > strength_upper_limit)
			strength = strength_upper_limit
		else
			message_admins("PA Control Computer increased to [strength] by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("PA Control Computer increased to [strength] by [key_name(usr)] in ([x],[y],[z])")
			investigate_log("increased to <font color='red'>[strength]</font> by [key_name(usr)]","singulo")
		strength_change()

/obj/machinery/particle_accelerator/control_box/proc/remove_strength(s)
	if(assembled)
		strength--
		if(strength < 0)
			strength = 0
		else
			message_admins("PA Control Computer decreased to [strength] by [key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in ([x],[y],[z])")
			investigate_log("decreased to <font color='green'>[strength]</font> by [key_name(usr)]","singulo")
		strength_change()

/obj/machinery/particle_accelerator/control_box/power_change()
	..()
	if(stat & NOPOWER)
		active = 0
		use_power = 0
	else if(!stat && construction_state <= 3)
		use_power = 1
	return


/obj/machinery/particle_accelerator/control_box/process()
	if(src.active)
		//a part is missing!
		if( length(connected_parts) < 6 )
			investigate_log("lost a connected part; It <font color='red'>powered down</font>.","singulo")
			src.toggle_power()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			if(PE)
				PE.emit_particle(src.strength)
	return


/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	for(var/obj/structure/particle_accelerator/fuel_chamber/F in orange(1,src))
		src.dir = F.dir
	connected_parts = list()
	var/tally = 0
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	var/turf/T = src.loc
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/fuel_chamber))
		tally++
	T = get_step(T,odir)
	if(check_part(T,/obj/structure/particle_accelerator/end_cap))
		tally++
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/power_box))
		tally++
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/center))
		tally++
	T = get_step(T,ldir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/left))
		tally++
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/right))
		tally++
	if(tally >= 6)
		assembled = 1
		return 1
	else
		assembled = 0
		return 0


/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/T, type)
	if(!(T)||!(type))
		return 0
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type))
		if(PA.connect_master(src))
			if(PA.report_ready(src))
				src.connected_parts.Add(PA)
				return 1
	return 0


/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	src.active = !src.active
	investigate_log("turned [active?"<font color='red'>ON</font>":"<font color='green'>OFF</font>"] by [usr ? key_name(usr) : "outside forces"]","singulo")
	message_admins("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? key_name_admin(usr) : "outside forces"](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? "[key_name(usr)]" : "outside forces"] in ([x],[y],[z])")
	if(src.active)
		src.use_power = 2
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = src.strength
			part.powered = 1
			part.update_icon()
	else
		src.use_power = 1
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon()
	return 1


/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=pacontrol")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR><BR>"
	dat += "<h3>Status</h3>"
	if(!assembled)
		dat += "Unable to detect all parts!<BR>"
		dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"
	else
		dat += "All parts in place.<BR><BR>"
		dat += "Power:"
		if(active)
			dat += "On<BR>"
		else
			dat += "Off <BR>"
		dat += "<A href='?src=\ref[src];togglep=1'>Toggle Power</A><BR><BR>"
		dat += "Particle Strength: [src.strength] "
		dat += "<A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"

	//user << browse(dat, "window=pacontrol;size=420x500")
	//onclose(user, "pacontrol")
	var/datum/browser/popup = new(user, "pacontrol", name, 420, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return