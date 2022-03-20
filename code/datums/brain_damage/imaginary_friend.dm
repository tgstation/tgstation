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
		addtimer(CALLBACK(src, .proc/reroll_friend), 600)

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
	sight = NONE
	mouse_opacity = MOUSE_OPACITY_ICON
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	var/icon/human_image
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/mob/living/owner

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
		INVOKE_ASYNC(src, .proc/setup_friend_from_prefs, appearance_from_prefs)
	else
		INVOKE_ASYNC(src, .proc/setup_friend)

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
		human_image = icon('icons/mob/ai.dmi', icon_state = resolve_ai_icon(appearance_from_prefs.read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
		return

	if(istype(appearance_job, /datum/job/cyborg))
		human_image = icon('icons/mob/robots.dmi', icon_state = "robot")
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

/mob/camera/imaginary_friend/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && src.client.handle_spam_prevention(message,MUTE_IC))
			return

	friend_talk(message)

/mob/camera/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if (client?.prefs.read_preference(/datum/preference/toggle/enable_runechat) && (client.prefs.read_preference(/datum/preference/toggle/enable_runechat_non_mobs) || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)
	to_chat(src, compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods))

/mob/camera/imaginary_friend/proc/friend_talk(message)
	message = capitalize(trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	src.log_talk(message, LOG_SAY, tag="imaginary friend")

	var/rendered = "<span class='game say'>[span_name("[name]")] <span class='message'>[say_quote(message)]</span></span>"
	var/dead_rendered = "<span class='game say'>[span_name("[name] (Imaginary friend of [owner])")] <span class='message'>[say_quote(message)]</span></span>"

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")

	//speech bubble
	if(owner.client)
		var/mutable_appearance/MA = mutable_appearance('icons/mob/talk.dmi', src, "default[say_test(message)]", FLY_LAYER)
		MA.plane = ABOVE_GAME_PLANE
		MA.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, MA, list(owner.client), 30)

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, owner)
		to_chat(M, "[link] [dead_rendered]")

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
	UpdateButtonIcon()

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
	human_image = icon('icons/mob/lavaland/lavaland_monsters.dmi', icon_state = "curseblob")
