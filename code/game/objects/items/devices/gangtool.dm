//gangtool device
//Allows gang leaders to recall the shuttle
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does just by looking."
	icon_state = "recaller"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	var/gang = "" //Which gang uses this?
	var/recalling = 0
	var/points = 3 //3 points to start with
	var/next_point_time = 0

/obj/item/device/gangtool/New()
	..()
	next_point_time = world.time + 900
	processing_objects.Add(src)

/obj/item/device/gangtool/process()
	if((points < 10) && (next_point_time < world.time))
		points++
		if(points < 10)
			var/gang_size = ((gang == "A")? ticker.mode.A_gangsters.len : ticker.mode.B_gangsters.len)
			next_point_time = world.time + 900 + (100 * gang_size)

/obj/item/device/gangtool/attack_self(mob/user)
	if (!can_use(user))
		return

	var/gang_size = ((gang == "A")? ticker.mode.A_gangsters.len : ticker.mode.B_gangsters.len)

	var/dat = "Client Organization: <B>[(gang == "A")?("[gang_name("A")] Gang"):("[gang_name("B")] Gang")]</B><br>"
	dat += "Organization Size: <B>[gang_size]</B><br>"
	dat += "<a href='?src=\ref[src];choice=recall'>Recall Emergency Shuttle</a><br>"
	dat += "<br>"
	dat += "Supply Points: <B>[points]</B><br>"
	dat += "Time until next supply point: <B>[(points >= 10) ? ("--:--") : (time2text(next_point_time - world.time, "mm:ss"))]</B><br>"
	dat += "<B>Purchase Items:</B><br>"

	if(points >= 3)
		dat += "(3 Points) <a href='?src=\ref[src];purchase=pistol'>10mm Pistol</a><br>"
	else
		dat += "(3 Points) 10mm Pistol<br>"

	if(points >= 1)
		dat += "(1 Point) <a href='?src=\ref[src];purchase=ammo'>10mm Ammo</a><br>"
	else
		dat += "(1 Point) 10mm Ammo<br>"

	if(points >= 6)
		dat += "(6 Points) <a href='?src=\ref[src];purchase=pen'>Recruitment Pen</a><br>"
	else
		dat += "(6 Points) Recruitment Pen<br>"

	dat += "<br>"
	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome, Boss, to your GangTool v0.2")
	popup.set_content(dat)
	popup.open()

/obj/item/device/gangtool/Topic(href, href_list)
	if(!can_use(usr))
		return

	add_fingerprint(usr)

	if(href_list["purchase"])
		var/obj/purchased
		switch(href_list["purchase"])
			if("pistol")
				if(points >= 3)
					purchased = new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(usr))
					points -= 3
			if("ammo")
				if(points >= 1)
					purchased = new /obj/item/ammo_box/magazine/m10mm(get_turf(usr))
					points -= 1
			if("pen")
				if(points >= 6)
					purchased = new /obj/item/weapon/pen/gang(get_turf(usr))
					points -= 6

		if(purchased)
			var/mob/living/carbon/human/H = usr
			H.put_in_any_hand_if_possible(purchased)

	else if(href_list["choice"] == "recall")
		recall(usr)

	attack_self(usr)

/obj/item/device/gangtool/proc/recall(mob/user)
	if(recalling || !can_use(user))
		return

	var/turf/userturf = get_turf(user)
	if(userturf.z != 1)
		user << "<span class='info'>\icon[src]Error: Device out of range of station communication arrays.</span>"
		return

	if(emergency_shuttle.location==0)
		if (emergency_shuttle.online)
			recalling = 1
			loc << "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>"
			sleep(rand(10,30))
			loc << "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>"
			sleep(rand(10,30))
			loc << "<span class='info'>\icon[src]Comm arrays accessed. Broadcasting recall signal...</span>"
			sleep(rand(10,30))
			recalling = 0
			log_game("[key_name(user)] has recalled the shuttle with a gangtool.")
			message_admins("[key_name_admin(user)] has recalled the shuttle with a gangtool.", 1)
			if(!cancel_call_proc(user))
				loc << "<span class='info'>\icon[src]No response recieved. Emergency shuttle cannot be recalled at this time.</span>"
			return
	user << "<span class='info'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>"

/obj/item/device/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.restrained() || user.lying || user.stat || user.stunned || user.weakened)
		return
	if(!(src in user.contents))
		return
	if(user.mind)
		switch(gang)
			if("A")
				if(user.mind in ticker.mode.A_bosses)
					. = "A"
			if("B")
				if(user.mind in ticker.mode.B_bosses)
					. = "B"
	return