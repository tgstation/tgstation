#define WASH_PERIOD 3 SECONDS

/mob/living/basic/bot/hygienebot
	name = "\improper Hygienebot"
	desc = "A flying cleaning robot, he'll chase down people who can't shower properly!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "hygienebot"
	base_icon_state = "hygienebot"
	pass_flags = parent_type::pass_flags | PASSTABLE
	layer = MOB_UPPER_LAYER
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100
	path_image_color = "#80dae7"
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = HYGIENE_BOT
	additional_access = /datum/id_trim/job/janitor
	hackables = "cleaning service protocols"
	ai_controller = /datum/ai_controller/basic_controller/bot/hygienebot

	///are we currently washing someone?
	var/washing = FALSE
	///Visual overlay of the bot spraying water.
	var/static/mutable_appearance/water_overlay = mutable_appearance('icons/mob/silicon/aibots.dmi', "hygienebot-water")
	///Visual overlay of the bot commiting warcrimes.
	var/static/mutable_appearance/fire_overlay = mutable_appearance('icons/mob/silicon/aibots.dmi', "hygienebot-fire")
	///announcements we say when we find a target
	var/static/list/found_announcements = list(
		HYGIENEBOT_VOICED_UNHYGIENIC = 'sound/mobs/non-humanoids/hygienebot/unhygienicclient.ogg',
	)
	///announcements we say when the target keeps moving away
	var/static/list/threat_announcements = list(
		HYGIENEBOT_VOICED_THREAT_AIRLOCK = 'sound/mobs/non-humanoids/hygienebot/dragyouout.ogg',
		HYGIENEBOT_VOICED_FOUL_SMELL = 'sound/mobs/non-humanoids/hygienebot/foulsmelling.ogg',
		HYGIENEBOT_VOICED_TROGLODYTE = 'sound/mobs/non-humanoids/hygienebot/troglodyte.ogg',
		HYGIENEBOT_VOICED_GREEN_CLOUD = 'sound/mobs/non-humanoids/hygienebot/greencloud.ogg',
		HYGIENEBOT_VOICED_ARSEHOLE = 'sound/mobs/non-humanoids/hygienebot/letmeclean.ogg',
		HYGIENEBOT_VOICED_THREAT_ARTERIES = 'sound/mobs/non-humanoids/hygienebot/cutarteries.ogg',
		HYGIENEBOT_VOICED_STOP_RUNNING = 'sound/mobs/non-humanoids/hygienebot/stoprunning.ogg',
	)
	///announcements we say after we have cleaned our target
	var/static/list/cleaned_announcements = list(
		HYGIENEBOT_VOICED_FUCKING_FINALLY = 'sound/mobs/non-humanoids/hygienebot/finally.ogg',
		HYGIENEBOT_VOICED_THANK_GOD = 'sound/mobs/non-humanoids/hygienebot/thankgod.ogg',
		HYGIENEBOT_VOICED_DEGENERATE = 'sound/mobs/non-humanoids/hygienebot/degenerate.ogg',
	)

/mob/living/basic/bot/hygienebot/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

	generate_ai_speech()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	var/static/list/hat_offsets = list(1, 1)
	AddElement(/datum/element/hat_wearer, offsets = hat_offsets)

	ADD_TRAIT(src, TRAIT_SPRAY_PAINTABLE, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))

/mob/living/basic/bot/hygienebot/explode()
	var/datum/effect_system/fluid_spread/foam/foam = new
	foam.set_up(2, holder = src, location = loc)
	foam.start()
	return ..()

/mob/living/basic/bot/hygienebot/generate_speak_list()
	var/static/list/finalized_speak_list = (found_announcements + threat_announcements + cleaned_announcements)
	return finalized_speak_list

/mob/living/basic/bot/hygienebot/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][bot_mode_flags & BOT_MODE_ON ? "-on" : ""]"


/mob/living/basic/bot/hygienebot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "hygienebot-flame")

	if(!washing)
		return

	. += (bot_access_flags & BOT_COVER_EMAGGED) ? fire_overlay : water_overlay

/mob/living/basic/bot/hygienebot/proc/on_entered(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(!washing)
		return
	commence_wash(movable)

/mob/living/basic/bot/hygienebot/proc/on_attack(datum/source, atom/target)
	SIGNAL_HANDLER
	. = COMPONENT_HOSTILE_NO_ATTACK
	if(washing)
		return
	set_washing_mode(new_mode = TRUE)
	for(var/atom/to_wash in loc)
		commence_wash(to_wash)
	addtimer(CALLBACK(src, PROC_REF(set_washing_mode), FALSE), WASH_PERIOD)

/mob/living/basic/bot/hygienebot/proc/set_washing_mode(new_mode)
	washing = new_mode
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/bot/hygienebot/proc/commence_wash(atom/target)
	if(bot_access_flags & BOT_COVER_EMAGGED)
		target.fire_act()
		return
	target.wash(CLEAN_WASH)

/mob/living/basic/bot/hygienebot/on_bot_movement(atom/movable/source, atom/oldloc, dir, forced)

	if(!washing || !isturf(loc))
		return

	for(var/mob/living/carbon/human in loc)
		commence_wash(human)


/mob/living/basic/bot/hygienebot/proc/generate_ai_speech()
	ai_controller.set_blackboard_key(BB_WASH_FOUND, found_announcements)
	ai_controller.set_blackboard_key(BB_WASH_THREATS, threat_announcements)
	ai_controller.set_blackboard_key(BB_WASH_DONE, cleaned_announcements)

#undef WASH_PERIOD
