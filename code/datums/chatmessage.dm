///the layer value given to the message image in the last animation step after the image has faded.
///used for either the initialization animation sequence or the edited stage 2 duration animation sequence.
///to the server the images layer is set instantly to this value, but the client cant see it because its only adjusted for them
/// after the message is inivisible. so this is used to mark what animation is being used for the server.
#define MESSAGE_ANIMATION_DEFAULT_LAYER_MARK 1020
///the layer value given to the message image for the animation sequence where the image is forced into fading.
///used so that the server doesnt force the image to fade twice.
#define MESSAGE_ANIMATION_FORCE_FADE_LAYER_MARK 1021
///the layer mark given to the last stage of the animation sequence after it has been edited but not forced into the fading animation.
#define MESSAGE_ANIMATION_EDIT_FADE_LAYER_MARK 1022

/**
 * # Chat Message Overlay
 *
 * Datum for generating a message overlay on the map
 */
/datum/chatmessage
	/// list of images generated for the message sent to each hearing client.
	/// associative list of the form: list(message image = client using that image)
	var/list/image/messages
	/// The clients who heard this message. only populated with clients that have been assigned an image
	/// associative list of the form: list(client who hears this message = chat message image that client uses)
	var/list/client/hearers
	/// all clients that have been assigned to this chatmessage datum from create_chat_message().
	/// needed to ensure that the same client cant be a hearer to a message twice.
	/// associative list of the form: list(client = TRUE)
	var/list/client/all_hearers
	/// The location in which the message is appearing
	var/atom/message_loc
	/// the full edited message the speaker created, might be edited by subsequent hearers
	var/template_message = ""
	/// what language the message is spoken in.
	var/datum/language/message_language
	/// Contains the approximate amount of lines for height decay for each message image.
	/// associative list of the form: list(message image = approximate lines for that image)
	var/list/approx_lines

	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Contains the hash of our main assigned timer for the end_of_life fading event. by the time this timer executes all clients should have
	///already seen the end of the maptext animation sequence and cant see their message anymore. so this will remove all message images from all clients
	var/fadertimer = null

	///concatenated string of parameters given to us at creation
	var/creation_parameters = ""
	///if TRUE, then this datum was dropped from its spot in SSrunechat.messages_by_creation_string and thus wont remove that spot of the list.
	var/dropped_hash = FALSE
	///how long the main stage of this message lasts (maptext fully visible) by default.
	var/lifespan = 0
	///associative list of the form: list(message image = world.time that image is set to fade out)
	var/list/fade_times_by_image
	///what world.time this message datum was created.
	var/creation_time = 0

/**
 * Constructs a chat message overlay
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The mob that owns this overlay, only this mob will be able to view it
 * * language - The language this message was spoken in
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/chatmessage/New(text, atom/target, datum/language/language, list/extra_classes = list(), lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")

	creation_parameters = "[text]-[REF(target)]-[language]-[list2params(extra_classes)]-[lifespan]-[world.time]"

	current_z_idx++
	// Reset z index if relevant
	if (current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	message_loc = isturf(target) ? target : get_atom_on_turf(target)
	RegisterSignal(message_loc, COMSIG_PARENT_QDELETING, .proc/end_of_life)

	creation_time = world.time
	src.lifespan = lifespan
	///how long this datum will actually exist for. its how long the default message animations take + 1 second buffer
	var/total_existence_time = CHAT_MESSAGE_SPAWN_TIME + lifespan + CHAT_MESSAGE_EOL_FADE + 1 SECONDS
	fadertimer = addtimer(CALLBACK(src, .proc/end_of_life), total_existence_time, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)

	//in the case of a hash collision this will drop the older chatmessage datum from this list. this is fine however
	//since the dropped datum will still properly handle itself including deletion etc.
	//all this means is that you cant create message A on x listeners in some synchronous code execution loop,
	//then later on start a message B with the exact same parameters (so theres a hash collision) on y listeners
	//and then afterwards try to again add more listeners to message A.
	//if A and B have the exact same creation_parameters then the code has to assume that all listeners after B belong to B not A
	if(SSrunechat.messages_by_creation_string[creation_parameters])
		var/datum/chatmessage/old_message = SSrunechat.messages_by_creation_string[creation_parameters]
		old_message.dropped_hash = TRUE

	SSrunechat.messages_by_creation_string[creation_parameters] = src

	messages = list()
	hearers = list()
	approx_lines = list()
	fade_times_by_image = list()
	all_hearers = list()

/datum/chatmessage/Destroy()
	for(var/client/hearer in all_hearers)
		LAZYREMOVEASSOC(hearer.seen_messages, message_loc, src)

		if(istype(hearers[hearer], /image))
			hearer.images -= hearers[hearer]

	for(var/datum/callback/queued_callback as anything in SSrunechat.message_queue)
		if(!queued_callback)
			SSrunechat.message_queue -= queued_callback
			continue

		if(queued_callback.object == src)
			SSrunechat.message_queue -= queued_callback
			qdel(queued_callback)
			break

	if(!dropped_hash)
		SSrunechat.messages_by_creation_string -= creation_parameters

	message_loc = null

	messages = null
	hearers = null
	all_hearers = null
	approx_lines = null
	fadertimer = null

	return ..()

/datum/chatmessage/proc/end_of_life()
	SIGNAL_HANDLER
	qdel(src)

/datum/chatmessage/proc/on_hearer_qdel(client/hearer)
	SIGNAL_HANDLER
	if(!istype(hearer))
		return

	LAZYREMOVEASSOC(hearer.seen_messages, message_loc, src)
	if(istype(hearers?[hearer], /image))
		var/image/seen_image = hearers[hearer]
		messages -= seen_image

	hearers -= hearer
	all_hearers -= hearer

/**
 * generates the spanned text used for the final image and creates a callback in SSrunechat to call generate_image() next tick.
 * This proc exists solely to handle everything in the image creation process before MeasureText() returns, as otherwise when the client
 * returns the results of MeasureText() we are in the verb execution portion of the tick which means we're in danger of overtiming.
 * delaying the final image processing to SSrunechat's next fire() fixes this.
 *
 * Arguments:
 * * text - the text used in the image, gets edited if it holds non allowed characters and/or the listener doesnt understand the speakers language
 * * target - the atom creating the message being heard by others. the image we create will have its loc assigned to this atom
 * * owner - the mob hearing the message from target, must have a client
 * * lanugage - the language typepath this message is spoken in
 * * extra_classes - the spans used for this message
 */
/datum/chatmessage/proc/prepare_text(text, atom/target, mob/owner, datum/language/language, list/extra_classes)
	set waitfor = FALSE //because this waits on client input
	/// Cached icons to show what language the user is speaking
	var/static/list/language_icons

	var/client/owned_by = owner.client
	if(!owned_by)
		return FALSE

	LAZYSET(all_hearers, owned_by, TRUE)
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, .proc/on_hearer_qdel)

	// Remove spans in the message from things like the recorder
	var/static/regex/span_check = new(@"<\/?span[^>]*>", "gi")
	text = replacetext(text, span_check, "")

	// Clip message
	var/maxlen = owned_by.prefs.read_preference(/datum/preference/numeric/max_chat_length)
	if (length_char(text) > maxlen)
		text = copytext_char(text, 1, maxlen + 1) + "..." // BYOND index moment

	// Calculate target color if not already present
	if (!target.chat_color || target.chat_color_name != target.name)
		target.chat_color = colorize_string(target.name)
		target.chat_color_darkened = colorize_string(target.name, 0.85, 0.85)
		target.chat_color_name = target.name

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	// Non mobs speakers can be small
	if (!ismob(target))
		extra_classes |= "small"

	var/list/prefixes

	// Append radio icon if from a virtual speaker
	if (extra_classes.Find("virtual-speaker"))
		var/image/r_icon = image('icons/ui_icons/chat/chat_icons.dmi', icon_state = "radio")
		LAZYADD(prefixes, "\icon[r_icon]")
	else if (extra_classes.Find("emote"))
		var/image/r_icon = image('icons/ui_icons/chat/chat_icons.dmi', icon_state = "emote")
		LAZYADD(prefixes, "\icon[r_icon]")

	// Append language icon if the language uses one
	var/datum/language/language_instance = GLOB.language_datum_instances[language]
	if (language_instance?.display_icon(owner))
		var/icon/language_icon = LAZYACCESS(language_icons, language)
		if (isnull(language_icon))
			language_icon = icon(language_instance.icon, icon_state = language_instance.icon_state)
			language_icon.Scale(CHAT_MESSAGE_ICON_SIZE, CHAT_MESSAGE_ICON_SIZE)
			LAZYSET(language_icons, language, language_icon)
		LAZYADD(prefixes, "\icon[language_icon]")

	text = "[prefixes?.Join("&nbsp;")][text]"

	// We dim italicized text to make it more distinguishable from regular text
	var/tgt_color = extra_classes.Find("italics") ? target.chat_color_darkened : target.chat_color

	// Approximate text height
	var/complete_text = "<span class='center [extra_classes.Join(" ")]' style='color: [tgt_color]'>[owner.say_emphasis(text)]</span>"
	var/measurement = owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH)//resolving it to a var so the macro doesnt call MeasureText() twice

	//fun fact: MeasureText() works by waiting for the client to send back the measurements for the text. meaning it works like a verb.
	//procs like this are called at the last section of hte tick before it ends, meaning if the other portions used up most of it,
	//then everything after this point is likely to overtime. queuing the message completion if the server is overloaded fixes this
	if(!owned_by || QDELETED(src) || QDELETED(message_loc) || !all_hearers?[owned_by])
		return //we should already have been qdel'd() if this evaluates to TRUE, doing it now would throw an error

	var/mheight = WXH_TO_HEIGHT(measurement)
	if(TICK_CHECK)
		SSrunechat.message_queue += CALLBACK(src, .proc/generate_image, target, owner, complete_text, mheight)
	else
		generate_image(target, owner, complete_text, mheight)


/**
 * actually generates the runechat image for the message spoken by target and heard by owner.
 *
 * Arguments:
 * * target - the atom creating the message being heard by others. the image we create will have its loc assigned to this atom
 * * owner - the mob hearing the message from target, must have a client
 * * complete_text - the complete text used to create the images maptext
 * * mheight - height of the complete text returned by MeasureText() in pixels i think idfk
 */
/datum/chatmessage/proc/generate_image(atom/target, mob/owner, complete_text, mheight)
	var/client/owned_by = owner.client
	if(!owned_by || QDELETED(target) || QDELETED(src))//possible now since generate_image() is called via a queue
		return

	var/our_approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	if (owned_by.seen_messages)
		var/idx = 1
		var/combined_height = our_approx_lines

		for(var/datum/chatmessage/preexisting_message as anything in owned_by.seen_messages[message_loc])
			if(QDELETED(preexisting_message))
				stack_trace("qdeleted message encountered in a clients seen_messages list!")
				LAZYREMOVEASSOC(owned_by.seen_messages, message_loc, preexisting_message)
				continue

			var/image/other_message_image = preexisting_message.hearers[owned_by]

			if(!other_message_image)
				continue //no image yet because the message hasnt been able to create an image.

			combined_height += preexisting_message.approx_lines[other_message_image]

			var/current_stage_2_time_left = preexisting_message.fade_times_by_image[other_message_image] - (world.time + CHAT_MESSAGE_SPAWN_TIME)

			//how much time remains in the "fully visible" stage of animation, after we adjust it. round it down to the nearest tick
			var/real_stage_2_time_left = round((current_stage_2_time_left) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height), world.tick_lag)

			///used to take away time from CHAT_MESSAGE_SPAWN_TIME's addition to the fading time
			var/non_abs_stage_2_time_left = real_stage_2_time_left
			real_stage_2_time_left = max(real_stage_2_time_left, 0)

			if(other_message_image.layer != MESSAGE_ANIMATION_FORCE_FADE_LAYER_MARK)
				//if the message isnt in stage 3 of the animation, adjust the length of stage 2. assume that stage 1 is over since its short
				//and taking that into account is harder than its worth. also check if theres enough time left after adjusting to bother
				if(preexisting_message.fade_times_by_image[other_message_image] > world.time && real_stage_2_time_left > 1 && other_message_image.layer != MESSAGE_ANIMATION_EDIT_FADE_LAYER_MARK)
					animate(other_message_image, alpha = 255, time = 0)
					animate(time = real_stage_2_time_left)
					animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)
					animate(layer = MESSAGE_ANIMATION_EDIT_FADE_LAYER_MARK, time = 0)

					preexisting_message.fade_times_by_image[other_message_image] = world.time + non_abs_stage_2_time_left + CHAT_MESSAGE_SPAWN_TIME

				//just start the fading early if theres no real time left. layer is only MESSAGE_ANIMATION_DEFAULT_LAYER_MARK to the server if this hasnt already happened to the image
				else if(real_stage_2_time_left <= 1)

					//to the server, animations complete their edits instantly, jumping to the last stage of the animation. so we need this step if the client
					//was still in the second stage of animation. if the time was wrong and the client was in the third stage of animation when the updated step
					//arrives, then this will look weird.
					animate(other_message_image, alpha = 0, time = CHAT_MESSAGE_EOL_FADE, flags = ANIMATION_PARALLEL)
					animate(layer = MESSAGE_ANIMATION_FORCE_FADE_LAYER_MARK, time = 0)

					preexisting_message.fade_times_by_image[other_message_image] = world.time //make sure we can tell afterwards if its already fading

			//make it move upwards
			animate(other_message_image, pixel_y = other_message_image.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME, flags = ANIMATION_PARALLEL)

	var/maptext_used = MAPTEXT(complete_text)
	var/maptext_x_used = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5

	var/image/message = create_new_image(target, maptext_used, mheight, maptext_x_used)

	//handle the client side animations for the image
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)
	animate(alpha = 255, time = lifespan)
	animate(alpha = 0, time = CHAT_MESSAGE_EOL_FADE)
	animate(layer = MESSAGE_ANIMATION_DEFAULT_LAYER_MARK, time = 0)
	//client wont see the results of this last step since it wont be visible. its just used to mark to the server whether the last animation stage was forced

	handle_new_image_association(message, owned_by, our_approx_lines)

/datum/chatmessage/proc/create_new_image(atom/target, maptext, mheight, maptext_x)
	var/static/mutable_appearance/template = create_runechat_template()
	template.layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx
	template.maptext_height = mheight
	template.pixel_y = target.maptext_height
	template.pixel_x = (target.maptext_width * 0.5) - 16
	template.maptext_x = maptext_x
	template.maptext = maptext

	// Build message image
	var/image/message = image(loc = message_loc)
	message.appearance = template.appearance

	return message

/proc/create_runechat_template()
	var/mutable_appearance/template = new()
	template.maptext_width = CHAT_MESSAGE_WIDTH
	template.plane = RUNECHAT_PLANE
	template.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	template.alpha = 0
	template.maptext_width = CHAT_MESSAGE_WIDTH

	return template


/datum/chatmessage/proc/handle_new_image_association(image/message_image, client/associated_client, approximate_lines, set_time = TRUE)
	if(!message_image || !associated_client)
		return

	associated_client.images |= message_image

	approx_lines[message_image] = approximate_lines
	if(set_time)
		fade_times_by_image[message_image] = world.time  + lifespan + CHAT_MESSAGE_SPAWN_TIME

	LAZYADDASSOCLIST(associated_client.seen_messages, message_loc, src)
	LAZYSET(messages, message_image, associated_client)
	LAZYSET(hearers, associated_client, message_image)

/**
 * Creates a message overlay at a defined location for a given speaker. assumes that this mob has a client
 *
 * Arguments:
 * * speaker - The atom who is saying this message
 * * message_language - The language that the message is said in
 * * raw_message - The text content of the message
 * * spans - Additional classes to be added to the message
 */
/mob/proc/create_chat_message(atom/movable/speaker, datum/language/message_language, raw_message, list/spans, runechat_flags = NONE)
	if(!client || SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(speaker, TRAIT_BYPASS_MEASURES))
		return

	// Check for virtual speakers (aka hearing a message through a radio)
	var/atom/movable/originalSpeaker = speaker
	if (istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/v = speaker
		speaker = v.source
		spans |= "virtual-speaker"

	// Ignore virtual speaker (most often radio messages) from ourself
	if (originalSpeaker != src && speaker == src)
		return

	var/datum/chatmessage/message_to_use
	var/text_to_use

	if(runechat_flags & EMOTE_MESSAGE)
		text_to_use = raw_message
		spans = list("emote", "italics")
	else
		text_to_use = lang_treat(speaker, message_language, raw_message, spans, null, TRUE)
		spans = spans ? spans.Copy() : list()

	message_to_use = SSrunechat.messages_by_creation_string["[text_to_use]-[REF(speaker)]-[message_language]-[list2params(spans)]-[CHAT_MESSAGE_LIFESPAN]-[world.time]"]
	//if an already existing message already has processed us as a hearer then we have to assume that this is from a new, identical message sent in the same tick
	//as the already existing one. thats the only time this can happen. if this is the case then create a new chatmessage
	if(!message_to_use || (message_to_use && message_to_use.all_hearers?[client]))
		message_to_use = new /datum/chatmessage(text_to_use, speaker, message_language, spans)

	message_to_use.prepare_text(text_to_use, speaker, src, message_language, spans)


// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN 0.6
#define CM_COLOR_SAT_MAX 0.7
#define CM_COLOR_LUM_MIN 0.65
#define CM_COLOR_LUM_MAX 0.75

/**
 * Gets a color for a name, will return the same color for a given string consistently within a round.atom
 *
 * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
 *
 * Arguments:
 * * name - The name to generate a color for
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"

#undef MESSAGE_ANIMATION_DEFAULT_LAYER_MARK
#undef MESSAGE_ANIMATION_FORCE_FADE_LAYER_MARK
