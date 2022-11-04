/datum/brain_trauma/special/imaginary_friend
	name = "Imaginary Friend"
	desc = "Patient can see and hear an imaginary person."
	scan_desc = "partial schizophrenia"
	gain_text = "<span class='notice'>You feel in good company, for some reason.</span>"
	lose_text = "<span class='warning'>You feel lonely again.</span>"
	var/mob/camera/imaginary_friend/friend
	var/friend_initialized = FALSE

/datum/brain_trauma/special/imaginary_friend/on_gain()
	var/mob/living/M = owner
	if(M.stat == DEAD || !M.client)
		qdel(src)
		return
	..()
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/on_life(delta_time, times_fired)
	if(get_dist(owner, friend) > 9)
		friend.recall()
	if(!friend)
		qdel(src)
		return
	if(!friend.client && friend_initialized)
		addtimer(CALLBACK(src, PROC_REF(reroll_friend)), 600)

/datum/brain_trauma/special/imaginary_friend/on_death()
	..()
	qdel(src) //friend goes down with the ship

/datum/brain_trauma/special/imaginary_friend/on_lose()
	..()
	QDEL_NULL(friend)

//If the friend goes afk, make a brand new friend. Plenty of fish in the sea of imagination.
/datum/brain_trauma/special/imaginary_friend/proc/reroll_friend()
	if(friend.client) //reconnected
		return
	friend_initialized = FALSE
	QDEL_NULL(friend)
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/proc/make_friend()
	friend = new(get_turf(owner), owner)

/datum/brain_trauma/special/imaginary_friend/proc/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as [owner.real_name]'s imaginary friend?", ROLE_PAI, null, 7.5 SECONDS, friend, POLL_IGNORE_IMAGINARYFRIEND)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		friend.key = C.key
		friend_initialized = TRUE
	else
		qdel(src)

/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	move_on_shuttle = TRUE
	desc = "A wonderful yet fake friend."
	see_in_dark = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	sight = SEE_BLACKNESS
	mouse_opacity = MOUSE_OPACITY_ICON
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	var/icon/human_image
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/mob/living/owner
	var/bubble_icon = "default"

	var/datum/action/innate/imaginary_join/join
	var/datum/action/innate/imaginary_hide/hide

/mob/camera/imaginary_friend/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	greet()
	Show()

/mob/camera/imaginary_friend/proc/greet()
	to_chat(src, span_notice("<b>You are the imaginary friend of [owner]!</b>"))
	to_chat(src, span_notice("You are absolutely loyal to your friend, no matter what."))
	to_chat(src, span_notice("You cannot directly influence the world around you, but you can see what [owner] cannot."))

/**
 * Arguments:
 * * imaginary_friend_owner - The living mob that owns the imaginary friend.
 * * appearance_from_prefs - If this is a valid set of prefs, the appearance of the imaginary friend is based on these prefs.
 */
/mob/camera/imaginary_friend/Initialize(mapload, mob/living/imaginary_friend_owner, datum/preferences/appearance_from_prefs = null)
	. = ..()

	owner = imaginary_friend_owner

	if(appearance_from_prefs)
		INVOKE_ASYNC(src, PROC_REF(setup_friend_from_prefs), appearance_from_prefs)
	else
		INVOKE_ASYNC(src, PROC_REF(setup_friend))

	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)

/mob/camera/imaginary_friend/proc/setup_friend()
	var/gender = pick(MALE, FEMALE)
	real_name = random_unique_name(gender)
	name = real_name
	human_image = get_flat_human_icon(null, pick(SSjob.joinable_occupations))

/**
 * Sets up the imaginary friend's name and look using a set of datum preferences.
 *
 * Arguments:
 * * appearance_from_prefs - If this is a valid set of prefs, the appearance of the imaginary friend is based on the currently selected character in them. Otherwise, it's random.
 */
/mob/camera/imaginary_friend/proc/setup_friend_from_prefs(datum/preferences/appearance_from_prefs)
	if(!istype(appearance_from_prefs))
		stack_trace("Attempted to create imaginary friend appearance from null prefs. Using random appearance.")
		setup_friend()
		return

	real_name = appearance_from_prefs.read_preference(/datum/preference/name/real_name)
	name = real_name

	// Determine what job is marked as 'High' priority.
	var/datum/job/appearance_job
	var/highest_pref = 0
	for(var/job in appearance_from_prefs.job_preferences)
		var/this_pref = appearance_from_prefs.job_preferences[job]
		if(this_pref > highest_pref)
			appearance_job = SSjob.GetJob(job)
			highest_pref = this_pref

	if(!appearance_job)
		appearance_job = SSjob.GetJob(JOB_ASSISTANT)

	if(istype(appearance_job, /datum/job/ai))
		human_image = icon('icons/mob/silicon/ai.dmi', icon_state = resolve_ai_icon(appearance_from_prefs.read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
		return

	if(istype(appearance_job, /datum/job/cyborg))
		human_image = icon('icons/mob/silicon/robots.dmi', icon_state = "robot")
		return

	human_image = get_flat_human_icon(null, appearance_job, appearance_from_prefs)

/mob/camera/imaginary_friend/proc/Show()
	if(!client) //nobody home
		return

	//Remove old image from owner and friend
	if(owner.client)
		owner.client.images.Remove(current_image)

	client.images.Remove(current_image)

	//Generate image from the static icon and the current dir
	current_image = image(human_image, src, , MOB_LAYER, dir=src.dir)
	current_image.override = TRUE
	current_image.name = name
	if(hidden)
		current_image.alpha = 150

	//Add new image to owner and friend
	if(!hidden && owner.client)
		owner.client.images |= current_image

	client.images |= current_image

/mob/camera/imaginary_friend/Destroy()
	if(owner?.client)
		owner.client.images.Remove(human_image)
	if(client)
		client.images.Remove(human_image)
	return ..()

/mob/camera/imaginary_friend/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	// I love old snowflake code where I can't inherit anything but have to copy-paste instead
	var/list/filter_result
	var/list/soft_filter_result
	if(client && !forced && !filterproof)
		//The filter doesn't act on the sanitized message, but the raw message.
		filter_result = CAN_BYPASS_FILTER(src) ? null : is_ic_filtered(message)
		if(!filter_result)
			soft_filter_result = CAN_BYPASS_FILTER(src) ? null : is_soft_ic_filtered(message)

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	if(filter_result  && !filterproof)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules."))
		to_chat(src, span_warning("\"[message]\""))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", message, filter_result)
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return

	if(soft_filter_result && !filterproof)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			SSblackbox.record_feedback("tally", "soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
			log_filter("Soft IC", message, filter_result)
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[message]\"")
		SSblackbox.record_feedback("tally", "passed_soft_ic_blocked_words", 1, lowertext(config.soft_ic_filter_regex.match))
		log_filter("Soft IC (Passed)", message, filter_result)

	if(client && !(ignore_spam || forced))
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_danger("You cannot speak IC (muted)."))
			return FALSE
		if(client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	friend_talk(message, spans, forced)

/mob/camera/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if (client?.prefs.read_preference(/datum/preference/toggle/enable_runechat) && (client.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)
	to_chat(src, compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods))

/mob/camera/imaginary_friend/proc/friend_talk(message, list/spans, forced = null)
	var/list/message_mods = list()
	message = get_message_mods(message, message_mods)
	message = capitalize(message)

	if(message_mods[RADIO_EXTENSION] == MODE_ADMIN)
		client?.cmd_admin_say(message)
		return

	if(message_mods[RADIO_EXTENSION] == MODE_DEADMIN)
		client?.dsay(message)
		return

	if(message_mods[MODE_SING])
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		message = "[randomnote] [capitalize(message)] [randomnote]"
		spans |= SPAN_SINGING

	var/eavesdrop_range = 0
	var/eavesdropped_message = ""

	if (message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		message = message_mods[MODE_CUSTOM_SAY_EMOTE]
		log_message(message, LOG_RADIO_EMOTE)
	else
		if(message_mods[WHISPER_MODE] == MODE_WHISPER)
			log_say(message, LOG_WHISPER, tag="imaginary friend", forced_by = forced, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])
			spans |= SPAN_ITALICS
			eavesdrop_range = EAVESDROP_EXTRA_RANGE
			// "This proc is dangerously laggy, avoid it or die"
			// What other option do I have here? I guess I'll die
			eavesdropped_message = stars(message)
		else
			log_say(message, LOG_SAY, tag="imaginary friend", forced_by = forced, custom_say_emote = message_mods[MODE_CUSTOM_SAY_EMOTE])

	var/quoted_message = say_quote(say_emphasis(message), spans, message_mods)
	var/rendered = "<span class='game say'>[span_name("[name]")] <span class='message'>[quoted_message]</span></span>"
	var/dead_rendered = "<span class='game say'>[span_name("[name] (Imaginary friend of [owner])")] <span class='message'>[quoted_message]</span></span>"

	var/language = owner.language_holder.get_selected_language()
	Hear(rendered, src, language, message, null, spans, message_mods)
	if(eavesdrop_range && get_dist(src, owner) > 1 + eavesdrop_range)
		rendered = "<span class='game say'>[span_name("[name]")] <span class='message'>[say_quote(say_emphasis(eavesdropped_message), spans, message_mods)]</span></span>"
		owner.Hear(rendered, src, language, eavesdropped_message, null, spans, message_mods)
	else
		owner.Hear(rendered, src, language, message, null, spans, message_mods)

	// Speech bubble, but only for those who have runechat off
	var/list/friend_clients = list(src.client, owner.client)
	var/list/speech_bubble_recipients = list()
	for(var/client/friend_client in friend_clients)
		if(friend_client && (!friend_client.prefs.read_preference(/datum/preference/toggle/enable_runechat) || (SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES))))
			speech_bubble_recipients.Add(friend_client)

	var/image/bubble = image('icons/mob/effects/talk.dmi', src, "[bubble_icon][say_test(message)]", FLY_LAYER)
	SET_PLANE_EXPLICIT(bubble, ABOVE_GAME_PLANE, src)
	bubble.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, bubble, speech_bubble_recipients, 3 SECONDS)
	LAZYADD(update_on_z, bubble)
	addtimer(CALLBACK(src, .proc/clear_saypopup, bubble), 3.5 SECONDS)

	var/turf/center_turf = get_turf(src)
	if(!center_turf)
		return

	for(var/mob/dead_player in GLOB.dead_mob_list)
		if(dead_player.z != z || get_dist(src, dead_player) > 7)
			if(eavesdrop_range)
				if(!(dead_player.client?.prefs.chat_toggles & CHAT_GHOSTWHISPER))
					continue
			else if(!(dead_player.client?.prefs.chat_toggles & CHAT_GHOSTEARS))
				continue
		var/link = FOLLOW_LINK(dead_player, owner)
		to_chat(dead_player, "[link] [dead_rendered]")

/mob/camera/imaginary_friend/proc/clear_saypopup(image/say_popup)
	LAZYREMOVE(update_on_z, say_popup)

/mob/camera/imaginary_friend/create_thinking_indicator()
	if(active_thinking_indicator || active_typing_indicator || !thinking_IC)
		return FALSE
	active_thinking_indicator = image('icons/mob/effects/talk.dmi', src, "[bubble_icon]3", TYPING_LAYER)
	add_image_to_clients(active_thinking_indicator, list(src.client, owner.client))

/mob/camera/imaginary_friend/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	remove_image_from_clients(active_thinking_indicator, list(src.client, owner.client))
	active_thinking_indicator = null

/mob/camera/imaginary_friend/create_typing_indicator()
	if(active_typing_indicator || active_thinking_indicator || !thinking_IC)
		return FALSE
	active_typing_indicator = image('icons/mob/effects/talk.dmi', src, "[bubble_icon]0", TYPING_LAYER)
	add_image_to_clients(active_typing_indicator, list(src.client, owner.client))

/mob/camera/imaginary_friend/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	remove_image_from_clients(active_typing_indicator, list(src.client, owner.client))
	active_typing_indicator = null

/mob/camera/imaginary_friend/remove_all_indicators()
	thinking_IC = FALSE
	remove_thinking_indicator()
	remove_typing_indicator()

/mob/camera/imaginary_friend/Move(NewLoc, Dir = 0)
	if(world.time < move_delay)
		return FALSE
	setDir(Dir)
	if(get_dist(src, owner) > 9)
		recall()
		move_delay = world.time + 10
		return FALSE
	abstract_move(NewLoc)
	move_delay = world.time + 1

/mob/camera/imaginary_friend/keybind_face_direction(direction)
	. = ..()
	Show()

/mob/camera/imaginary_friend/abstract_move(atom/destination)
	. = ..()
	Show()

/mob/camera/imaginary_friend/proc/recall()
	if(!owner || loc == owner)
		return FALSE
	abstract_move(owner)

/datum/action/innate/imaginary_join
	name = "Join"
	desc = "Join your owner, following them from inside their mind."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "join"

/datum/action/innate/imaginary_join/Activate()
	var/mob/camera/imaginary_friend/I = owner
	I.recall()

/datum/action/innate/imaginary_hide
	name = "Hide"
	desc = "Hide yourself from your owner's sight."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "hide"

/datum/action/innate/imaginary_hide/proc/update_status()
	var/mob/camera/imaginary_friend/I = owner
	if(I.hidden)
		name = "Show"
		desc = "Become visible to your owner."
		button_icon_state = "unhide"
	else
		name = "Hide"
		desc = "Hide yourself from your owner's sight."
		button_icon_state = "hide"
	UpdateButtons()

/datum/action/innate/imaginary_hide/Activate()
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = !I.hidden
	I.Show()
	update_status()

//down here is the trapped mind
//like imaginary friend but a lot less imagination and more like mind prison//

/datum/brain_trauma/special/imaginary_friend/trapped_owner
	name = "Trapped Victim"
	desc = "Patient appears to be targeted by an invisible entity."
	gain_text = ""
	lose_text = ""
	random_gain = FALSE

/datum/brain_trauma/special/imaginary_friend/trapped_owner/make_friend()
	friend = new /mob/camera/imaginary_friend/trapped(get_turf(owner), src)

/datum/brain_trauma/special/imaginary_friend/trapped_owner/reroll_friend() //no rerolling- it's just the last owner's hell
	if(friend.client) //reconnected
		return
	friend_initialized = FALSE
	QDEL_NULL(friend)
	qdel(src)

/datum/brain_trauma/special/imaginary_friend/trapped_owner/get_ghost() //no randoms
	return

/mob/camera/imaginary_friend/trapped
	name = "figment of imagination?"
	real_name = "figment of imagination?"
	desc = "The previous host of this body."

/mob/camera/imaginary_friend/trapped/greet()
	to_chat(src, span_notice("<b>You have managed to hold on as a figment of the new host's imagination!</b>"))
	to_chat(src, span_notice("All hope is lost for you, but at least you may interact with your host. You do not have to be loyal to them."))
	to_chat(src, span_notice("You cannot directly influence the world around you, but you can see what the host cannot."))

/mob/camera/imaginary_friend/trapped/setup_friend()
	real_name = "[owner.real_name]?"
	name = real_name
	human_image = icon('icons/mob/simple/lavaland/lavaland_monsters.dmi', icon_state = "curseblob")
