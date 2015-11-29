//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/pod
	name = "Mass Drivers and Pod Doors Control"
	desc = "A controll for launching pods. Some people prefer firing Mechas."
	icon_state = "mass_drivers"
	circuit = /obj/item/weapon/circuitboard/pod
	var/list/id_tags = list()
	var/list/door_only_tags = list()
	var/list/synced = list()
	var/list/timings = list()
	var/list/times = list()
	var/list/maxtimes = list()
	var/list/powers = list()
	var/list/loopings = list()
	var/default_time = 30
	var/default_loop = 0
	var/default_timings = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/pod/New()
	..()
	spawn(5)
		driver_sync()
	machines += src
	return

/obj/machinery/computer/pod/proc/driver_sync()
	timings = list()
	times = list()
	synced = list()
	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		for(var/ident_tag in id_tags)
			if((M.id_tag == ident_tag) && !(ident_tag in synced))
				synced += ident_tag
				timings += ident_tag
				timings[ident_tag] = default_timings
				times += ident_tag
				times[ident_tag] = default_time
				maxtimes += ident_tag
				maxtimes[ident_tag] = default_time
				powers += ident_tag
				powers[ident_tag] = 1.0
				loopings += ident_tag
				loopings[ident_tag] = default_loop
				break
	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.z != src.z)	continue
		for(var/ident_tag in id_tags)
			if((M.id_tag == ident_tag) && !(ident_tag in synced) && !(ident_tag in door_only_tags))
				door_only_tags += ident_tag
				break

	return

/obj/machinery/computer/pod/proc/solo_sync(var/ident_tag)
	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		if((M.id_tag == ident_tag) && !(ident_tag in synced))
			synced += ident_tag
			timings += ident_tag
			timings[ident_tag] = 0.0
			times += ident_tag
			times[ident_tag] = default_time
			maxtimes += ident_tag
			maxtimes[ident_tag] = default_time
			powers += ident_tag
			powers[ident_tag] = 1.0
			loopings += ident_tag
			loopings[ident_tag] = default_loop
			break
	if(!(ident_tag in synced))
		for(var/obj/machinery/door/poddoor/M in poddoors)
			if(M.z != src.z)	continue
			if((M.id_tag == ident_tag) && !(ident_tag in synced) && !(ident_tag in door_only_tags))
				door_only_tags += ident_tag
				break

	return


/obj/machinery/computer/pod/proc/launch_sequence(var/ident_tag)
	if(stat & (NOPOWER|BROKEN))
		return
	var/anydriver = 0
	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			anydriver = 1
	if(!anydriver)
		visible_message("Cannot locate any mass driver of that ID. Cancelling firing sequence!")
		return

	if(icon_state != "old")
		flick("mass_drivers_timing", src)

	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			spawn()
				M.open()
	sleep(20)


	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			M.drive()

	sleep(50)
	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			spawn()
				M.close()
	return


/obj/machinery/computer/pod/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	return attack_hand(user)


/obj/machinery/computer/pod/attack_paw(var/mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/pod/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>[name]</B>(<A href='?src=\ref[src];rename=1'>rename</A>)"
	user.set_machine(src)
	dat += "<BR><A href = '?src=\ref[src];sync=1'>Reset Connections</A><BR>"
	if(synced.len)
		dat += "<BR><A href = '?src=\ref[src];massfire=1'><B>Fire All Connected Drivers</B></A><BR>"
	if(istype(src,/obj/machinery/computer/pod/deathsquad))
		dat += "<BR><A href = '?src=\ref[src];teleporter=1'><B>Set Teleporter Destination Z-Level</B></A><BR>"
	for(var/ident_tag in id_tags)
		if(!(ident_tag in door_only_tags))
			dat += "<BR><BR><B>[ident_tag]</B> <A href='?src=\ref[src];remove=1;driver=[ident_tag]'>remove</A>"
		if(ident_tag in synced)
			var/d2 = ""
			if(timings[ident_tag])	//door controls do not need timers.
				d2 = "<A href='?src=\ref[src];time=0;driver=[ident_tag]'>Stop Time Launch</A>"
			else
				d2 = "<A href='?src=\ref[src];time=1;driver=[ident_tag]'>Initiate Time Launch</A>"
			var/second = times[ident_tag] % 60
			var/minute = (times[ident_tag] - second) / 60
			var/maxsecond = maxtimes[ident_tag] % 60
			var/maxminute = (maxtimes[ident_tag] - maxsecond) / 60
			dat += "<HR>\nTimer System: [d2]\nTime Left: [minute ? "[minute]:" : null][second]/[maxminute ? "[maxminute]:" : null][maxsecond] <A href='?src=\ref[src];tp=-30;driver=[ident_tag]'>-</A> <A href='?src=\ref[src];tp=-1;driver=[ident_tag]'>-</A> <A href='?src=\ref[src];tp=1;driver=[ident_tag]'>+</A> <A href='?src=\ref[src];tp=30;driver=[ident_tag]'>+</A>"
			dat += "<BR>Set timer to loop: [loopings[ident_tag] ? "<A href = '?src=\ref[src];loop=0;driver=[ident_tag]'>Yes</A>" : "<A href = '?src=\ref[src];loop=1;driver=[ident_tag]'>No</A>"]"
			var/temp = ""
			var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
			for(var/t in L)
				if( powers[ident_tag] == t)
					temp += "<B><A href = '?src=\ref[src];power=[t];driver=[ident_tag]'>[t]</A></B> "
				else
					temp += "<A href = '?src=\ref[src];power=[t];driver=[ident_tag]'>[t]</A> "
			dat += "<HR>\nPower Level: [temp]<BR>\n<A href = '?src=\ref[src];launch=1;driver=[ident_tag]'><B>Fire Drive!</B></A><BR>\n<A href = '?src=\ref[src];door=1;driver=[ident_tag]'>Toggle Pod Doors</A><BR>"

	for(var/ident_tag in door_only_tags)
		dat += "<BR><BR><B>[ident_tag]</B> <A href='?src=\ref[src];remove=1;driver=[ident_tag]'>remove</A>"
		dat += "<BR>\n<A href = '?src=\ref[src];door=1;driver=[ident_tag]'>Toggle Pod Doors</A><BR>"

	dat += "<BR><A href='?src=\ref[src];add=1'>add another id_tag</A>"

	dat += "<BR><BR><A href='?src=\ref[user];mach_close=computer'>Close</A></TT></BODY></HTML>"
	user << browse(dat, "window=computer;size=400x500")
	add_fingerprint(usr)
	onclose(user, "computer")
	return

/obj/machinery/computer/pod/process()
	if(!..())
		return
	var/timing = 0
	for(var/ident_tag in id_tags)
		if(timings[ident_tag])
			if(times[ident_tag] > 0)
				times[ident_tag] = round(times[ident_tag]) - 1
				timing = 1
			else
				spawn()
					launch_sequence(ident_tag)
				if(loopings[ident_tag])
					times[ident_tag] = maxtimes[ident_tag]
				else
					times[ident_tag] = 0
					timings[ident_tag] = 0
		else
			times[ident_tag] = maxtimes[ident_tag]
		updateDialog()

	if(icon_state != "old")
		if(timing)
			icon_state = "mass_drivers_timing"
		else
			icon_state = "mass_drivers"
	return


/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)
		if(href_list["add"])
			var/new_id_tag = input("Enter a new id_tag", "Mass Driver Controls", "id_tag")
			if(!(new_id_tag in id_tags))
				id_tags += new_id_tag
				solo_sync(new_id_tag)
		if(href_list["remove"])
			var/ident_tag = href_list["driver"]
			if(ident_tag in synced)
				synced -= ident_tag
			if(ident_tag in door_only_tags)
				door_only_tags -= ident_tag
			timings -= ident_tag
			times -= ident_tag
			powers -= ident_tag
			loopings -= ident_tag
			id_tags -= ident_tag
		if(href_list["teleporter"])
			var/choices = list(0)
			choices += accessable_z_levels
			var/obj/machinery/computer/pod/deathsquad/D = src
			D.teleporter_dest = input("Enter the destination Z-Level. The mechs will arrive from the East. Leave 0 if you don't want to set a specific ZLevel", "Mass Driver Controls", "ZLevel") in choices

		if(href_list["massfire"])
			for(var/ident_tag in synced)
				spawn()
					launch_sequence(ident_tag)
		if(href_list["power"])
			var/ident_tag = href_list["driver"]
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			for(var/obj/machinery/mass_driver/M in mass_drivers)
				if(M.id_tag == ident_tag)
					M.power = t
			powers[ident_tag] = t
		if(href_list["launch"])
			launch_sequence(href_list["driver"])
		if(href_list["time"])
			var/ident_tag = href_list["driver"]
			timings[ident_tag] = text2num(href_list["time"])
		if(href_list["loop"])
			var/ident_tag = href_list["driver"]
			loopings[ident_tag] = text2num(href_list["loop"])
		if(href_list["sync"])
			driver_sync()
		if(href_list["tp"])
			var/ident_tag = href_list["driver"]
			var/tp = text2num(href_list["tp"])
			maxtimes[ident_tag] += tp
			maxtimes[ident_tag] = min(max(round(maxtimes[ident_tag]), 0), 120)
		if(href_list["door"])
			var/ident_tag = href_list["driver"]
			for(var/obj/machinery/door/poddoor/M in poddoors)
				if(M.z != src.z)	continue
				if(M.id_tag == ident_tag)
					spawn()
						if(M.density)
							M.open()
						else
							M.close()
		if(href_list["rename"])
			var/new_title = input("Enter a new title", "[name]", "[name]")
			if(new_title)
				name = new_title
		updateUsrDialog()
	return



/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "DoorMex Control Computer"
	circuit = /obj/item/weapon/circuitboard/olddoor


/obj/machinery/computer/pod/old/syndicate
	name = "External Airlock Controls"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."
	req_access = list(access_syndicate)
	circuit = /obj/item/weapon/circuitboard/syndicatedoor
	light_color = null

/obj/machinery/computer/pod/old/syndicate/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied</span>")
		return
	else
		..()

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"
	circuit = /obj/item/weapon/circuitboard/swfdoor


/obj/machinery/computer/pod/deathsquad
	id_tags = list("ASSAULT0","ASSAULT1","ASSAULT2","ASSAULT3")
	var/teleporter_dest = 0
	circuit = /obj/item/weapon/circuitboard/pod/deathsquad

/obj/machinery/computer/pod/deathsquad/launch_sequence(var/ident_tag)
	if(stat & (NOPOWER|BROKEN))
		return
	var/anydriver = 0
	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			anydriver = 1
	if(!anydriver)
		visible_message("Cannot locate any mass driver of that ID. Cancelling firing sequence!")
		return

	if(icon_state != "old")
		flick("mass_drivers_timing", src)

	if(teleporter_dest)
		for(var/obj/structure/deathsquad_tele/D in world)
			if(D.z != src.z)	continue
			if(D.id_tag == ident_tag)
				D.icon_state = "tele1"
				D.ztarget = teleporter_dest
				D.density = 1

	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			spawn()
				M.open()
	sleep(20)

	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			M.drive()

	sleep(50)
	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.z != src.z)	continue
		if(M.id_tag == ident_tag)
			spawn()
				M.close()

	for(var/obj/structure/deathsquad_tele/D in world)
		if(D.z != src.z)	continue
		if(D.id_tag == ident_tag)
			D.icon_state = "tele0"
			D.density = 0

	return

/obj/structure/deathsquad_tele
	name = "Mech Teleporter"
	density = 0
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele0"
	var/ztarget = 0
	var/id_tag = ""


/obj/structure/deathsquad_tele/Bumped(var/atom/movable/AM)
	if(!ztarget)	return ..()
	var/y = AM.y
	spawn()
		AM.z = ztarget
		AM.y = y
		AM.x = world.maxx - TRANSITIONEDGE - 2
		AM.dir = 8
		var/atom/target = get_edge_target_turf(AM, AM.dir)
		AM.throw_at(target, 50, AM.throw_speed)
	return

//The automatic mass driver control in taxi's delivery office, controls the disposals network.
/obj/machinery/computer/pod/disposal
	name = "Disposal Network Mass Driver Control Computer"
	default_loop = 1
	default_time = 10
	default_timings = 1
	id_tags = list("disposal_network")
