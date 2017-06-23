//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2;syndicate=5"
	var/datum/gang/gang //Which gang uses this?
	var/recalling = 0
	var/outfits = 2
	var/free_pen = 0
	var/promotable = 0
	var/list/tags = list()

/obj/item/device/gangtool/Initialize() //Initialize supply point income if it hasn't already been started
	..()
	if(!SSticker.mode.gang_points)
		SSticker.mode.gang_points = new /datum/gang_points(SSticker.mode)

/obj/item/device/gangtool/attack_self(mob/user)
	if (!can_use(user))
		return

	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		if(user.mind in SSticker.mode.get_gang_bosses())
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
		dat += "Registration: <B>[gang.name] Gang [isboss ? "Boss" : "Lieutenant"]</B><br>"
		dat += "Organization Size: <B>[gang.gangsters.len + gang.bosses.len]</B> | Station Control: <B>[round((gang.territory.len/GLOB.start_state.num_territories)*100, 1)]%</B><br>"
		dat += "Your Influence: <B>[gang.get_influence(user.mind)]</B><br>"
		dat += "Time until Influence grows: <B>[time2text(SSticker.mode.gang_points.next_point_time - world.time, "mm:ss")]</B><br>"
		dat += "<hr>"


		for(var/cat in gang.boss_category_list)
			dat += "<b>[cat]</b><br>"
			for(var/V in gang.boss_category_list[cat])
				var/datum/gang_item/G = V
				if(!G.can_see(user, gang, src))
					continue

				var/cost = G.get_cost_display(user, gang, src)
				if(cost)
					dat += cost + " "

				var/toAdd = G.get_name_display(user, gang, src)
				if(G.can_buy(user, gang, src))
					toAdd = "<a href='?src=\ref[src];purchase=[G.id]'>[toAdd]</a>"
				dat += toAdd
				var/extra = G.get_extra_info(user, gang, src)
				if(extra)
					dat += "<br><i>[extra]</i>"
				dat += "<br>"
			dat += "<br>"

	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v3.5", 340, 625)
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
		var/datum/gang_item/G = gang.boss_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)

	attack_self(usr)


/obj/item/device/gangtool/proc/ping_gang(mob/user)
	if(!user)
		return
	var/message = stripped_input(user,"Discreetly send a gang-wide message.","Send Message") as null|text
	if(!message || !can_use(user))
		return
	if(user.z > 2)
		to_chat(user, "<span class='info'>[bicon(src)]Error: Station out of range.</span>")
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
				to_chat(ganger.current, ping)
		for(var/mob/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [ping]")
		log_game("[key_name(user)] Messaged [gang.name] Gang: [message].")


/obj/item/device/gangtool/proc/register_device(mob/user)
	if(gang)	//It's already been registered!
		return
	if((promotable && (user.mind in SSticker.mode.get_gangsters())) || (user.mind in SSticker.mode.get_gang_bosses()))
		gang = user.mind.gang_datum
		gang.gangtools += src
		icon_state = "gangtool-[gang.color]"
		if(!(user.mind in gang.bosses))
			var/cached_influence = gang.gangsters[user.mind]
			SSticker.mode.remove_gangster(user.mind, 0, 2)
			gang.bosses[user.mind] = cached_influence
			user.mind.gang_datum = gang
			user.mind.special_role = "[gang.name] Gang Lieutenant"
			gang.add_gang_hud(user.mind)
			log_game("[key_name(user)] has been promoted to Lieutenant in the [gang.name] Gang")
			free_pen = 1
			gang.message_gangtools("[user] has been promoted to Lieutenant.")
			to_chat(user, "<FONT size=3 color=red><B>You have been promoted to Lieutenant!</B></FONT>")
			SSticker.mode.forge_gang_objectives(user.mind)
			SSticker.mode.greet_gang(user.mind,0)
			to_chat(user, "The <b>Gangtool</b> you registered will allow you to purchase weapons and equipment, and send messages to your gang.")
			to_chat(user, "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool.")
	else
		to_chat(usr, "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>")

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!can_use(user))
		return 0

	if(SSshuttle.emergencyNoRecall)
		return 0

	if(recalling)
		to_chat(usr, "<span class='warning'>Error: Recall already in progress.</span>")
		return 0

	if(!gang.recalls)
		to_chat(usr, "<span class='warning'>Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")

	gang.message_gangtools("[usr] is attempting to recall the emergency shuttle.")
	recalling = 1
	to_chat(loc, "<span class='info'>[bicon(src)]Generating shuttle recall order with codes retrieved from last call signal...</span>")

	sleep(rand(100,300))

	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		to_chat(user, "<span class='warning'>[bicon(src)]Emergency shuttle cannot be recalled at this time.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>[bicon(src)]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")

	sleep(rand(100,300))

	if(!gang.dom_attempts)
		to_chat(user, "<span class='warning'>[bicon(src)]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		recalling = 0
		return 0

	var/turf/userturf = get_turf(user)
	if(userturf.z != ZLEVEL_STATION) //Shuttle can only be recalled while on station
		to_chat(user, "<span class='warning'>[\bicon(src)]Error: Device out of range of station communication arrays.</span>")
		recalling = 0
		return 0
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	if((100 * GLOB.start_state.score(end_state)) < 80) //Shuttle cannot be recalled if the station is too damaged
		to_chat(user, "<span class='warning'>[bicon(src)]Error: Station communication systems compromised. Unable to establish connection.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>[bicon(src)]Comm arrays accessed. Broadcasting recall signal...</span>")

	sleep(rand(100,300))

	recalling = 0
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
	userturf = get_turf(user)
	if(userturf.z == ZLEVEL_STATION) //Check one more time that they are on station.
		if(SSshuttle.cancelEvac(user))
			gang.recalls -= 1
			return 1

	to_chat(loc, "<span class='info'>[bicon(src)]No response recieved. Emergency shuttle cannot be recalled at this time.</span>")
	return 0

/obj/item/device/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return 0
	if(user.restrained() || user.lying || user.stat || user.IsStun() || user.knockdown)
		return 0
	if(!(src in user.contents))
		return 0
	if(!user.mind)
		return 0
	if(gang && (user.mind in gang.bosses))	//If it's already registered, only let the gang's bosses use this
		return 1
	else if(user.mind in SSticker.mode.get_all_gangsters()) // For soldiers and potential LT's
		return 1
	return 0

/obj/item/device/gangtool/spare
	outfits = 1

/obj/item/device/gangtool/spare/lt
	promotable = 1

///////////// Internal tool used by gang regulars ///////////

/obj/item/device/gangtool/soldier/New(mob/user)
	. = ..()
	gang = user.mind.gang_datum
	gang.gangtools += src
	var/datum/action/innate/gang/tool/GT = new
	GT.Grant(user, src, gang)

/obj/item/device/gangtool/soldier/attack_self(mob/user)
	if (!can_use(user))
		return
	var/dat
	if(gang.is_dominating)
		dat += "<center><font color='red'>Takeover In Progress:<br><B>[gang.domination_time_remaining()] seconds remain</B></font></center>"
	dat += "Registration: <B>[gang.name] - Foot Soldier</B><br>"
	dat += "Organization Size: <B>[gang.gangsters.len + gang.bosses.len]</B> | Station Control: <B>[round((gang.territory.len/GLOB.start_state.num_territories)*100, 1)]%</B><br>"
	dat += "Your Influence: <B>[gang.get_influence(user.mind)]</B><br>"
	if(LAZYLEN(tags))
		dat += "Your tags generate bonus influence for you.<br> You have tagged the following territories:"
		for(var/obj/effect/decal/cleanable/crayon/gang/T in tags)
			dat += " [T.territory] -"
	else
		dat += "You have not personally tagged any territory for your gang. Use a spray can to mark your territory and receive bonus influence."
	dat += "<br>Time until Influence grows: <B>[time2text(SSticker.mode.gang_points.next_point_time - world.time, "mm:ss")]</B><br>"
	dat += "<hr>"
	for(var/cat in gang.reg_category_list)
		dat += "<b>[cat]</b><br>"
		for(var/V in gang.reg_category_list[cat])
			var/datum/gang_item/G = V
			if(!G.can_see(user, gang, src))
				continue

			var/cost = G.get_cost_display(user, gang, src)
			if(cost)
				dat += cost + " "

			var/toAdd = G.get_name_display(user, gang, src)
			if(G.can_buy(user, gang, src))
				toAdd = "<a href='?src=\ref[src];purchase=[G.id]'>[toAdd]</a>"
			dat += toAdd
			var/extra = G.get_extra_info(user, gang, src)
			if(extra)
				dat += "<br><i>[extra]</i>"
			dat += "<br>"
		dat += "<br>"

	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v3.5", 340, 625)
	popup.set_content(dat)
	popup.open()

/obj/item/device/gangtool/soldier/Topic(href, href_list)
	if(!can_use(usr))
		return
	if(href_list["purchase"])
		var/datum/gang_item/G = gang.reg_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)

	attack_self(usr)

/datum/action/innate/gang
	background_icon_state = "bg_spell"

/datum/action/innate/gang/IsAvailable()
	if(!owner.mind || !owner.mind in SSticker.mode.get_all_gangsters())
		return 0
	return ..()

/datum/action/innate/gang/tool
	name = "Personal Gang Tool"
	desc = "An implanted gang tool that lets you purchase gear"
	background_icon_state = "bg_mime"
	button_icon_state = "bolt_action"
	var/obj/item/device/gangtool/soldier/GT

/datum/action/innate/gang/tool/Grant(mob/user, obj/reg, datum/gang/G)
	. = ..()
	GT = reg
	button.color = G.color

/datum/action/innate/gang/tool/Activate()
	GT.attack_self(owner)
