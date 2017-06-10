#define DOM_BLOCKED_SPAM_CAP 6
#define DOM_REQUIRED_TURFS 30
#define DOM_REQUIRED_SEPARATION 10
#define DOMINATOR_FORCEFIELD_RADIUS 6
#define DOMINATOR_TELEGRAPH_DELAY 100		//No visual effects yet but prevents instant combat dominator dropping.
#define DOMINATOR_FORCEFIELD FALSE			//Dominators have forcefields.
#define DOM_HULK_HITS_REQUIRED 10

/obj/machinery/dominator
	name = "dominator"
	desc = "A visibly sinister device. Looks like you can break it if you hit it enough."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = 1
	anchored = 1
	layer = HIGH_OBJ_LAYER
	max_integrity = 300
	obj_integrity = 300
	integrity_failure = 100
	armor = list(melee = 20, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 10, acid = 70)
	var/datum/gang/gang
	var/operating = 0	//0=standby or broken, 1=takeover
	var/warned = 0	//if this device has set off the warning at <3 minutes yet
	var/spam_prevention = DOM_BLOCKED_SPAM_CAP //first message is immediate
	var/datum/effect_system/spark_spread/spark_system
	var/obj/effect/countdown/dominator/countdown
	var/datum/proximity_monitor/advanced/dominator_forcefield/forcefield
	var/recalling = FALSE
	var/free_pens = 3

/obj/machinery/dominator/hulk_damage()
	return (max_integrity - integrity_failure) / DOM_HULK_HITS_REQUIRED

/proc/dominator_excessive_walls(atom/A)
	var/open = 0
	for(var/turf/T in view(3, A))
		if(!isclosedturf(T))
			open++
	if(open < DOM_REQUIRED_TURFS)
		return TRUE
	else
		return FALSE

/proc/dominator_interference_check(atom/A)
	if(!DOMINATOR_FORCEFIELD)
		return TRUE
	for(var/obj/machinery/dominator/DM in world)
		if(get_dist(DM, src) < DOM_REQUIRED_SEPARATION)
			return TRUE
	return FALSE

/obj/machinery/dominator/tesla_act()
	qdel(src)

/obj/machinery/dominator/Initialize()
	. = ..()
	set_light(2)
	GLOB.poi_list |= src
	spark_system = new
	spark_system.set_up(5, TRUE, src)
	countdown = new(src)
	if(DOMINATOR_FORCEFIELD)
		//Someone can add a visual telegraph later I guess!
		addtimer(CALLBACK(src, .proc/activate_forcefield), DOMINATOR_TELEGRAPH_DELAY)
	if(!SSticker.mode.gang_points)
		SSticker.mode.gang_points = new /datum/gang_points(SSticker.mode)

/obj/machinery/dominator/proc/can_use(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.restrained() || user.lying || user.stat || user.stunned || user.weakened)
		return FALSE
	if(!(src in user.contents))
		return FALSE
	if(!user.mind)
		return FALSE
	if(gang && (user.mind in gang.bosses))	//If it's already registered, only let the gang's bosses use this
		return TRUE
	else if(user.mind in SSticker.mode.get_all_gangsters()) // For soldiers and potential LT's
		return TRUE
	return FALSE

/obj/machinery/dominator/proc/recall(mob/user, phase = 1)
	switch(phase)
		if(1)
			if(!can_use(user))
				return FALSE

			if(SSshuttle.emergencyNoRecall)
				return FALSE

			if(recalling)
				to_chat(usr, "<span class='warning'>Error: Recall already in progress.</span>")
				return FALSE

			if(!gang.recalls)
				to_chat(usr, "<span class='warning'>Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")

			gang.gang_broadcast("[usr] is attempting to recall the emergency shuttle.")
			recalling = TRUE
			to_chat(loc, "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>")
			addtimer(CALLBACK(src, .proc/recall, user, phase+1), rand(100,300))
		if(1)
			if(SSshuttle.emergency.mode != SHUTTLE_CALL) //Shuttle can only be recalled when it's moving to the station
				to_chat(user, "<span class='warning'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>")
				recalling = FALSE
				return FALSE
			to_chat(loc, "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")
			addtimer(CALLBACK(src, .proc/recall, user, phase+1), rand(100,300))
		if(2)
			if(!gang.dom_attempts)
				to_chat(user, "<span class='warning'>\icon[src]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
				recalling = FALSE
				return FALSE

			var/turf/userturf = get_turf(user)
			if(userturf.z != ZLEVEL_STATION) //Shuttle can only be recalled while on station
				to_chat(user, "<span class='warning'>\icon[src]Error: Device out of range of station communication arrays.</span>")
				recalling = FALSE
				return FALSE
			var/datum/station_state/end_state = new /datum/station_state()
			end_state.count()
			if((100 * GLOB.start_state.score(end_state)) < 80) //Shuttle cannot be recalled if the station is too damaged
				to_chat(user, "<span class='warning'>\icon[src]Error: Station communication systems compromised. Unable to establish connection.</span>")
				recalling = FALSE
				return FALSE
			to_chat(loc, "<span class='info'>\icon[src]Comm arrays accessed. Broadcasting recall signal...</span>")

			addtimer(CALLBACK(src, .proc/recall, user, phase+1), rand(100,300))
		if(3)
			recalling = FALSE
			log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
			message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool.", 1)
			var/turf/userturf = get_turf(user)
			if(userturf.z == ZLEVEL_STATION) //Check one more time that they are on station.
				if(SSshuttle.cancelEvac(user))
					gang.recalls -= 1
					return TRUE

			to_chat(loc, "<span class='info'>\icon[src]No response recieved. Emergency shuttle cannot be recalled at this time.</span>")
			return FALSE
	update_icon()

/obj/machinery/dominator/examine(mob/user)
	..()
	if(stat & BROKEN)
		return

	var/time
	if(gang && gang.is_dominating)
		time = gang.domination_time_remaining()
		if(time > 0)
			to_chat(user, "<span class='notice'>Hostile Takeover in progress. Estimated [time] seconds remain.</span>")
		else
			to_chat(user, "<span class='notice'>Hostile Takeover of [station_name()] successful. Have a great day.</span>")
	else
		to_chat(user, "<span class='notice'>System on standby.</span>")
	to_chat(user, "<span class='danger'>System Integrity: [round((obj_integrity/max_integrity)*100,1)]%</span>")

/obj/machinery/dominator/proc/activate_forcefield(force = FALSE)
	if(istype(forcefield))
		QDEL_NULL(forcefield)
	if(!istype(gang))
		return FALSE
	if(stat & BROKEN)
		return FALSE
	if(!force && gang.is_dominating)
		return FALSE
	var/list/fparams = list()
	fparams["current_range"] = DOMINATOR_FORCEFIELD_RADIUS
	fparams["host"] = src
	fparams["controller"] = src
	fparams["team"] = gang
	forcefield = make_field(/datum/proximity_monitor/advanced/dominator_forcefield, fparams)

/obj/machinery/dominator/proc/deactivate_forcefield()
	QDEL_NULL(forcefield)

/obj/machinery/dominator/process()
	..()
	if(gang && gang.is_dominating)
		var/time_remaining = gang.domination_time_remaining()
		if(time_remaining > 0)
			if(dominator_excessive_walls(src))
				gang.domination_timer += 20
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				if(spam_prevention < DOM_BLOCKED_SPAM_CAP)
					spam_prevention++
				else
					gang.gang_broadcast("Warning: There are too many walls around your gang's dominator, its signal is being blocked!")
					say("Error: Takeover signal is currently blocked! There are too many walls within 3 standard units of this device.")
					spam_prevention = 0
				return
			. = TRUE
			playsound(loc, 'sound/items/timer.ogg', 10, 0)
			if(!warned && (time_remaining < 180))
				warned = 1
				var/area/domloc = get_area(loc)
				gang.gang_broadcast("Less than 3 minutes remains in hostile takeover. Defend your dominator at [domloc.map_name]!", null, "System Alert", "userdanger")
				for(var/datum/gang/G in SSticker.mode.gangs)
					if(G != gang)
						G.gang_broadcast("WARNING: [gang.name] Gang takeover imminent. Their dominator at [domloc.map_name] must be destroyed!", null, "System Alert", "userdanger")

	if(!.)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/dominator/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/bang.ogg', 50, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/machinery/dominator/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.)
		if(obj_integrity/max_integrity > 0.66)
			if(prob(damage_amount*2))
				spark_system.start()
		else if(!(stat & BROKEN))
			spark_system.start()
			update_icon()

/obj/machinery/dominator/update_icon()
	cut_overlays()
	if(!(stat & BROKEN))
		icon_state = "dominator-active"
		if(operating)
			var/mutable_appearance/dominator_overlay = mutable_appearance('icons/obj/machines/dominator.dmi', "dominator-overlay")
			if(gang)
				dominator_overlay.color = gang.color_hex
			add_overlay(dominator_overlay)
		else
			icon_state = "dominator"
		if(obj_integrity/max_integrity < 0.66)
			add_overlay("damage")
	else
		icon_state = "dominator-broken"

/obj/machinery/dominator/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		set_broken()
		deactivate_forcefield()

/obj/machinery/dominator/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			set_broken()
		new /obj/item/stack/sheet/plasteel(src.loc)
	qdel(src)

/obj/machinery/dominator/attacked_by(obj/item/I, mob/living/user)
	add_fingerprint(user)
	..()

/obj/machinery/dominator/proc/set_broken()
	if(gang)
		gang.is_dominating = FALSE

		var/takeover_in_progress = 0
		for(var/datum/gang/G in SSticker.mode.gangs)
			if(G.is_dominating)
				takeover_in_progress = 1
				break
		if(!takeover_in_progress)
			var/was_stranded = SSshuttle.emergency.mode == SHUTTLE_STRANDED
			SSshuttle.clearHostileEnvironment(src)
			if(!was_stranded)
				priority_announce("All hostile activity within station systems has ceased.","Network Alert")

			if(get_security_level() == "delta")
				set_security_level("red")

		gang.gang_broadcast("Hostile takeover cancelled: Dominator is no longer operational.[gang.dom_attempts ? " You have [gang.dom_attempts] attempt remaining." : " The station network will have likely blocked any more attempts by us."]", null, "Broadcast", "userdanger")

	set_light(0)
	operating = 0
	stat |= BROKEN
	update_icon()
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/dominator/Destroy()
	if(!(stat & BROKEN))
		set_broken()
	GLOB.poi_list.Remove(src)
	gang = null
	QDEL_NULL(spark_system)
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/dominator/emp_act(severity)
	take_damage(100, BURN, "energy", 0)
	..()

/obj/machinery/dominator/attack_hand(mob/user)
	if(operating || (stat & BROKEN))
		examine(user)
		return

/obj/machinery/dominator/proc/get_gang_item_interface(mob/user, boss = FALSE, soldier = FALSE)
	. = list()
	if(boss)
		for(var/cat in gang.boss_category_list)
			. += "<b>[cat]</b><br>"
			for(var/V in gang.boss_category_list[cat])
				var/datum/gang_item/G = V
				if(!G.can_see(user, gang, src))
					continue

				var/cost = G.get_cost_display(user, gang, src)
				if(cost)
					. += cost + " "

				var/toAdd = G.get_name_display(user, gang, src)
				if(G.can_buy(user, gang, src))
					toAdd = "<a href='?src=\ref[src];purchase=[G.id]'>[toAdd]</a>"
				. += toAdd
				var/extra = G.get_extra_info(user, gang, src)
				if(extra)
					. += "<br><i>[extra]</i>"
				. += "<br>"
			. += "<br>"
	if(soldier)
		for(var/cat in gang.reg_category_list)
			. += "<b>[cat]</b><br>"
			for(var/V in gang.reg_category_list[cat])
				var/datum/gang_item/G = V
				if(!G.can_see(user, gang, src))
					continue

				var/cost = G.get_cost_display(user, gang, src)
				if(cost)
					. += cost + " "

				var/toAdd = G.get_name_display(user, gang, src)
				if(G.can_buy(user, gang, src))
					toAdd = "<a href='?src=\ref[src];purchase=[G.id]'>[toAdd]</a>"
				. += toAdd
				var/extra = G.get_extra_info(user, gang, src)
				if(extra)
					. += "<br><i>[extra]</i>"
				. += "<br>"
			. += "<br>"

/obj/machinery/dominator/proc/get_gang_dominator_interface(takeover = TRUE, start = FALSE)
	. = list()
	if(takeover && gang.is_dominating)
		. += "<center><font color='red'>Takeover In Progress:<br><B>[gang.domination_time_remaining()] seconds remain</B></font></center>"
	if(start && !gang.is_dominating)
		. += "<center><font color='red' size='4'><br><B><a href='?src=\ref[src];dominate=1'>START TAKEOVER</a></B></font></center>"

/obj/machinery/dominator/proc/get_gang_status(mob/user)
	if(!gang)
		return
	. = list()
	if(user)
		var/isboss = (user.mind == gang.bosses[1])
		if(isboss)
			. += "Registration: <B>[gang.name] Gang [isboss ? "Boss" : "Lieutenant"]</B><br>"
			. += "Influence available to you: <B>[gang.bosses[user]]</B><br>"
		else
			. += "Registration: <B>[gang.name] Gang Soldier</B><br>"
			. += "Influence available to you: <B>[gang.gangsters[user]]</B><br>"
			. += "<B>Remember! Territories you tag will generate bonus influence to you!</B>"
	. += "Organization Size: <B>[gang.gangsters.len + gang.bosses.len]</B> | Station Control: <B>[round((gang.territory.len/GLOB.start_state.num_territories)*100, 1)]%</B><br>"

/obj/machinery/dominator/proc/interface_boss(mob/user)
	var/dat = list()
	dat += get_gang_dominator_interface(TRUE, TRUE)
	dat += "<hr>"
	dat += get_gang_status(user)
	dat += "<hr>"
	dat += get_gang_item_interface(user, TRUE, FALSE)
	dat += "<hr>"
	show_popup(user, dat)

/obj/machinery/dominator/proc/interface_soldier(mob/user)
	var/dat = list()
	dat += get_gang_dominator_interface(TRUE, FALSE)
	dat += "<hr>"
	dat += get_gang_status(user)
	dat += "<hr>"
	dat += get_gang_item_interface(user, FALSE, TRUE)
	dat += "<hr>"
	show_popup(user, dat)

/obj/machinery/dominator/proc/show_popup(mob/user, data)
	var/dat = list()
	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"
	dat += data
	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangUplink v3.5", 340, 625)
	popup.set_content(dat)
	popup.open()

/obj/machinery/dominator/Topic(href, href_list)
	if(!can_use(usr))
		return
	add_fingerprint(usr)
	if(!gang)			//Shouldn't happen.
		return
	if(href_list["purchase_soldier"])
		var/datum/gang_item/G = gang.reg_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)
		interface_soldier(usr)
	if(href_list["purchase_boss"])
		var/datum/gang_item/G = gang.boss_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)
		interface_boss(usr)
	if(href_list["dominate"])
		interface_domination(usr)

/obj/machinery/dominator/proc/interface_domination(mob/user)
	var/datum/gang/tempgang

	if(user.mind in SSticker.mode.get_all_gangsters())
		tempgang = user.mind.gang_datum					//If someone somehow teleported into your dominator and is now dominating with your dominator using one of THEIR charges in a crowd of angry gangsters, good/bad for them..
	else
		examine(user)
		return

	if(tempgang.is_dominating)
		to_chat(user, "<span class='warning'>Error: Hostile Takeover is already in progress.</span>")
		return

	if(!tempgang.dom_attempts)
		to_chat(user, "<span class='warning'>Error: Unable to breach station network. Firewall has logged our signature and is blocking all further attempts.</span>")
		return

	var/time = round(determine_domination_time(tempgang)/60,0.1)
	if(alert(user,"With [round((tempgang.territory.len/GLOB.start_state.num_territories)*100, 1)]% station control, a takeover will require [time] minutes.\nYour gang will be unable to gain influence while it is active.\nThe entire station will likely be alerted to it once it starts.\nYou have [tempgang.dom_attempts] attempt(s) remaining. Are you ready?","Confirm","Ready","Later") == "Ready")
		if((tempgang.is_dominating) || !tempgang.dom_attempts || !in_range(src, user) || !isturf(loc))
			return 0

		var/area/A = get_area(loc)
		var/locname = A.map_name

		gang = tempgang
		gang.dom_attempts --
		priority_announce("Network breach detected in [locname]. The [gang.name] Gang is attempting to seize control of the station!","Network Alert")
		gang.domination()
		SSshuttle.registerHostileEnvironment(src)
		name = "[gang.name] Gang [name]"
		operating = 1
		update_icon()

		countdown.color = gang.color_hex
		countdown.start()

		set_light(3)
		START_PROCESSING(SSmachines, src)

		deactivate_forcefield()

		gang.gang_broadcast("Hostile takeover in progress: Estimated [time] minutes until victory.[gang.dom_attempts ? "" : " This is your final attempt."]", null, "Automatic Broadcast", "userdanger")
		for(var/datum/gang/G in SSticker.mode.gangs)
			if(G != gang)
				G.gang_broadcast("Enemy takeover attempt detected in [locname]: Estimated [time] minutes until our defeat.",null, "Automatic Broadcast", "userdanger")

/obj/machinery/dominator/proc/ping_gang(mob/user)
	if(!istype(user))
		return
	var/message = stripped_input(user, "Send a wide-wide broadcast.", "Send Message") as null|text
	if(!message||!can_use(user))
		return
	if(user.z != ZLEVEL_STATION)
		to_chat(user, "<span class='boldwarning'>[bicon(src)]Error: Relays out of range!</span>")
	gang.gang_broadcast(message, user)
