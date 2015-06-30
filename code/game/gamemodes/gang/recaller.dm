//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does just by looking."
	icon_state = "gangtool"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	var/gang //Which gang uses this?
	var/boss = 1 //If this gangtool belongs to the big boss
	var/recalling = 0
	var/outfits = 3

/obj/item/device/gangtool/New() //Initialize supply point income if it hasn't already been started
	if(!ticker.mode.gang_points)
		ticker.mode.gang_points = new /datum/gang_points(ticker.mode)
		ticker.mode.gang_points.start()
	if(boss)
		desc += " Looks important."

/obj/item/device/gangtool/attack_self(mob/user)
	if (!can_use(user))
		return

	var/gang_bosses = ((gang == "A")? ticker.mode.A_bosses.len : ticker.mode.B_bosses.len)

	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		dat += "<a href='?src=\ref[src];register=1'>Register Device</a><br>"
	else
		var/datum/game_mode/gang/gangmode
		if(istype(ticker.mode, /datum/game_mode/gang))
			gangmode = ticker.mode

		var/gang_size = gang_bosses + ((gang == "A")? ticker.mode.A_gang.len : ticker.mode.B_gang.len)
		var/gang_territory = ((gang == "A")? ticker.mode.A_territory.len : ticker.mode.B_territory.len)
		var/points = ((gang == "A") ? ticker.mode.gang_points.A : ticker.mode.gang_points.B)
		var/timer
		if(gangmode)
			timer = ((gang == "A") ? gangmode.A_timer : gangmode.B_timer)
			if(isnum(timer))
				dat += "<center><font color='red'>Takeover In Progress:<br><B>[timer] seconds remain</B></font></center><br>"

		dat += "Registration: <B>[(gang == "A")? gang_name("A") : gang_name("B")] Gang [boss ? "Boss" : "Lieutenant"]</B><br>"
		dat += "Organization Size: <B>[gang_size]</B> | Station Control: <B>[round((gang_territory/start_state.num_territories)*100, 1)]%</B><br>"
		dat += "Gang Influence: <B>[points]</B> | Outfit Stock: <B>[outfits]</B><br>"
		dat += "Time until Influence grows: <B>[(points >= 999) ? ("--:--") : (time2text(ticker.mode.gang_points.next_point_time - world.time, "mm:ss"))]</B><br>"
		dat += "<hr>"
		dat += "<B>Gangtool Functions:</B><br>"

		dat += "<a href='?src=\ref[src];choice=ping'>Send Message to Gang</a><br>"
		if(outfits > 0)
			dat += "<a href='?src=\ref[src];choice=outfit'>Create Armored Gang Outfit</a><br>"
		else
			dat += "<b>Create Gang Outfit</b> (Restocking)<br>"
		if(gangmode && boss)
			dat += "<a href='?src=\ref[src];choice=recall'>Recall Emergency Shuttle</a><br>"

		dat += "<br>"
		dat += "<B>Purchase Weapons:</B><br>"

		/////////////////
		// NORMAL GANG //
		/////////////////

		if(!gangmode || (gang == "A" && gangmode.A_fighting_style == "normal") || (gang == "B" && gangmode.B_fighting_style == "normal")) //If the gamemode is not gang, always use standard loadout.
			dat += "(10 Influence) "
			if(points >= 10)
				dat += "<a href='?src=\ref[src];purchase=switchblade'>Switchblade</a><br>"
			else
				dat += "Switchblade<br>"

			dat += "(25 Influence) "
			if(points >= 25)
				dat += "<a href='?src=\ref[src];purchase=pistol'>10mm Pistol</a><br>"
			else
				dat += "10mm Pistol<br>"

			dat += "(10 Influence) "
			if(points >= 10)
				dat += "<a href='?src=\ref[src];purchase=10mmammo'>10mm Ammo</a><br>"
			else
				dat += "10mm Ammo<br>"

			dat += "(50 Influence) "
			if(points >= 50)
				dat += "<a href='?src=\ref[src];purchase=uzi'>Mini Uzi</a><br>"
			else
				dat += "Mini Uzi<br>"

			dat += "(20 Influence) "
			if(points >= 20)
				dat += "<a href='?src=\ref[src];purchase=9mmammo'>Uzi Ammo</a><br>"
			else
				dat += "Uzi Magazine<br>"

			dat += "<br>"

		//////////////////
		// MARTIAL ARTS //
		//////////////////

		else if((gang == "A" && gangmode.A_fighting_style == "martial") || (gang == "B" && gangmode.B_fighting_style == "martial"))
			dat += "(10 Influence) "
			if(points >= 10)
				dat += "<a href='?src=\ref[src];purchase=bostaff'>Bo Staff</a><br>"
			else
				dat += "Bo Staff<br>"

			dat += "(20 Influence) "
			if(points >= 20)
				dat += "<a href='?src=\ref[src];purchase=wrestlingbelt'>Wrestling Belt</a><br>"
			else
				dat += "Wrestling Belt<br>"

			dat += "(30 Influence) "
			if(points >= 30)
				dat += "<a href='?src=\ref[src];purchase=scroll'>Sleeping Carp Scroll (one-use)</a><br>"
			else
				dat += "Sleeping Carp Scroll (one-use)<br>"
			dat += "<br>"

		////////////////////////
		// STANDARD EQUIPMENT //
		////////////////////////

		dat += "<B>Purchase Equipment:</B><br>"

		dat += "(5 Influence) "
		if(points >= 5)
			dat += "<a href='?src=\ref[src];purchase=spraycan'>Territory Spraycan</a><br>"
		else
			dat += "Territory Spraycan<br>"

		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=C4'>C4 Explosive</a><br>"
		else
			dat += "C4 Explosive<br>"

		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=implant'>Implant Breaker</a><br>"
		else
			dat += "Implant Breaker<br>"

		dat += "(50 Influence) "
		if(points >= 50)
			dat += "<a href='?src=\ref[src];purchase=pen'>Recruitment Pen</a><br>"
		else
			dat += "Recruitment Pen<br>"

		dat += "(30 Influence) "
		if(points >= 30)
			dat += "<a href='?src=\ref[src];purchase=gangtool'>Spare Gangtool</a><br>"
		else
			dat += "Spare Gangtool<br>"

		if(gangmode)
			if(gang == "A" ? !gangmode.A_dominations : !gangmode.B_dominations)
				dat += "(Out of stock) Station Dominator"
			else
				dat += "(30 Influence) "
				if(points >= 30)
					dat += "<a href='?src=\ref[src];purchase=dominator'><b>Station Dominator</b></a><br>"
				else
					dat += "<b>Station Dominator</b><br>"
				dat += "<i>(Estimated Takeover Time: [round(max(300,900 - ((round((gang_territory/start_state.num_territories)*200, 10) - 60) * 15))/60,1)] minutes)</i><br>"

	dat += "<br>"
	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v2.2", 340, 620)
	popup.set_content(dat)
	popup.open()



/obj/item/device/gangtool/Topic(href, href_list)
	if(!can_use(usr))
		return

	add_fingerprint(usr)

	if(href_list["register"])
		register_device(usr)

	else if(!gang) //Gangtool must be registered before you can use the functions below
		return

	if(href_list["purchase"])
		var/points = ((gang == "A") ? ticker.mode.gang_points.A : ticker.mode.gang_points.B)
		var/item_type
		switch(href_list["purchase"])
			if("spraycan")
				if(points >= 5)
					item_type = /obj/item/toy/crayon/spraycan/gang
					points = 5
			if("switchblade")
				if(points >= 10)
					item_type = /obj/item/weapon/switchblade
					points = 10
			if("pistol")
				if(points >= 25)
					item_type = /obj/item/weapon/gun/projectile/automatic/pistol
					points = 25
			if("10mmammo")
				if(points >= 10)
					item_type = /obj/item/ammo_box/magazine/m10mm
					points = 10
			if("uzi")
				if(points >= 50)
					item_type = /obj/item/weapon/gun/projectile/automatic/mini_uzi
					points = 50
			if("9mmammo")
				if(points >= 20)
					item_type = /obj/item/ammo_box/magazine/uzim9mm
					points = 20
			if("scroll")
				if(points >= 30)
					item_type = /obj/item/weapon/sleeping_carp_scroll
					usr << "<span class='notice'>Anyone who reads the <b>sleeping carp scroll</b> will learn secrets of the sleeping carp martial arts style.</span>"
					points = 30
			if("wrestlingbelt")
				if(points >= 20)
					item_type = /obj/item/weapon/storage/belt/champion/wrestling
					usr << "<span class='notice'>Anyone wearing the <b>wresting belt</b> will know how to be effective with wrestling.</span>"
					points = 20
			if("bostaff")
				if(points >= 10)
					item_type = /obj/item/weapon/twohanded/bostaff
					points = 10
			if("C4")
				if(points >= 10)
					item_type = /obj/item/weapon/c4
					points = 10
			if("pen")
				if(points >= 50)
					item_type = /obj/item/weapon/pen/gang
					points = 50
			if("implant")
				if(points >= 10)
					item_type = /obj/item/weapon/implanter/gang
					usr << "<span class='notice'>The <b>implant breaker</b> destroys all other implants within the target before trying to recruit them to your gang. Implant is destroyed after one use.</span>"
					points = 10
			if("gangtool")
				if(points >= 30)
					item_type = /obj/item/device/gangtool/lt
					points = 30
			if("dominator")
				if(istype(ticker.mode, /datum/game_mode/gang))
					var/datum/game_mode/gang/mode = ticker.mode
					if(isnum((gang == "A") ? mode.A_timer : mode.B_timer))
						return

					if(gang == "A" ? !mode.A_dominations : !mode.B_dominations)
						return

					var/area/usrarea = get_area(usr.loc)
					var/usrturf = get_turf(usr.loc)
					if(initial(usrarea.name) == "Space" || istype(usrturf,/turf/space) || usr.z != 1)
						usr << "<span class='warning'>You can only use this on the station!</span>"
						return

					for(var/obj/obj in usrturf)
						if(obj.density)
							usr << "<span class='warning'>There's not enough room here!</span>"
							return

					if(points >= 30)
						item_type = /obj/machinery/dominator
						usr << "<span class='notice'>The <b>dominator</b> will secure your gang's dominance over the station. Turn it on when you are ready to defend it.</span>"
						points = 30

		if(item_type)
			if(gang == "A")
				ticker.mode.gang_points.A -= points
			else if(gang == "B")
				ticker.mode.gang_points.B -= points
			if(ispath(item_type))
				var/obj/purchased = new item_type(get_turf(usr),gang)
				var/mob/living/carbon/human/H = usr
				H.put_in_any_hand_if_possible(purchased)
			if(points)
				ticker.mode.message_gangtools(((gang=="A")? ticker.mode.A_tools : ticker.mode.B_tools), "A [href_list["purchase"]] was purchased by [usr] for [points] Influence.")
			log_game("A [href_list["purchase"]] was purchased by [key_name(usr)] for [points] Influence.")

		else
			usr << "<span class='warning'>Not enough influence.</span>"

	else if(href_list["choice"])
		switch(href_list["choice"])
			if("recall")
				if(boss)
					recall(usr)
			if("outfit")
				if(outfits > 0)
					if(ticker.mode.gang_outfit(usr,src,gang))
						outfits -= 1
			if("ping")
				ping_gang(usr)
	attack_self(usr)


/obj/item/device/gangtool/proc/ping_gang(var/mob/user)
	if(!user)
		return
	var/message = stripped_input(user,"Discreetly send a gang-wide message.","Send Message") as null|text
	if(!message || !can_use(user))
		return
	if(user.z > 2)
		user << "<span class='info'>\icon[src]Error: Station out of range.</span>"
		return
	var/list/members = list()
	if(gang == "A")
		members += ticker.mode.A_bosses | ticker.mode.A_gang
	else if(gang == "B")
		members += ticker.mode.B_bosses | ticker.mode.B_gang
	if(members.len)
		var/ping = "<span class='danger'><B><i>[gang_name(gang)] [boss ? "Gang Boss" : "Lieutenant"] [user.real_name]</i>: [message]</B></span>"
		for(var/datum/mind/ganger in members)
			if((ganger.current.z <= 2) && (ganger.current.stat == CONSCIOUS))
				ganger.current << ping
		for(var/mob/M in dead_mob_list)
			M << ping
		log_game("[key_name(user)] Messaged [gang_name(gang)] Gang ([gang]): [message].")


/obj/item/device/gangtool/proc/register_device(var/mob/user)
	if(user.mind in ticker.mode.A_bosses)
		ticker.mode.A_tools += src
		gang = "A"
		icon_state = "gangtool-a"
	else if(user.mind in ticker.mode.B_bosses)
		ticker.mode.B_tools += src
		gang = "B"
		icon_state = "gangtool-b"
	if(!gang)
		usr << "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>"

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!can_use(user))
		return 0

	if(!istype(ticker.mode, /datum/game_mode/gang))
		return 0

	var/datum/game_mode/gang/mode = ticker.mode
	mode.message_gangtools(((gang=="A")? ticker.mode.A_tools : ticker.mode.B_tools), "[usr] is attempting to recall the emergency shuttle.")
	recalling = 1
	loc << "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>"

	sleep(rand(100,300))

	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		user << "<span class='info'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>"
		recalling = 0
		return 0
	loc << "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>"

	sleep(rand(100,300))

	if(gang == "A" ? !mode.A_dominations : !mode.B_dominations)
		user << "<span class='info'>\icon[src]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>"
		recalling = 0
		return 0

	var/turf/userturf = get_turf(user)
	if(userturf.z != 1) //Shuttle can only be recalled while on station
		user << "<span class='info'>\icon[src]Error: Device out of range of station communication arrays.</span>"
		recalling = 0
		return 0
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	if((100 *  start_state.score(end_state)) < 70) //Shuttle cannot be recalled if the station is too damaged
		user << "<span class='info'>\icon[src]Error: Station communication systems compromised. Unable to establish connection.</span>"
		recalling = 0
		return 0
	loc << "<span class='info'>\icon[src]Comm arrays accessed. Broadcasting recall signal...</span>"

	sleep(rand(100,300))

	recalling = 0
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
	userturf = get_turf(user)
	if(userturf.z == 1) //Check one more time that they are on station.
		if(SSshuttle.cancelEvac(user))
			return 1

	loc << "<span class='info'>\icon[src]No response recieved. Emergency shuttle cannot be recalled at this time.</span>"
	return 0

/obj/item/device/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.restrained() || user.lying || user.stat || user.stunned || user.weakened)
		return
	if(!(src in user.contents))
		return

	var/success
	if(user.mind)
		if(gang)
			if((gang == "A") && (user.mind in ticker.mode.A_bosses))
				success = 1
			else if((gang == "B") && (user.mind in ticker.mode.B_bosses))
				success = 1
		else
			success = 1
	if(success)
		return 1
	user << "<span class='warning'>\icon[src] ACCESS DENIED: Unauthorized user.</span>"
	return 0

/obj/item/device/gangtool/lt
	boss = 0
	outfits = 1
