#define DOM_BLOCKED_SPAM_CAP 6
#define DOM_REQUIRED_TURFS 30

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

/proc/dominator_excessive_walls(atom/A)
	var/open = 0
	for(var/turf/T in view(3, A))
		if(!isclosedturf(T))
			open++
	if(open < DOM_REQUIRED_TURFS)
		return TRUE
	else
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
					gang.message_gangtools("Warning: There are too many walls around your gang's dominator, its signal is being blocked!")
					say("Error: Takeover signal is currently blocked! There are too many walls within 3 standard units of this device.")
					spam_prevention = 0
				return
			. = TRUE
			playsound(loc, 'sound/items/timer.ogg', 10, 0)
			if(!warned && (time_remaining < 180))
				warned = 1
				var/area/domloc = get_area(loc)
				gang.message_gangtools("Less than 3 minutes remains in hostile takeover. Defend your dominator at [domloc.map_name]!")
				for(var/datum/gang/G in SSticker.mode.gangs)
					if(G != gang)
						G.message_gangtools("WARNING: [gang.name] Gang takeover imminent. Their dominator at [domloc.map_name] must be destroyed!",1,1)

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

		gang.message_gangtools("Hostile takeover cancelled: Dominator is no longer operational.[gang.dom_attempts ? " You have [gang.dom_attempts] attempt remaining." : " The station network will have likely blocked any more attempts by us."]",1,1)

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

	var/datum/gang/tempgang

	if(user.mind in SSticker.mode.get_all_gangsters())
		tempgang = user.mind.gang_datum
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

		gang.message_gangtools("Hostile takeover in progress: Estimated [time] minutes until victory.[gang.dom_attempts ? "" : " This is your final attempt."]")
		for(var/datum/gang/G in SSticker.mode.gangs)
			if(G != gang)
				G.message_gangtools("Enemy takeover attempt detected in [locname]: Estimated [time] minutes until our defeat.",1,1)
