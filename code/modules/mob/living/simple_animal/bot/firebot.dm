//Floorbot
/mob/living/simple_animal/bot/firebot
	name = "\improper Firebot"
	desc = "A little fire extinguishing bot. He looks rather anxious."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	spacewalk = TRUE

	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FIRE_BOT
	model = "Firebot"
	bot_core = /obj/machinery/bot_core/floorbot
	window_id = "autoextinguisher"
	window_name = "Mobile Fire Extinguisher v1.0"
	path_image_color = "#FFA500"

	var/atom/target_fire
	var/atom/old_target_fire

	var/obj/item/extinguisher/internal_ext

	var/last_found = 0

	var/speech_cooldown = 0
	var/detected_cooldown = 0

	var/extinguish_people = TRUE
	var/extinguish_fires = TRUE

/mob/living/simple_animal/bot/firebot/Initialize()
	. = ..()
	update_icon()
	var/datum/job/engineer/J = new/datum/job/engineer
	access_card.access += J.get_access()
	prev_access = access_card.access

	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.safety = FALSE
	internal_ext.precision = TRUE
	internal_ext.max_water = INFINITY
	internal_ext.Initialize()

/mob/living/simple_animal/bot/firebot/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/firebot/turn_off()
	..()
	update_icon()

/mob/living/simple_animal/bot/firebot/bot_reset()
	..()
	target_fire = null
	old_target_fire = null
	ignore_list = list()
	anchored = FALSE
	update_icon()

/mob/living/simple_animal/bot/firebot/proc/soft_reset()
	path = list()
	target_fire = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()

/mob/living/simple_animal/bot/firebot/set_custom_texts()
	text_hack = "You corrupt [name]'s safety protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/firebot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Mobile Fire Extinguisher v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"

	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "Extinguish Fires: <A href='?src=[REF(src)];operation=extinguish_fires'>[extinguish_fires ? "Yes" : "No"]</A><BR>"
		dat += "Extinguish People: <A href='?src=[REF(src)];operation=extinguish_people'>[extinguish_people ? "Yes" : "No"]</A><BR>"
		dat += "Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"

	return dat

/mob/living/simple_animal/bot/firebot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")
		audible_message("<span class='danger'>[src] buzzes oddly!</span>")
		playsound(src, "sparks", 75, 1)
		if(user)
			old_target_fire = user
		extinguish_fires = FALSE
		extinguish_people = TRUE
		a_intent = "harm"

/mob/living/simple_animal/bot/firebot/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["operation"])
		if("extinguish_fires")
			extinguish_fires = !extinguish_fires
		if("extinguish_people")
			extinguish_people = !extinguish_people

	update_controls()

/mob/living/simple_animal/bot/firebot/proc/is_burning(atom/target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.on_fire || emagged == 2)
			return TRUE

	else if(isturf(target))
		var/turf/open/T = target
		if(T.active_hotspot)
			return TRUE

	return FALSE

/mob/living/simple_animal/bot/firebot/handle_automated_action()
	if(!..())
		return

	if(IsStun() || IsParalyzed())
		old_target_fire = target_fire
		target_fire = null
		mode = BOT_IDLE
		return

	if(prob(1) && target_fire == null)
		var/list/messagevoice = list("No fires detected" = 'sound/voice/firebot/nofires.ogg',
		"Only you can prevent station fires." = 'sound/voice/firebot/onlyyou.ogg',
		"Temperature nominal" = 'sound/voice/firebot/tempnominal.ogg',
		"Keep it cool" = 'sound/voice/firebot/keepitcool.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(loc, messagevoice[message], 50, 0)

	// Couldn't reach the target, reset and try again ignoring the old one
	if(frustration > 8)
		old_target_fire = target_fire
		soft_reset()

	// We extinguished our target or it was deleted
	if(QDELETED(target_fire) || !is_burning(target_fire) || isdead(target_fire))
		target_fire = null

		if(extinguish_people)
			target_fire = scan(/mob/living, old_target_fire, DEFAULT_SCAN_RANGE) // Scan for burning humans first

		if(target_fire == null && extinguish_fires)
			target_fire = scan(/turf/open, old_target_fire, DEFAULT_SCAN_RANGE) // Scan for burning turfs second

		old_target_fire = target_fire

	// Target reached ENGAGE WATER CANNON
	if(target_fire && (get_dist(src, target_fire) <= 1))

		if((speech_cooldown + 300) < world.time)
			if(ishuman(target_fire))
				speak("Stop, drop and roll!")
				playsound(src.loc, "sound/voice/firebot/stopdropnroll.ogg", 50, 0)
			else
				speak("Extinguishing!")
				playsound(src.loc, "sound/voice/firebot/extinguishing.ogg", 50, 0)
			speech_cooldown = world.time

		if(emagged == 2)
			internal_ext.attack(target_fire, src)
		else
			internal_ext.afterattack(target_fire, src, null)

	// Target ran away
	else if(target_fire && path.len && (get_dist(target_fire,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	if(target_fire && (get_dist(src, target_fire) > 1))
		path = get_path_to(src, get_turf(target_fire), /turf/proc/Distance_cardinal, 0, 30, 1, id=access_card)
		mode = BOT_MOVING
		if(!path.len)
			soft_reset()

	if(path.len > 0 && target_fire)
		if(!bot_move(path[path.len]))
			old_target_fire = target_fire
			soft_reset()
		return

	// We got a target but it's too far away from us
	if(path.len > 8 && target_fire)
		frustration++

	if(auto_patrol && !target_fire)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()


//Look for burning people or turfs around the bot
/mob/living/simple_animal/bot/firebot/process_scan(atom/scan_target)
	var/result

	if(is_burning(scan_target))
		if((detected_cooldown + 300) < world.time)
			speak("Fire detected!")
			playsound(src.loc, "sound/voice/firebot/detected.ogg", 50, 0)
			detected_cooldown = world.time
		result = scan_target

	return result

/mob/living/simple_animal/bot/firebot/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if((temperature > T0C + 200 || temperature < BODYTEMP_COLD_DAMAGE_LIMIT))
		internal_ext.afterattack(src, src, null)
	..()


/mob/living/simple_animal/bot/firebot/update_icon()
	icon_state = "floorbot[on]"


/mob/living/simple_animal/bot/firebot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/atom/Tsec = drop_location()

	//drop_part(toolbox, Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)


	if(prob(50))
		drop_part(robot_arm, Tsec)

	new /obj/item/stack/tile/plasteel(Tsec, 1)

	do_sparks(3, TRUE, src)
	..()



/obj/machinery/bot_core/firebot
	req_one_access = list(ACCESS_CONSTRUCTION, ACCESS_ROBOTICS)
