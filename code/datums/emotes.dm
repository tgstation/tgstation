#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/message = "" //Message displayed when emote is used
	var/message_mime = "" //Message displayed if the user is a mime
	var/message_alien = "" //Message displayed if the user is a grown alien
	var/message_larva = "" //Message displayed if the user is an alien larva
	var/message_robot = "" //Message displayed if the user is a robot
	var/message_AI = "" //Message displayed if the user is an AI
	var/message_monkey = "" //Message displayed if the user is a monkey
	var/message_simple = "" //Message to display if the user is a simple_animal
	var/message_param = "" //Message to display if a param was given
	var/emote_type = EMOTE_VISIBLE //Whether the emote is visible or audible
	var/restraint_check = FALSE //Checks if the mob is restrained before performing the emote
	var/muzzle_ignore = FALSE //Will only work if the emote is EMOTE_AUDIBLE
	var/list/mob_type_allowed_typecache = list() //Types that are allowed to use that emote
	var/list/mob_type_blacklist_typecache = list() //Types that are NOT allowed to use that emote
	var/stat_allowed = CONSCIOUS
	var/static/list/emote_list = list()

/datum/emote/New()
	..()
	if(key_third_person)
		emote_list[key_third_person] = src
	mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)

/datum/emote/proc/run_emote(mob/user, params = null, type_override = null)
	. = TRUE
	if(!can_run_emote(user))
		return FALSE
	var/msg = select_message_type(user)
	if(params && message_param)
		msg = select_param(user, params)
	if(findtext(msg, "their"))
		msg = replacetext(msg, "their", user.p_their())
	if(findtext(msg, "them"))
		msg = replacetext(msg, "them", user.p_them())
	if(findtext(msg, "%s"))
		msg = replacetext(msg, "%s", user.p_s())

	var/mob/living/L = user
	for(var/obj/item/weapon/implant/I in L.implants)
		I.trigger(key, L)

	if(!msg)
		return FALSE

	user.log_message(msg, INDIVIDUAL_EMOTE_LOG)
	msg = "<b>[user]</b> " + msg

	for(var/mob/M in GLOB.dead_mob_list)
		if(!M.client || isnewplayer(M))
			continue
		var/T = get_turf(src)
		if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(T, null)))
			M.show_message(msg)

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg)
	else
		user.visible_message(msg)
	log_emote("[key_name(user)] : [msg]")

/datum/emote/proc/select_message_type(mob/user)
	. = message
	if(!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(user.mind && user.mind.miming && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(iscyborg(user) && message_robot)
		. = message_robot
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkey(user) && message_monkey)
		. = message_monkey
	else if(istype(user, /mob/living/simple_animal) && message_simple)
		. = message_simple

/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/datum/emote/proc/can_run_emote(mob/user, help_check)
	. = TRUE
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE
	if(!help_check)
		if(user.stat > stat_allowed  || (user.status_flags & FAKEDEATH))
			return FALSE
		if(restraint_check && user.restrained())
			return FALSE
		if(user.reagents && user.reagents.has_reagent("mimesbane"))
			return FALSE


/datum/emote/sound
	var/sound //Sound to play when emote is called
	var/vary = FALSE	//used for the honk borg emote
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon)

/datum/emote/sound/run_emote(mob/user, params)
	. = ..()
	if(.)
		playsound(user.loc, sound, 50, vary)
