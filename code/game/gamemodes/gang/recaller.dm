//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2;syndicate=5"
	var/datum/gang/gang //Which gang uses this?
	var/recalling = 0
	var/outfits = 3
	var/free_pen = 0
	var/promotable = 0

/obj/item/device/gangtool/New() //Initialize supply point income if it hasn't already been started
	if(!ticker.mode.gang_points)
		ticker.mode.gang_points = new /datum/gang_points(ticker.mode)

/obj/item/device/gangtool/attack_self(mob/user)
	if (!can_use(user))
		return

	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		if(user.mind in ticker.mode.get_gang_bosses())
			if(promotable && user.mind.gang_datum.bosses.len < 3)
				dat += "Give this device to another member of your organization to use to promote them to Lieutenant.<br><br>"
				dat += "If this is meant as a spare device for yourself:<br>"
			dat += "<a href='?src=\ref[src];register=1'>Register Device as Spare</a><br>"
		else if (promotable)
			if(user.mind.gang_datum.bosses.len < 3)
				dat += "You have been selected for a promotion!<br>"
				dat += "<a href='?src=\ref[src];register=1'>Accept Promotion</a><br>"
			else
				dat += "No promotions available: All positions filled.<br>"
		else
			dat += "This device is not authorized to promote.<br>"
	else
		if(gang.is_dominating)
			dat += "<center><font color='red'>Takeover In Progress:<br><B>[gang.domination_time_remaining()] seconds remain</B></font></center>"

		var/isboss = (user.mind == gang.bosses[1])
		var/points = gang.points
		dat += "Registration: <B>[gang.name] Gang [isboss ? "Boss" : "Lieutenant"]</B><br>"
		dat += "Organization Size: <B>[gang.gangsters.len + gang.bosses.len]</B> | Station Control: <B>[round((gang.territory.len/start_state.num_territories)*100, 1)]%</B><br>"
		dat += "Gang Influence: <B>[points]</B><br>"
		dat += "Time until Influence grows: <B>[(points >= 999) ? ("--:--") : (time2text(ticker.mode.gang_points.next_point_time - world.time, "mm:ss"))]</B><br>"
		dat += "<hr>"
		dat += "<B>Gangtool Functions:</B><br>"

		dat += "<a href='?src=\ref[src];choice=ping'>Send Message to Gang</a><br>"
		if(outfits > 0)
			dat += "<a href='?src=\ref[src];choice=outfit'>Create Armored Gang Outfit</a><br>"
		else
			dat += "<b>Create Gang Outfit</b> (Restocking)<br>"
		if(isboss)
			dat += "<a href='?src=\ref[src];choice=recall'>Recall Emergency Shuttle</a><br>"

		dat += "<br>"
		dat += "<B>Purchase Weapons:</B><br>"

		/////////////////
		// NORMAL GANG //
		/////////////////

		if(gang.fighting_style == "normal")
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

			dat += "&nbsp;&#8627;(10 Influence) "
			if(points >= 10)
				dat += "<a href='?src=\ref[src];purchase=10mmammo'>10mm Ammo</a><br>"
			else
				dat += "10mm Ammo<br>"

			dat += "(60 Influence) "
			if(points >= 60)
				dat += "<a href='?src=\ref[src];purchase=uzi'>Uzi SMG</a><br>"
			else
				dat += "Uzi SMG<br>"

			dat += "&nbsp;&#8627;(40 Influence) "
			if(points >= 40)
				dat += "<a href='?src=\ref[src];purchase=9mmammo'>Uzi Ammo</a><br>"
			else
				dat += "Uzi Ammo<br>"

			dat += "(1 Influence) "
			if(points >=1)
				dat += "<a href='?src=\ref[src];purchase=necklace'>Dope Necklace</a><br>"
			else
				dat += "Dope Necklace<br>"

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

		dat += "(15 Influence) "
		if(points >= 15)
			dat += "<a href='?src=\ref[src];purchase=implant'>Implant Breaker</a><br>"
		else
			dat += "Implant Breaker<br>"

		if(free_pen)
			dat += "(GET ONE FREE) "
		else
			dat += "(50 Influence) "
		if((points >= 50)||free_pen)
			dat += "<a href='?src=\ref[src];purchase=pen'>Recruitment Pen</a><br>"
		else
			dat += "Recruitment Pen<br>"

		var/gangtooltext = "Spare Gangtool"
		if(isboss && gang.bosses.len < 3)
			gangtooltext = "Promote a Gangster"
		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=gangtool'>[gangtooltext]</a><br>"
		else
			dat += "[gangtooltext]<br>"

		if(!gang.dom_attempts)
			dat += "(Out of stock) Station Dominator<br>"
		else
			dat += "(30 Influence) "
			if(points >= 30)
				dat += "<a href='?src=\ref[src];purchase=dominator'><b>Station Dominator</b></a><br>"
			else
				dat += "<b>Station Dominator</b><br>"
			dat += "<i>(Estimated Takeover Time: [round(determine_domination_time(gang)/60,0.1)] minutes)</i><br>"

	dat += "<br>"
	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v3.2", 340, 625)
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
		var/pointcost
		var/item_type
		switch(href_list["purchase"])
			if("spraycan")
				if(gang.points >= 5)
					item_type = /obj/item/toy/crayon/spraycan/gang
					pointcost = 5
			if("switchblade")
				if(gang.points >= 10)
					item_type = /obj/item/weapon/switchblade
					pointcost = 10
			if("necklace")
				if(gang.points >=1)
					item_type = /obj/item/clothing/neck/necklace/dope
					pointcost = 1
			if("pistol")
				if(gang.points >= 25)
					item_type = /obj/item/weapon/gun/ballistic/automatic/pistol
					pointcost = 25
			if("10mmammo")
				if(gang.points >= 10)
					item_type = /obj/item/ammo_box/magazine/m10mm
					pointcost = 10
			if("uzi")
				if(gang.points >= 60)
					item_type = /obj/item/weapon/gun/ballistic/automatic/mini_uzi
					pointcost = 60
			if("9mmammo")
				if(gang.points >= 40)
					item_type = /obj/item/ammo_box/magazine/uzim9mm
					pointcost = 40
			if("scroll")
				if(gang.points >= 30)
					item_type = /obj/item/weapon/sleeping_carp_scroll
					usr << "<span class='notice'>Anyone who reads the <b>sleeping carp scroll</b> will learn secrets of the sleeping carp martial arts style.</span>"
					pointcost = 30
			if("wrestlingbelt")
				if(gang.points >= 20)
					item_type = /obj/item/weapon/storage/belt/champion/wrestling
					usr << "<span class='notice'>Anyone wearing the <b>wresting belt</b> will know how to be effective with wrestling.</span>"
					pointcost = 20
			if("bostaff")
				if(gang.points >= 10)
					item_type = /obj/item/weapon/twohanded/bostaff
					pointcost = 10
			if("C4")
				if(gang.points >= 10)
					item_type = /obj/item/weapon/grenade/plastic/c4
					pointcost = 10
			if("pen")
				if((gang.points >= 50) || free_pen)
					item_type = /obj/item/weapon/pen/gang
					usr << "<span class='notice'>More <b>recruitment pens</b> will allow you to recruit gangsters faster. Only gang leaders can recruit with pens.</span>"
					if(free_pen)
						free_pen = 0
					else
						pointcost = 50
			if("implant")
				if(gang.points >= 15)
					item_type = /obj/item/weapon/implanter/gang
					usr << "<span class='notice'>The <b>implant breaker</b> is a single-use device that destroys all implants within the target before trying to recruit them to your gang. Also works on enemy gangsters.</span>"
					pointcost = 15
			if("gangtool")
				if(gang.points >= 10)
					if(usr.mind == gang.bosses[1])
						item_type = /obj/item/device/gangtool/spare/lt
						if(gang.bosses.len < 3)
							usr << "<span class='notice'><b>Gangtools</b> allow you to promote a gangster to be your Lieutenant, enabling them to recruit and purchase items like you. Simply have them register the gangtool. You may promote up to [3-gang.bosses.len] more Lieutenants</span>"
					else
						item_type = /obj/item/device/gangtool/spare/
					pointcost = 10
			if("dominator")
				if(!gang.dom_attempts)
					return

				var/area/usrarea = get_area(usr.loc)
				var/usrturf = get_turf(usr.loc)
				if(initial(usrarea.name) == "Space" || isspaceturf(usrturf) || usr.z != 1)
					usr << "<span class='warning'>You can only use this on the station!</span>"
					return

				for(var/obj/obj in usrturf)
					if(obj.density)
						usr << "<span class='warning'>There's not enough room here!</span>"
						return

				if(usrarea.type in gang.territory|gang.territory_new)
					if(gang.points >= 30)
						item_type = /obj/machinery/dominator
						usr << "<span class='notice'>The <b>dominator</b> will secure your gang's dominance over the station. Turn it on when you are ready to defend it.</span>"
						pointcost = 30
				else
					usr << "<span class='warning'>The <b>dominator</b> can be spawned only on territory controlled by your gang!</span>"
					return

		if(item_type)
			gang.points -= pointcost
			if(ispath(item_type))
				var/obj/purchased = new item_type(get_turf(usr),gang)
				var/mob/living/carbon/human/H = usr
				H.put_in_hands(purchased)
				if(pointcost)
					gang.message_gangtools("A [href_list["purchase"]] was purchased by [usr.real_name] for [pointcost] Influence.")
			log_game("A [href_list["purchase"]] was purchased by [key_name(usr)] ([gang.name] Gang) for [pointcost] Influence.")

		else
			usr << "<span class='warning'>Not enough influence.</span>"

	else if(href_list["choice"])
		switch(href_list["choice"])
			if("recall")
				if(usr.mind == gang.bosses[1])
					recall(usr)
			if("outfit")
				if(outfits > 0)
					if(gang.gang_outfit(usr,src))
						usr << "<span class='notice'><b>Gang Outfits</b> can act as armor with moderate protection against ballistic and melee attacks. Every gangster wearing one will also help grow your gang's influence.</span>"
						outfits -= 1
			if("ping")
				ping_gang(usr)
	attack_self(usr)


/obj/item/device/gangtool/proc/ping_gang(mob/user)
	if(!user)
		return
	var/message = stripped_input(user,"Discreetly send a gang-wide message.","Send Message") as null|text
	if(!message || !can_use(user))
		return
	if(user.z > 2)
		user << "<span class='info'>\icon[src]Error: Station out of range.</span>"
		return
	var/list/members = list()
	members += gang.gangsters
	members += gang.bosses
	if(members.len)
		var/gang_rank = gang.bosses.Find(user.mind)
		switch(gang_rank)
			if(1)
				gang_rank = "Gang Boss"
			if(2)
				gang_rank = "1st Lieutenant"
			if(3)
				gang_rank = "2nd Lieutenant"
			if(4)
				gang_rank = "3rd Lieutenant"
			else
				gang_rank = "[gang_rank - 1]th Lieutenant"
		var/ping = "<span class='danger'><B><i>[gang.name] [gang_rank]</i>: [message]</B></span>"
		for(var/datum/mind/ganger in members)
			if(ganger.current && (ganger.current.z <= 2) && (ganger.current.stat == CONSCIOUS))
				ganger.current << ping
		for(var/mob/M in dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			M << "[link] [ping]"
		log_game("[key_name(user)] Messaged [gang.name] Gang: [message].")


/obj/item/device/gangtool/proc/register_device(mob/user)
	if(gang)	//It's already been registered!
		return
	if((promotable && (user.mind in ticker.mode.get_gangsters())) || (user.mind in ticker.mode.get_gang_bosses()))
		gang = user.mind.gang_datum
		gang.gangtools += src
		icon_state = "gangtool-[gang.color]"
		if(!(user.mind in gang.bosses))
			ticker.mode.remove_gangster(user.mind, 0, 2)
			gang.bosses += user.mind
			user.mind.gang_datum = gang
			user.mind.special_role = "[gang.name] Gang Lieutenant"
			gang.add_gang_hud(user.mind)
			log_game("[key_name(user)] has been promoted to Lieutenant in the [gang.name] Gang")
			free_pen = 1
			gang.message_gangtools("[user] has been promoted to Lieutenant.")
			user << "<FONT size=3 color=red><B>You have been promoted to Lieutenant!</B></FONT>"
			ticker.mode.forge_gang_objectives(user.mind)
			ticker.mode.greet_gang(user.mind,0)
			user << "The <b>Gangtool</b> you registered will allow you to purchase weapons and equipment, and send messages to your gang."
			user << "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool."
	else
		usr << "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>"

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!can_use(user))
		return 0

	if(recalling)
		usr << "<span class='warning'>Error: Recall already in progress.</span>"
		return 0

	gang.message_gangtools("[usr] is attempting to recall the emergency shuttle.")
	recalling = 1
	loc << "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>"

	sleep(rand(100,300))

	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		user << "<span class='warning'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>"
		recalling = 0
		return 0
	loc << "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>"

	sleep(rand(100,300))

	if(!gang.dom_attempts)
		user << "<span class='warning'>\icon[src]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>"
		recalling = 0
		return 0

	var/turf/userturf = get_turf(user)
	if(userturf.z != 1) //Shuttle can only be recalled while on station
		user << "<span class='warning'>\icon[src]Error: Device out of range of station communication arrays.</span>"
		recalling = 0
		return 0
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	if((100 *  start_state.score(end_state)) < 80) //Shuttle cannot be recalled if the station is too damaged
		user << "<span class='warning'>\icon[src]Error: Station communication systems compromised. Unable to establish connection.</span>"
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
		return 0
	if(user.restrained() || user.lying || user.stat || user.stunned || user.weakened)
		return 0
	if(!(src in user.contents))
		return 0
	if(!user.mind)
		return 0

	if(gang)	//If it's already registered, only let the gang's bosses use this
		if(user.mind in gang.bosses)
			return 1
	else	//If it's not registered, any gangster can use this to register
		if(user.mind in ticker.mode.get_all_gangsters())
			return 1

	return 0

/obj/item/device/gangtool/spare
	outfits = 1

/obj/item/device/gangtool/spare/lt
	promotable = 1
