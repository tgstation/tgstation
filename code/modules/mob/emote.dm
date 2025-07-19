///How confused a carbon must be before they will vomit
#define BEYBLADE_PUKE_THRESHOLD (30 SECONDS)
///How must nutrition is lost when a carbon pukes
#define BEYBLADE_PUKE_NUTRIENT_LOSS 60
///How often a carbon becomes penalized
#define BEYBLADE_DIZZINESS_PROBABILITY 20
///How long the screenshake lasts
#define BEYBLADE_DIZZINESS_DURATION (20 SECONDS)
///How much confusion a carbon gets every time they are penalized
#define BEYBLADE_CONFUSION_INCREMENT (10 SECONDS)
///A max for how much confusion a carbon will be for beyblading
#define BEYBLADE_CONFUSION_LIMIT (40 SECONDS)

//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE, forced = FALSE)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)

	act = LOWER_TEXT(act)
	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional && !force_silence)
			to_chat(src, span_notice("'[act]' emote does not exist. Say *help for a list."))
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/emote in key_emotes)
		if(!emote.check_cooldown(src, intentional))
			silenced = TRUE
			continue
		if(!forced && !emote.can_run_emote(src, TRUE, intentional, param))
			continue
		if(SEND_SIGNAL(src, COMSIG_MOB_PRE_EMOTED, emote.key, param, m_type, intentional, emote) & COMPONENT_CANT_EMOTE)
			silenced = TRUE
			continue
		emote.run_emote(src, param, m_type, intentional)
		SEND_SIGNAL(src, COMSIG_MOB_EMOTE, emote, act, m_type, message, intentional)
		SEND_SIGNAL(src, COMSIG_MOB_EMOTED(emote.key))
		return TRUE
	if(intentional && !silenced && !force_silence)
		to_chat(src, span_notice("Unusable emote '[act]'. Say *help for a list."))
	return FALSE

/datum/emote/help
	key = "help"
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai, /mob/eye/imaginary_friend)

/datum/emote/help/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say [span_bold("\"*emote\"")]: \n")
	message += span_smallnoticeital("Note - emotes highlighted in blue play a sound \n\n")

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/emote_action in GLOB.emote_list[key])
			if(emote_action.key in keys)
				continue
			if(emote_action.can_run_emote(user, status_check = FALSE , intentional = TRUE))
				keys += emote_action.key

	keys = sort_list(keys)

	// the span formatting will mess up sorting so need to do it afterwards
	for(var/i in 1 to keys.len)
		for(var/datum/emote/emote_action in GLOB.emote_list[keys[i]])
			if(emote_action.get_sound(user) && emote_action.should_play_sound(user, intentional = TRUE))
				keys[i] = span_boldnotice(keys[i])

	message += keys.Join(", ")
	message += "."
	message = message.Join("")
	to_chat(user, boxed_message(message))

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer, /mob/eye/imaginary_friend)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai, /mob/eye/imaginary_friend)

/datum/emote/flip/run_emote(mob/user, params , type_override, intentional)
	. = ..()
	user.SpinAnimation(FLIP_EMOTE_DURATION, 1)

/datum/emote/flip/check_cooldown(mob/user, intentional)
	. = ..()
	if(.)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(isliving(user))
		var/mob/living/flippy_mcgee = user
		if(prob(20))
			flippy_mcgee.Knockdown(1 SECONDS)
			flippy_mcgee.visible_message(
				span_notice("[flippy_mcgee] attempts to do a flip and falls over, what a doofus!"),
				span_notice("You attempt to do a flip while still off balance from the last flip and fall down!")
			)
			if(prob(50))
				flippy_mcgee.adjustBruteLoss(1)
		else
			flippy_mcgee.visible_message(
				span_notice("[flippy_mcgee] stumbles a bit after their flip."),
				span_notice("You stumble a bit from still being off balance from your last flip.")
			)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer, /mob/eye/imaginary_friend)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/eye/imaginary_friend)

/datum/emote/spin/run_emote(mob/user, params,  type_override, intentional)
	. = ..()
	user.spin(20, 1)

/datum/emote/spin/check_cooldown(mob/living/carbon/user, intentional)
	. = ..()
	if(.)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(!iscarbon(user))
		return

	if(user.get_timed_status_effect_duration(/datum/status_effect/confusion) > BEYBLADE_PUKE_THRESHOLD)
		user.vomit(VOMIT_CATEGORY_KNOCKDOWN, lost_nutrition = BEYBLADE_PUKE_NUTRIENT_LOSS, distance = 0)
		return

	if(prob(BEYBLADE_DIZZINESS_PROBABILITY))
		to_chat(user, span_warning("You feel woozy from spinning."))
		user.set_dizzy_if_lower(BEYBLADE_DIZZINESS_DURATION)
		user.adjust_confusion_up_to(BEYBLADE_CONFUSION_INCREMENT, BEYBLADE_CONFUSION_LIMIT)

#undef BEYBLADE_PUKE_THRESHOLD
#undef BEYBLADE_PUKE_NUTRIENT_LOSS
#undef BEYBLADE_DIZZINESS_PROBABILITY
#undef BEYBLADE_DIZZINESS_DURATION
#undef BEYBLADE_CONFUSION_INCREMENT
#undef BEYBLADE_CONFUSION_LIMIT


/datum/emote/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps!"
	// Allows ghosts to jump
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	affected_by_pitch = FALSE

/datum/emote/jump/run_emote(mob/user, params, type_override, intentional)
	. = ..()

	jump_animation(user)

	if(!isliving(user))
		return
	for(var/obj/item/storage/box/squeeze_box in get_turf(user))
		squeeze_box.flatten_box()

/datum/emote/jump/proc/jump_animation(mob/user)
	var/original_transform = user.transform
	animate(user, transform = user.transform.Translate(0, 4), time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(transform = original_transform, time = 0.1 SECONDS)

/datum/emote/jump/get_sound(mob/user)
	return 'sound/items/weapons/thudswoosh.ogg'

// Avoids playing sounds if we're a ghost
/datum/emote/jump/should_play_sound(mob/user, intentional)
	if(isliving(user))
		return ..()
	return FALSE
