#define FOAM_INTERVAL 5 SECONDS

/mob/living/basic/bot/firebot
	name = "\improper Firebot"
	desc = "A little fire extinguishing bot. He looks rather anxious."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "firebot1"
	light_color = "#8cffc9"
	light_power = 0.8

	req_one_access = list(ACCESS_ROBOTICS, ACCESS_CONSTRUCTION)
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FIRE_BOT
	additional_access = /datum/id_trim/job/station_engineer
	hackables = "fire safety protocols"
	path_image_color = "#FFA500"
	possessed_message = "You are a firebot! Protect the station from fires to the best of your ability!"
	ai_controller = /datum/ai_controller/basic_controller/bot/firebot
	///our inbuilt fire extinguisher
	var/obj/item/extinguisher/internal_ext

	///Flags firebots use to decide how they function.
	var/firebot_mode_flags = FIREBOT_EXTINGUISH_PEOPLE | FIREBOT_EXTINGUISH_FLAMES
	//Selections:  FIREBOT_STATIONARY_MODE | FIREBOT_EXTINGUISH_PEOPLE | FIREBOT_EXTINGUISH_FLAMES
	///cooldown before we release foam all over
	COOLDOWN_DECLARE(foam_cooldown)


/mob/living/basic/bot/firebot/generate_speak_list()
	var/static/list/idle_lines = list(
		FIREBOT_VOICED_NO_FIRES = 'sound/voice/firebot/nofires.ogg',
		FIREBOT_VOICED_ONLY_YOU = 'sound/voice/firebot/onlyyou.ogg',
		FIREBOT_VOICED_TEMPERATURE_NOMINAL = 'sound/voice/firebot/tempnominal.ogg',
		FIREBOT_VOICED_KEEP_COOL = 'sound/voice/firebot/keepitcool.ogg',
	)
	var/static/list/fire_detected_lines = list(
		FIREBOT_VOICED_FIRE_DETECTED = 'sound/voice/firebot/detected.ogg',
		FIREBOT_VOICED_STOP_DROP = 'sound/voice/firebot/stopdropnroll.ogg',
		FIREBOT_VOICED_EXTINGUISHING = 'sound/voice/firebot/extinguishing.ogg',
	)
	var/static/list/emagged_lines = list(
		FIREBOT_VOICED_CANDLE_TIP = 'sound/voice/firebot/candle_tip.ogg',
		FIREBOT_VOICED_ELECTRIC_FIRE = 'sound/voice/firebot/electric_fire_tip.ogg',
		FIREBOT_VOICED_FUEL_TIP = 'sound/voice/firebot/gasoline_tip.ogg'
	)
	ai_controller.set_blackboard_key(BB_FIREBOT_EMAGGED_LINES, emagged_lines)
	ai_controller.set_blackboard_key(BB_FIREBOT_IDLE_LINES, idle_lines)
	ai_controller.set_blackboard_key(BB_FIREBOT_FIRE_DETECTED_LINES, fire_detected_lines)
	return idle_lines + fire_detected_lines

/mob/living/basic/bot/firebot/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	update_appearance(UPDATE_ICON)
	var/static/list/things_to_extinguish = typecacheof(list(/mob/living/carbon))
	ai_controller.set_blackboard_key(BB_FIREBOT_CAN_EXTINGUISH, things_to_extinguish)
	create_extinguisher()
	AddElement(/datum/element/atmos_sensitive, mapload)

/mob/living/basic/bot/firebot/Destroy()
	QDEL_NULL(internal_ext)
	return ..()

/mob/living/basic/bot/firebot/bot_reset(bypass_ai_reset)
	. = ..()
	create_extinguisher()

/mob/living/basic/bot/firebot/proc/create_extinguisher()
	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.safety = FALSE
	internal_ext.precision = TRUE
	internal_ext.max_water = INFINITY
	internal_ext.refill()

/mob/living/basic/bot/firebot/melee_attack(atom/attacked_atom, list/modifiers, ignore_cooldown = FALSE)
	use_extinguisher(attacked_atom, modifiers)

/mob/living/basic/bot/firebot/RangedAttack(atom/attacked_atom, list/modifiers)
	use_extinguisher(attacked_atom, modifiers)

/mob/living/basic/bot/firebot/proc/use_extinguisher(atom/attacked_atom, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	spray_water(attacked_atom, modifiers)

/mob/living/basic/bot/firebot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		return

	to_chat(user, span_warning("You enable the very ironically named \"fighting with fire\" mode, and disable the targeting safeties.")) // heheehe. funny

	audible_message(span_danger("[src] buzzes oddly!"))
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	internal_ext.chem = /datum/reagent/clf3 //Refill the internal extinguisher with liquid fire
	internal_ext.power = 3
	internal_ext.safety = FALSE
	internal_ext.precision = FALSE
	internal_ext.max_water = INFINITY
	internal_ext.refill()
	return TRUE

// Variables sent to TGUI
/mob/living/basic/bot/firebot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || HAS_SILICON_ACCESS(user))
		data["custom_controls"]["extinguish_fires"] = firebot_mode_flags & FIREBOT_EXTINGUISH_FLAMES
		data["custom_controls"]["extinguish_people"] = firebot_mode_flags & FIREBOT_EXTINGUISH_PEOPLE
		data["custom_controls"]["stationary_mode"] = firebot_mode_flags & FIREBOT_STATIONARY_MODE
	return data

// Actions received from TGUI
/mob/living/basic/bot/firebot/ui_act(action, params)
	. = ..()
	if(. || (bot_access_flags & BOT_COVER_LOCKED && !HAS_SILICON_ACCESS(usr)))
		return

	switch(action)
		if("extinguish_fires")
			firebot_mode_flags ^= FIREBOT_EXTINGUISH_FLAMES
		if("extinguish_people")
			firebot_mode_flags ^= FIREBOT_EXTINGUISH_PEOPLE
		if("stationary_mode")
			firebot_mode_flags ^= FIREBOT_STATIONARY_MODE
			update_appearance()

/mob/living/basic/bot/firebot/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > T0C + 200 || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)

/mob/living/basic/bot/firebot/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(!COOLDOWN_FINISHED(src, foam_cooldown))
		return
	var/datum/effect_system/fluid_spread/foam/firefighting/foam = new
	foam.set_up(3, holder = src, location = loc)
	foam.start()
	COOLDOWN_START(src, foam_cooldown, FOAM_INTERVAL)

/mob/living/basic/bot/firebot/proc/spray_water(atom/attacked_atom, list/modifiers)
	if(firebot_mode_flags & FIREBOT_STATIONARY_MODE)
		flick("firebots_use", src)
	else
		flick("firebot1_use", src)
	internal_ext?.interact_with_atom(attacked_atom, src, modifiers)

/mob/living/basic/bot/firebot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "firebot0"
		return
	if(IsStun() || IsParalyzed() || (firebot_mode_flags & FIREBOT_STATIONARY_MODE)) //Bot has yellow light to indicate stationary mode.
		icon_state = "firebots1"
		return
	icon_state = "firebot1"

/mob/living/basic/bot/firebot/explode()
	var/turf/my_turf = drop_location()

	new /obj/item/assembly/prox_sensor(my_turf)
	new /obj/item/clothing/head/utility/hardhat/red(my_turf)

	if(isopenturf(my_turf))
		var/turf/open/open_turf = my_turf
		open_turf.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

	return ..()

#undef FOAM_INTERVAL
