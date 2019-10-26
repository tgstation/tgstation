//gangtool device
/obj/item/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	var/datum/team/gang/gang //Which gang uses this?
	var/recalling = 0
	var/outfits = 2
	var/free_pen = 0
	var/promotable = FALSE
	var/list/buyable_items = list()
	var/list/tags = list()
	var/flag = GANGS

/obj/item/gangtool/Initialize()
	. = ..()
	update_icon()
	for(var/i in subtypesof(/datum/gang_item))
		var/datum/gang_item/G = i
		var/id = initial(G.id)
		var/cat = initial(G.category)
		if(!(initial(G.mode_flags) & flag))
			continue
		if(id)
			if(!islist(buyable_items[cat]))
				buyable_items[cat] = list()
			buyable_items[cat][id] = new G

/obj/item/gangtool/Destroy()
	if(gang)
		gang.gangtools -= src
	return ..()

/obj/item/gangtool/attack_self(mob/user)
	if(!can_use(user))
		return FALSE
	user.set_machine(src)
	interact(user)
	return TRUE

/obj/item/gangtool/interact(mob/user)
	return ui_interact(user)

/obj/item/gangtool/ui_interact(mob/user)
	. = ..()
	var/datum/antagonist/gang/boss/L = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		if(L)
			if(promotable && L.gang.leaders.len < L.gang.max_leaders)
				dat += "Give this device to another member of your organization to use to promote them to Lieutenant.<br><br>"
				dat += "If this is meant as a spare device for yourself:<br>"
			dat += "<a href='?src=[REF(src)];register=1'>Register Device as Spare</a><br>"
		else if(promotable)
			var/datum/antagonist/gang/sweet = user.mind.has_antag_datum(/datum/antagonist/gang)
			if(sweet.gang.leaders.len < sweet.gang.max_leaders)
				dat += "You have been selected for a promotion!<br>"
				dat += "<a href='?src=[REF(src)];register=1'>Accept Promotion</a><br>"
			else
				dat += "No promotions available: All positions filled.<br>"
		else
			dat += "This device is not authorized to promote.<br>"
	else
		if(gang.domination_time != NOT_DOMINATING)
			dat += "<center><font color='red'>Takeover In Progress:<br><B>[DisplayTimeText(gang.domination_time_remaining() * 10)] remain</B></font></center>"

		dat += "Registration: <B>[gang.name] Gang Boss</B><br>"
		dat += "Organization Size: <B>[gang.members.len]</B> | Station Control: <B>[gang.territories.len] territories under control.</B> | Influence: <B>[gang.influence]</B><br>"
		dat += "Time until Influence grows: <B>[time2text(gang.next_point_time - world.time, "mm:ss")]</B><br>"
		dat += "<a href='?src=[REF(src)];commute=1'>Send message to Gang</a><br>"
		dat += "<a href='?src=[REF(src)];recall=1'>Recall shuttle</a><br>"
		dat += "<hr>"
		for(var/cat in buyable_items)
			dat += "<b>[cat]</b><br>"
			for(var/id in buyable_items[cat])
				var/datum/gang_item/G = buyable_items[cat][id]
				if(!G.can_see(user, gang, src))
					continue

				var/cost = G.get_cost_display(user, gang, src)
				if(cost)
					dat += cost + " "

				var/toAdd = G.get_name_display(user, gang, src)
				if(G.can_buy(user, gang, src))
					toAdd = "<a href='?src=[REF(src)];purchase=1;id=[id];cat=[cat]'>[toAdd]</a>"
				dat += toAdd
				var/extra = G.get_extra_info(user, gang, src)
				if(extra)
					dat += "<br><i>[extra]</i>"
				dat += "<br>"
			dat += "<br>"

	dat += "<a href='?src=[REF(src)];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v4.0", 340, 625)
	popup.set_content(dat)
	popup.open()

/obj/item/gangtool/Topic(href, href_list)
	..()
	if(!can_use(usr))
		return

	add_fingerprint(usr)

	if(href_list["register"])
		register_device(usr)
	else if(!gang) //Gangtool must be registered before you can use the functions below
		return

	if(href_list["purchase"])
		if(islist(buyable_items[href_list["cat"]]))
			var/list/L = buyable_items[href_list["cat"]]
			var/datum/gang_item/G = L[href_list["id"]]
			if(G && G.can_buy(usr, gang, src))
				G.purchase(usr, gang, src, FALSE)

	if(href_list["commute"])
		ping_gang(usr)
	if(href_list["recall"])
		recall(usr)
	if(usr)
		attack_self(usr)

/obj/item/gangtool/update_icon()
	overlays.Cut()
	var/image/I = new(icon, "[icon_state]-overlay")
	if(gang)
		I.color = gang.color
	overlays.Add(I)

/obj/item/gangtool/proc/ping_gang(mob/user)
	if(!can_use(user))
		return
	var/message = stripped_input(user, "Discreetly send a gang-wide message.","Send Message")
	if(!message || !can_use(user))
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='info'>[icon2html(src, user)]Error: Station out of range.</span>")
		return
	if(gang.members.len)
		var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(!G)
			return
		var/ping = "<span class='danger'><B><i>[gang.name] [G.message_name] [user.real_name]</i>: [message]</B></span>"
		for(var/datum/mind/ganger in gang.members)
			if(ganger.current && is_station_level(ganger.current.z) && (ganger.current.stat == CONSCIOUS))
				to_chat(ganger.current, ping)
		for(var/mob/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [ping]")
		user.log_talk(message,LOG_SAY, tag="[gang.name] gangster")

/obj/item/gangtool/proc/register_device(mob/user)
	if(gang)	//It's already been registered!
		return
	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(G)
		gang = G.gang
		gang.gangtools += src
		update_icon()
		if(!(user.mind in gang.leaders) && promotable)
			G.promote()
			free_pen = TRUE
			gang.message_gangtools("[user] has been promoted to Lieutenant.")
			to_chat(user, "The <b>Gangtool</b> you registered will allow you to purchase weapons and equipment, and send messages to your gang.")
			to_chat(user, "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool.")
	else
		to_chat(user, "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>")

/obj/item/gangtool/proc/recall(mob/user)
	if(!recallchecks(user))
		return
	if(recalling)
		to_chat(user, "<span class='warning'>Error: Recall already in progress.</span>")
		return
	gang.message_gangtools("[user] is attempting to recall the emergency shuttle.")
	recalling = TRUE
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Generating shuttle recall order with codes retrieved from last call signal...</span>")
	addtimer(CALLBACK(src, .proc/recall2, user), rand(100,300))

/obj/item/gangtool/proc/recall2(mob/user)
	if(!recallchecks(user))
		return
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")
	addtimer(CALLBACK(src, .proc/recall3, user), rand(100,300))

/obj/item/gangtool/proc/recall3(mob/user)
	if(!recallchecks(user))
		return
	var/list/living_crew = list()//shamelessly copied from mulligan code, there should be a helper for this
	for(var/mob/Player in GLOB.mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client)
			living_crew += Player
	var/malc = CONFIG_GET(number/midround_antag_life_check)
	if(living_crew.len / GLOB.joined_player_list.len <= malc) //Shuttle cannot be recalled if too many people died
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Error: Station communication systems compromised. Unable to establish connection.</span>")
		recalling = FALSE
		return
	to_chat(user, "<span class='info'>[icon2html(src, loc)]Comm arrays accessed. Broadcasting recall signal...</span>")
	addtimer(CALLBACK(src, .proc/recallfinal, user), rand(100,300))

/obj/item/gangtool/proc/recallfinal(mob/user)
	if(!recallchecks(user))
		return
	recalling = FALSE
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
	if(SSshuttle.cancelEvac(user))
		gang.recalls--
		return TRUE

	to_chat(user, "<span class='info'>[icon2html(src, loc)]No response recieved. Emergency shuttle cannot be recalled at this time.</span>")
	return

/obj/item/gangtool/proc/recallchecks(mob/user)
	if(!can_use(user))
		return
	if(SSshuttle.emergencyNoRecall)
		return
	if(!gang.recalls)
		to_chat(user, "<span class='warning'>Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		return
	if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Emergency shuttle cannot be recalled at this time.</span>")
		recalling = FALSE
		return
	if(!gang.dom_attempts)
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		recalling = FALSE
		return
	if(!is_station_level(user.z)) //Shuttle can only be recalled while on station
		to_chat(user, "<span class='warning'>[icon2html(src, user)]Error: Device out of range of station communication arrays.</span>")
		recalling = FALSE
		return
	return TRUE

/obj/item/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!(src in user.contents))
		return
	if(!user.mind)
		return
	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(!G && !istype(src, /obj/item/gangtool/hell_march/vigilante))
		to_chat(user, "<span class='notice'>Huh, what's this?</span>")
		return
	if(!isnull(gang) && G.gang != gang)
		to_chat(user, "<span class='danger'>You cannot use gang tools owned by enemy gangs!</span>")
		return
	return TRUE


/obj/item/gangtool/spare
	outfits = TRUE

/obj/item/gangtool/spare/lt
	promotable = TRUE

/obj/item/gangtool/hell_march
	flag = GANGMAGEDDON
	var/datum/action/innate/gangtool/linked_action
	var/action_type = /datum/action/innate/gangtool
	var/points = 0

/obj/item/gangtool/hell_march/Initialize()
	. = ..()
	if(!ismob(loc))
		return INITIALIZE_HINT_QDEL
	var/mob/user = loc
	var/datum/antagonist/gang/L = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(!L && flag != VIGILANTE)
		return
	linked_action = new action_type(user)
	linked_action.Grant(user, src, L ? L.gang : null)

/obj/item/gangtool/hell_march/proc/pay_income()
	if(!ismob(loc))
		return 0
	var/mob/M = loc
	if(!M.mind)
		return 0
	if(M.mind.has_antag_datum(/datum/antagonist/gang/boss))
		return pay_territory_income_to_boss()
	return pay_soldier_territory_income()

/obj/item/gangtool/hell_march/proc/pay_soldier_territory_income()
	if(!ismob(loc))
		return 0
	var/mob/M = loc
	if(!M.mind)
		return 0
	var/datum/antagonist/gang/G = M.mind.has_antag_datum(/datum/antagonist/gang)
	if(!G)
		return 0
	. = 0
	. = round(max(0,(3 - points/10)) + (G.gang.get_soldier_territories(M.mind)*0.5) + (LAZYLEN(G.gang.territories)*0.3))
	points += .
	if(.)
		to_chat(M, "<span class='notice'>You have gained [.] influence from [G.gang.get_soldier_territories(M.mind)] territories you have personally tagged.</span>")
	else
		to_chat(M, "<span class='warning'>You have not gained any influence from territories you personally tagged. Get to work!</span>")

/obj/item/gangtool/hell_march/proc/pay_territory_income_to_boss()
	if(!ismob(loc))
		return 0
	var/mob/M = loc
	if(!M.mind)
		return 0
	var/datum/antagonist/gang/boss/G = M.mind.has_antag_datum(/datum/antagonist/gang/boss)
	if(!G)
		return 0
	. = 0
	var/inc = round(max(0,(5 - points/10)) + (LAZYLEN(G.gang.territories)*0.6))
	. += inc
	points += inc
	to_chat(M, "<span class='notice'>Your influence has increased by [inc] from your gang holding [LAZYLEN(G.gang.territories)] territories!</span>")

/obj/item/gangtool/hell_march/Destroy()
	linked_action.Remove(linked_action.owner)
	qdel(linked_action)
	return ..()

/obj/item/gangtool/hell_march/ui_interact(mob/user)
	if(user.mind.has_antag_datum(/datum/antagonist/gang/boss))
		return ..()
	if(!user.mind.has_antag_datum(/datum/antagonist/gang))
		return
	var/dat
	if(gang.domination_time != NOT_DOMINATING)
		dat += "<center><font color='red'>Takeover In Progress:<br><B>[DisplayTimeText(gang.domination_time_remaining() * 10)] remain</B></font></center>"
	dat += "Registration: <B>[gang.name] Gangster</B><br>"
	dat += "Organization Size: <B>[gang.members.len]</B> | Station Control: <B>[gang.territories.len] territories under control.</B> | Influence: <B>[points]</B><br>"
	dat += "<a href='?src=[REF(src)];commute=1'>Send message to Gang</a><br>"
	dat += "<hr>"
	for(var/cat in buyable_items)
		dat += "<b>[cat]</b><br>"
		for(var/id in buyable_items[cat])
			var/datum/gang_item/G = buyable_items[cat][id]
			if(!G.can_see(user, gang, src))
				continue

			var/cost = G.get_cost_display(user, gang, src)
			if(cost)
				dat += cost + " "

			var/toAdd = G.get_name_display(user, gang, src)
			if(G.can_buy(user, gang, src))
				toAdd = "<a href='?src=[REF(src)];purchase=1;id=[id];cat=[cat]'>[toAdd]</a>"
			dat += toAdd
			var/extra = G.get_extra_info(user, gang, src)
			if(extra)
				dat += "<br><i>[extra]</i>"
			dat += "<br>"
		dat += "<br>"

	dat += "<a href='?src=[REF(src)];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v4.0", 340, 625)
	popup.set_content(dat)
	popup.open()

// vigilante tool

/obj/item/gangtool/hell_march/vigilante
	flag = VIGILANTE
	action_type = /datum/action/innate/gangtool/vigilante

/obj/item/gangtool/hell_march/vigilante/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/earnings), 1500, TIMER_UNIQUE)

/obj/item/gangtool/hell_march/vigilante/proc/earnings()
	var/all_territory = list()
	var/newpoints = 0
	var/mob/living/carbon/human/H = loc
	for(var/datum/team/gang/G in GLOB.antagonist_teams)
		all_territory += G.territories
	for(var/area/A in tags)
		if(!(A in all_territory))
			newpoints += 0.5
	to_chat(H, "<span class='notice'>You have received 3 influence for your continued loyalty, [newpoints] for keeping the station tag-free.")
	points += newpoints + 3
	for(var/obj/item/implant/mindshield/I in H.implants)
		points += 3
		to_chat(H, "<span class='notice'>You have also received 3 influence for possessing a mindshield implant.</span>")
	addtimer(CALLBACK(src, .proc/earnings), 1500, TIMER_UNIQUE)

/obj/item/gangtool/hell_march/vigilante/ui_interact(mob/user)
	if(user.mind.has_antag_datum(/datum/antagonist/gang))
		return
	var/dat
	dat += "Registration: <B>Vigilante</B><br>"
	dat += "Your Influence: <B>[points]</B><br>"
	dat += "<center><a href='?src=[REF(src)];destroy=TRUE'><B>DESTROY HELD CONTRABAND</a></center></B><br>"
	dat += "<hr>"
	for(var/cat in buyable_items)
		dat += "<b>[cat]</b><br>"
		for(var/id in buyable_items[cat])
			var/datum/gang_item/G = buyable_items[cat][id]
			if(!G.can_see(user, gang, src))
				continue

			var/cost = G.get_cost_display(user, gang, src)
			if(cost)
				dat += cost + " "

			var/toAdd = G.get_name_display(user, gang, src)
			if(G.can_buy(user, gang, src))
				toAdd = "<a href='?src=[REF(src)];purchase=1;id=[id];cat=[cat]'>[toAdd]</a>"
			dat += toAdd
			var/extra = G.get_extra_info(user, gang, src)
			if(extra)
				dat += "<br><i>[extra]</i>"
			dat += "<br>"
		dat += "<br>"

	dat += "<a href='?src=[REF(src)];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to Vigilante's Companion v1.2", 340, 625)
	popup.set_content(dat)
	popup.open()

/obj/item/gangtool/hell_march/vigilante/Topic(href, list/href_list)
	if(!can_use(usr))
		return
	if(href_list["purchase"])
		if(islist(buyable_items[href_list["cat"]]))
			var/list/L = buyable_items[href_list["cat"]]
			var/datum/gang_item/G = L[href_list["id"]]
			if(G && G.can_buy(usr, gang, src))
				G.purchase(usr, gang, src, FALSE)
	if(href_list["destroy"])
		Destroy_Contraband(usr)
	ui_interact(usr)

/obj/item/gangtool/hell_march/vigilante/proc/Destroy_Contraband(mob/living/user)
	var/obj/item/I = user.get_active_held_item()
	var/value
	if(QDELETED(I))
		to_chat(user, "<span class='notice'>No item detected.</span>")
		return
	switch(I.type)
		if(/obj/item/gun/ballistic/automatic/pistol)
			value = 20
		if(/obj/item/implanter/gang)
			value = 12
		if(/obj/item/grenade/c4)
			value = 5
		if(/obj/item/toy/crayon/spraycan/gang)
			var/obj/item/toy/crayon/spraycan/gang/SC = I
			value = 1 + round(SC.charges/9)
		if(/obj/item/grenade/syndieminibomb/concussion/frag)
			value = 13
		if(/obj/item/clothing/shoes/combat/gang)
			value = 9
		if(/obj/item/pen/gang)
			value = 17
		if(/obj/item/reviver)
			value = 10
		if(/obj/item/gangtool)
			value = 20
		if(/obj/item/clothing/glasses/hud/security/chameleon)
			value = 5
		if(/obj/item/gun/ballistic/automatic/mini_uzi)
			value = 30
		if(/obj/item/gun/ballistic/automatic/sniper_rifle)
			value = 20
		if(/obj/item/ammo_box/magazine/sniper_rounds)
			value = 5
		if(/obj/item/gun/ballistic/shotgun/lethal)
			value = 20
		if(/obj/item/gun/ballistic/automatic/surplus)
			value = 8
		if(/obj/item/throwing_star)
			value = 3
		if(/obj/item/switchblade)
			value = 5
		if(/obj/item/storage/belt/military/gang)
			value = 8
		if(/obj/item/clothing/gloves/gang)
			value = 8
		if(/obj/item/clothing/neck/necklace/dope)
			value = 6
		if(/obj/item/clothing/shoes/gang)
			value = 14
		if(/obj/item/clothing/mask/gskull)
			value = 11
		if(/obj/item/clothing/head/collectable/petehat/gang)
			value = 10
	if(istype(I, /obj/item/clothing))
		for(var/datum/team/gang/G in GLOB.gangs)
			if(I.type in (G.outer_outfits) && I.armor["bullet"]>=35)
				value = 5
	if(!value)
		to_chat(user, "<span class='notice'>No contraband detected!</span>")
		return
	playsound(src, 'sound/items/poster_being_created.ogg', 75, 1)
	if(do_after(user, 20, TRUE, I))
		points += value
		to_chat(user, "<span class='notice'>[I] has been processed for [value] influence.")
		qdel(I)

/datum/action/innate/gangtool
	name = "Personal Gang Tool"
	desc = "An implanted gang tool that lets you purchase gear"
	background_icon_state = "bg_demon"
	button_icon_state = "bolt_action"
	var/obj/item/gangtool/hell_march/GT

/datum/action/innate/gangtool/Grant(mob/user, obj/reg)
	. = ..()
	GT = reg

/datum/action/innate/gangtool/Activate()
	GT.ui_interact(owner)

/datum/action/innate/gangtool/vigilante
	name = "Vigilante Uplink"
	desc = "An implanted vigilante uplink."
