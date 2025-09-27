/mob/living/basic/bot/honkbot
	name = "\improper Honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon_state = "honkbot"
	base_icon_state = "honkbot"
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	req_access = list(ACCESS_ROBOTICS, ACCESS_THEATRE, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	ai_controller = /datum/ai_controller/basic_controller/bot/honkbot
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = HONK_BOT
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT | BOT_MODE_AUTOPATROL | BOT_MODE_ROUNDSTART_POSSESSION
	hackables = "sound control systems"
	path_image_color = "#FF69B4"
	data_hud_type = TRAIT_SECURITY_HUD_ID_ONLY
	additional_access = /datum/id_trim/job/clown
	possessed_message = "You are a honkbot! Make sure the crew are having a great time!"
	///our voicelines
	var/static/list/honkbot_sounds = list(
		HONKBOT_VOICED_HONK_HAPPY = 'sound/items/bikehorn.ogg',
		HONKBOT_VOICED_HONK_SAD = 'sound/misc/sadtrombone.ogg',
	)
	///Honkbot's flags
	var/honkbot_flags = HONKBOT_CHECK_RECORDS | HONKBOT_HANDCUFF_TARGET | HONKBOT_MODE_SLIP

/mob/living/basic/bot/honkbot/Initialize(mapload)
	. = ..()
	var/static/list/clown_friends = typecacheof(list(
		/mob/living/carbon/human,
		/mob/living/silicon/robot,
	))
	ai_controller.set_blackboard_key(BB_CLOWNS_LIST, clown_friends)
	var/static/list/slippery_items = typecacheof(list(
		/obj/item/grown/bananapeel,
		/obj/item/soap,
	))
	ai_controller.set_blackboard_key(BB_SLIPPERY_ITEMS, slippery_items)

	var/datum/action/cooldown/mob_cooldown/bot/honk/bike_honk = new(src)
	bike_honk.Grant(src)
	bike_honk.post_honk_callback = CALLBACK(src, PROC_REF(set_attacking_state))
	ai_controller.set_blackboard_key(BB_HONK_ABILITY, bike_honk)

	AddComponent(/datum/component/slippery,\
		knockdown = 6 SECONDS,\
		paralyze = 3 SECONDS,\
		on_slip_callback = CALLBACK(src, PROC_REF(post_slip)),\
		can_slip_callback = CALLBACK(src, PROC_REF(pre_slip)),\
	)
	AddComponent(/datum/component/stun_n_cuff,\
		stun_sound = 'sound/items/airhorn/AirHorn.ogg',\
		post_stun_callback = CALLBACK(src, PROC_REF(post_stun)),\
		post_arrest_callback = CALLBACK(src, PROC_REF(post_arrest)),\
		handcuff_type = /obj/item/restraints/handcuffs/cable/zipties/fake,\
	)

/mob/living/basic/bot/honkbot/generate_speak_list()
	return honkbot_sounds

/mob/living/basic/bot/honkbot/proc/pre_slip()
	return (prob(70) && ai_controller?.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))

/mob/living/basic/bot/honkbot/proc/post_slip()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/basic/bot, speak), HONKBOT_VOICED_HONK_SAD)
	set_attacking_state()

/mob/living/basic/bot/honkbot/proc/set_attacking_state()
	icon_state = "[base_icon_state]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 0.2 SECONDS)

/mob/living/basic/bot/honkbot/proc/post_arrest(mob/living/carbon/current_target)
	playsound(src, (bot_access_flags & BOT_COVER_EMAGGED ? SFX_HONKBOT_E : 'sound/items/bikehorn.ogg'), 50, FALSE)
	icon_state = bot_access_flags & BOT_COVER_EMAGGED ? "[base_icon_state]-e" : "[base_icon_state]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/mob/living/basic/bot/honkbot/proc/post_stun(mob/living/carbon/current_target)
	if(!istype(current_target))
		return

	current_target.set_stutter(40 SECONDS)
	current_target.set_jitter_if_lower(100 SECONDS)
	set_attacking_state()
	if(HAS_TRAIT(current_target, TRAIT_DEAF))
		return

	var/obj/item/organ/ears/target_ears = current_target.get_organ_slot(ORGAN_SLOT_EARS)
	target_ears?.adjustEarDamage(0, 5)

/mob/living/basic/bot/honkbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || HAS_SILICON_ACCESS(user))
		data["custom_controls"]["slip_people"] = honkbot_flags & HONKBOT_MODE_SLIP
		data["custom_controls"]["fake_cuff"] = honkbot_flags & HONKBOT_HANDCUFF_TARGET
		data["custom_controls"]["check_ids"] = honkbot_flags & HONKBOT_CHECK_IDS
		data["custom_controls"]["check_records"] = honkbot_flags & HONKBOT_CHECK_RECORDS
	return data

/mob/living/basic/bot/honkbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || !isliving(user) || (bot_access_flags & BOT_COVER_LOCKED) && !HAS_SILICON_ACCESS(user))
		return
	switch(action)
		if("slip_people")
			honkbot_flags ^= HONKBOT_MODE_SLIP
		if("fake_cuff")
			honkbot_flags ^= HONKBOT_HANDCUFF_TARGET
		if("check_ids")
			honkbot_flags ^= HONKBOT_CHECK_IDS
		if("check_records")
			honkbot_flags ^= HONKBOT_CHECK_RECORDS
