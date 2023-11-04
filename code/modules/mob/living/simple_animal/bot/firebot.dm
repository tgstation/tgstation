//Firebot

#define SPEECH_INTERVAL 300  // Time between idle speeches
#define DETECTED_VOICE_INTERVAL 300  // Time between fire detected callouts
#define FOAM_INTERVAL 50  // Time between deployment of fire fighting foam

/mob/living/simple_animal/bot/firebot
	name = "\improper Firebot"
	desc = "A little fire extinguishing bot. He looks rather anxious."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "firebot1"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_CONSTRUCTION)
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FIRE_BOT
	hackables = "fire safety protocols"
	path_image_color = "#FFA500"
	possessed_message = "You are a firebot! Protect the station from fires to the best of your ability!"

	automated_announcements = list(
		FIREBOT_VOICED_FIRE_DETECTED = 'sound/voice/firebot/detected.ogg',
		FIREBOT_VOICED_STOP_DROP = 'sound/voice/firebot/stopdropnroll.ogg',
		FIREBOT_VOICED_EXTINGUISHING = 'sound/voice/firebot/extinguishing.ogg',
		FIREBOT_VOICED_NO_FIRES = 'sound/voice/firebot/nofires.ogg',
		FIREBOT_VOICED_ONLY_YOU = 'sound/voice/firebot/onlyyou.ogg',
		FIREBOT_VOICED_TEMPERATURE_NOMINAL = 'sound/voice/firebot/tempnominal.ogg',
		FIREBOT_VOICED_KEEP_COOL = 'sound/voice/firebot/keepitcool.ogg',
	)

	var/atom/target_fire
	var/atom/old_target_fire

	var/obj/item/extinguisher/internal_ext

	var/last_found = 0

	var/speech_cooldown = 0
	var/detected_cooldown = 0
	COOLDOWN_DECLARE(foam_cooldown)

	var/extinguish_people = TRUE
	var/extinguish_fires = TRUE
	var/stationary_mode = FALSE

/mob/living/simple_animal/bot/firebot/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/engi_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/station_engineer]
	access_card.add_access(engi_trim.access + engi_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	create_extinguisher()
	AddElement(/datum/element/atmos_sensitive, mapload)

/mob/living/simple_animal/bot/firebot/Destroy()
	QDEL_NULL(internal_ext)
	return ..()

/mob/living/simple_animal/bot/firebot/bot_reset()
	create_extinguisher()

/mob/living/simple_animal/bot/firebot/proc/create_extinguisher()
	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.safety = FALSE
	internal_ext.precision = TRUE
	internal_ext.max_water = INFINITY
	internal_ext.refill()

/mob/living/simple_animal/bot/firebot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(internal_ext)
		internal_ext.afterattack(A, src)
	else
		return ..()

/mob/living/simple_animal/bot/firebot/RangedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(internal_ext)
		internal_ext.afterattack(A, src)
	else
		return ..()

/mob/living/simple_animal/bot/firebot/turn_on()
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/firebot/turn_off()
	..()
	update_appearance()

/mob/living/simple_animal/bot/firebot/bot_reset()
	..()
	target_fire = null
	old_target_fire = null
	set_anchored(FALSE)
	update_appearance()

/mob/living/simple_animal/bot/firebot/proc/soft_reset()
	path = list()
	target_fire = null
	mode = BOT_IDLE
	last_found = world.time
	update_appearance()

/mob/living/simple_animal/bot/firebot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return

	to_chat(user, span_warning("You enable the very ironically named \"fighting with fire\" mode, and disable the targetting safeties.")) // heheehe. funny

	audible_message(span_danger("[src] buzzes oddly!"))
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(user)
		old_target_fire = user
	extinguish_fires = FALSE
	extinguish_people = TRUE

	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.chem = /datum/reagent/clf3 //Refill the internal extinguisher with liquid fire
	internal_ext.power = 3
	internal_ext.safety = FALSE
	internal_ext.precision = FALSE
	internal_ext.max_water = INFINITY
	internal_ext.refill()
	return TRUE

// Variables sent to TGUI
/mob/living/simple_animal/bot/firebot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["extinguish_fires"] = extinguish_fires
		data["custom_controls"]["extinguish_people"] = extinguish_people
		data["custom_controls"]["stationary_mode"] = stationary_mode
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/firebot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("extinguish_fires")
			extinguish_fires = !extinguish_fires
		if("extinguish_people")
			extinguish_people = !extinguish_people
		if("stationary_mode")
			stationary_mode = !stationary_mode
			update_appearance()

/mob/living/simple_animal/bot/firebot/proc/is_burning(atom/target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.on_fire || (bot_cover_flags & BOT_COVER_EMAGGED && !M.on_fire))
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
		var/static/list/idle_line = list(
			FIREBOT_VOICED_NO_FIRES,
			FIREBOT_VOICED_ONLY_YOU,
			FIREBOT_VOICED_TEMPERATURE_NOMINAL,
			FIREBOT_VOICED_KEEP_COOL,
		)
		speak(pick(idle_line))

	// Couldn't reach the target, reset and try again ignoring the old one
	if(frustration > 8)
		old_target_fire = target_fire
		soft_reset()

	// We extinguished our target or it was deleted
	if(QDELETED(target_fire) || !is_burning(target_fire) || isdead(target_fire))
		target_fire = null
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE)

		var/list/things_to_extinguish = list()
		if(extinguish_people)
			things_to_extinguish += list(/mob/living)

		if(target_fire == null && extinguish_fires)
			things_to_extinguish += list(/turf/open)

		target_fire = scan(things_to_extinguish, old_target_fire, scan_range) // Scan for burning turfs second
		old_target_fire = target_fire

	// Target reached ENGAGE WATER CANNON
	if(target_fire && (get_dist(src, target_fire) <= (bot_cover_flags & BOT_COVER_EMAGGED ? 1 : 2))) // Make the bot spray water from afar when not emagged
		if((speech_cooldown + SPEECH_INTERVAL) < world.time)
			if(ishuman(target_fire))
				speak(FIREBOT_VOICED_STOP_DROP)
			else
				speak(FIREBOT_VOICED_EXTINGUISHING)
			speech_cooldown = world.time

			flick("firebot1_use", src)
			spray_water(target_fire, src)

		soft_reset()

	// Target ran away
	else if(target_fire && path.len && (get_dist(target_fire,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(target_fire && stationary_mode)
		soft_reset()
		return

	if(target_fire && (get_dist(src, target_fire) > 2))

		path = get_path_to(src, target_fire, max_distance=30, mintargetdist=1, access=access_card.GetAccess())
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

	if(bot_mode_flags & BOT_MODE_AUTOPATROL && !target_fire)
		switch(mode)
			if(BOT_IDLE, BOT_START_PATROL)
				start_patrol()
			if(BOT_PATROL)
				bot_patrol()


//Look for burning people or turfs around the bot
/mob/living/simple_animal/bot/firebot/process_scan(atom/scan_target)
	if(!is_burning(scan_target))
		return null

	if((detected_cooldown + DETECTED_VOICE_INTERVAL) < world.time)
		speak(FIREBOT_VOICED_FIRE_DETECTED)
		detected_cooldown = world.time
		return scan_target

/mob/living/simple_animal/bot/firebot/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > T0C + 200 || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)

/mob/living/simple_animal/bot/firebot/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(COOLDOWN_FINISHED(src, foam_cooldown))
		var/datum/effect_system/fluid_spread/foam/firefighting/foam = new
		foam.set_up(3, holder = src, location = loc)
		foam.start()
		COOLDOWN_START(src, foam_cooldown, FOAM_INTERVAL)

/mob/living/simple_animal/bot/firebot/proc/spray_water(atom/target, mob/user)
	if(stationary_mode)
		flick("firebots_use", user)
	else
		flick("firebot1_use", user)
	internal_ext.afterattack(target, user, null)

/mob/living/simple_animal/bot/firebot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "firebot0"
		return
	if(IsStun() || IsParalyzed() || stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "firebots1"
		return
	icon_state = "firebot1"


/mob/living/simple_animal/bot/firebot/explode()
	var/atom/Tsec = drop_location()

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/clothing/head/utility/hardhat/red(Tsec)

	var/turf/T = get_turf(Tsec)

	if(isopenturf(T))
		var/turf/open/theturf = T
		theturf.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
	return ..()

#undef SPEECH_INTERVAL
#undef DETECTED_VOICE_INTERVAL
#undef FOAM_INTERVAL

