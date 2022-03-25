/**
 * # Chat Message Overlay
 *
 * Datum for generating a message overlay on the map
 */
/datum/chatmessage
	/// list of images generated for the message sent to each hearing client.
	/// associative list of the form: list(message image = list(clients using that image))
	var/list/image/messages = list()
	/// The clients who heard this message.
	/// associative list of the form: list(client who hears this message = chat message image that client uses)
	var/list/client/hearers = list()
	/// The location in which the message is appearing
	var/atom/message_loc
	/// the full edited message the speaker created, might be edited by subsequent hearers
	var/template_message = ""
	/// what language the message is spoken in.
	var/datum/language/message_language
	/// Contains the scheduled destruction time, used for scheduling EOL
	var/scheduled_destruction
	/// Contains the time that the EOL for the message will be complete, used for qdel scheduling
	var/eol_complete
	/// Contains the approximate amount of lines for height decay for each message image.
	/// associative list of the form: list(message image = approximate lines for that image)
	var/list/approx_lines = list()

	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Contains the hash of our main assigned timer for the end_of_life fading event
	var/fadertimer = null
	/// lazy list version of fadertimer filled with timer hashes for hearers that get their messages removed at a different time than the default time.
	/// associative lazy list of the form: list(hearer client with different message removal time = fadertimer set to that hearer)
	var/list/fadertimers_by_hearer
	/// States if end_of_life is being executed
	var/is_fading = FALSE
	/// lazy list version of is_fading that gets filled with hearers that get their message images removed at a different time than the default EOL time.
	/// associative lazy list of the form: list(hearer with different message removal time  = whether that hearers message is in the fading stage yet)
	var/list/override_is_fading

	///one of the three final determiners of whether a client gets a new or reused message
	///associative list of the form: list(maptext = list(all images using that exact maptext))
	var/list/images_by_maptext = list()
	///one of the three final determiners of whether a client gets a new or reused message
	///associative list of the form: list(mheight = list(all images using that exact mheight))
	var/list/images_by_mheight = list()
	///one of the three final determiners of whether a client gets a new or reused message
	///associative list of the form: list(maptext_x = list(all images using that exact maptext_x))
	var/list/images_by_maptext_x = list()
	///concatenated string of parameters given to us at creation
	var/creation_parameters = ""
	///if TRUE, then this datum was dropped from its spot in SSrunechat.messages_by_creation_string and thus wont remove that spot of the list.
	var/dropped_hash = FALSE

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

	// Register with the runechat SS to handle EOL and destruction
	fadertimer = addtimer(CALLBACK(src, .proc/end_of_life), lifespan - CHAT_MESSAGE_EOL_FADE, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)

	//in the case of a hash collision this WILL drop the older chatmessage datum from this list. this is fine however
	//since the dropped datum will still properly handle itself including deletion etc.
	//all this means is that you cant create message A on x listeners in some synchronous code execution loop,
	//then later on start a message B with the exact same parameters (so theres a hash collision) on y listeners
	//and then afterwards try to again add more listeners to message A.
	//if A and B have the exact same creation_parameters then the code has to assume that all listeners after B belong to B not A
	if(SSrunechat.messages_by_creation_string[creation_parameters])
		var/datum/chatmessage/old_message = SSrunechat.messages_by_creation_string[creation_parameters]
		old_message.dropped_hash = TRUE

	SSrunechat.messages_by_creation_string[creation_parameters] = src

/datum/chatmessage/Destroy()
	for(var/client/hearer in hearers)
		LAZYREMOVEASSOC(hearer.seen_messages, message_loc, src)

		if(istype(hearers[hearer], /image))
			hearer.images -= hearers[hearer]

	if(!dropped_hash)
		SSrunechat.messages_by_speaker -= creation_string

	message_loc = null

	messages = null
	hearers = null
	approx_lines = null

	images_by_maptext = null
	images_by_maptext_x = null
	images_by_mheight = null
	return ..()

/**
 * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion,
 * sets timer for scheduling deletion
 *
 * Arguments:
 * * fadetime - The amount of time to animate the message's fadeout for
 */
/datum/chatmessage/proc/end_of_life(fadetime = CHAT_MESSAGE_EOL_FADE)
	is_fading = TRUE
	for(var/image/message as anything in messages)
		animate(message, alpha = 0, time = fadetime, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), fadetime, TIMER_DELETE_ME, SSrunechat)

/datum/chatmessage/proc/on_hearer_qdel(datum/source)
	SIGNAL_HANDLER
	if(!istype(source, /client))
		return

	var/client/hearer = source
	LAZYREMOVEASSOC(hearer.seen_messages, message_loc, src)
	if(istype(hearers[hearer], /image))
		var/image/seen_image = hearers[hearer]
		hearer.images -= seen_image
		messages[seen_image] -= hearer

	hearers -= hearer

///preset /mutable_appearance subtype just to prefill some constant runechat image vars
/mutable_appearance/runechat_template
	plane = RUNECHAT_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	alpha = 0
	maptext_width = CHAT_MESSAGE_WIDTH

/**
 * actually generates the runechat image for the message spoken by target and heard by owner.
 *
 * Arguments:
 * * text - the text used in the image, gets edited if it holds non allowed characters and/or the listener doesnt understand the speakers language
 * * target - the atom creating the message being heard by others. the image we create will have its loc assigned to this atom
 * * owner - the mob hearing the message from target, must have a client
 * * lanugage - the language typepath this message is spoken in
 * * extra_classes - the spans used for this message
 */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, datum/language/language, list/extra_classes)
	set waitfor = FALSE //because this waits on client input
	/// Cached icons to show what language the user is speaking
	var/static/list/language_icons

	// Register client who hears this message
	var/client/owned_by = owner.client
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
	var/mheight = WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH))
	var/our_approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	if (owned_by.seen_messages)
		var/idx = 1
		var/combined_height = our_approx_lines

		for(var/datum/chatmessage/preexisting_message as anything in owned_by.seen_messages[message_loc])

			var/image/other_message_image = preexisting_message.hearers[owned_by]
			animate(other_message_image, pixel_y = other_message_image.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			combined_height += preexisting_message.approx_lines[other_message_image]

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL has been executed.
			if (!preexisting_message.is_fading && !preexisting_message.override_is_fading?[owned_by])
				var/their_timer_hash = preexisting_message.fadertimers_by_hearer?[owned_by] || preexisting_message.fadertimer

				var/sched_remaining = SSrunechat.get_time_remaining(their_timer_hash)

				var/remaining_time = (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height)

				preexisting_message.split_canon_event(owned_by, remaining_time)//make the image that client uses different


				/*if (round(DS2TICKS(remaining_time))//check if more than one tick is left at the end because reinsertion is expensive

				else
					preexisting_message.end_of_life()//cant actually happen without floating point rounding
					*/

	var/maptext_used = MAPTEXT(complete_text)
	var/maptext_x_used = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5

	// these are the only three parameters that define a unique image, if any of these are different then a new entry must be made in all of them
	//TODOKYLER: check what happens if a hit is returned for these parameters but 1 client sees a different previous message that has to be animated separately
	//from the image another client sees
	var/list/preexisting_images = images_by_maptext[maptext_used] & images_by_maptext_x["[maptext_x_used]"] & images_by_mheight["[mheight]"]

	if(length(preexisting_images))
		//there should only be one remaining image by this point but it doesnt really matter
		var/image/existing_image = preexisting_images[1]
		handle_new_image_association(existing_image, owned_by, our_approx_lines, FALSE)
		return

	var/image/message = create_new_image(target, maptext_used, mheight, maptext_x_used)

	handle_new_image_association(message, owned_by, our_approx_lines, new_image = TRUE)

	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)

/datum/chatmessage/proc/create_new_image(atom/target, maptext, mheight, maptext_x)
	var/static/mutable_appearance/runechat_template/template = new()
	template.layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx
	template.maptext_width = CHAT_MESSAGE_WIDTH
	template.maptext_height = mheight
	template.pixel_y = target.maptext_height
	template.pixel_x = (target.maptext_width * 0.5) - 16
	template.maptext_x = maptext_x
	template.maptext = maptext

	// Build message image
	var/image/message = image(loc = message_loc)
	message.appearance = template

	return message


/datum/chatmessage/proc/handle_new_image_association(image/message_image, client/associated_client, approximate_lines, new_image = TRUE)
	associated_client.images |= message_image

	if(new_image)//branch new image that isnt reused
		LAZYADDASSOCLIST(images_by_maptext, message_image.maptext, message_image)
		LAZYADDASSOCLIST(images_by_maptext_x, "[message_image.maptext_x]", message_image)
		LAZYADDASSOCLIST(images_by_mheight, "[message_image.maptext_height]", message_image)
		approx_lines[message_image] = approximate_lines

	LAZYADDASSOCLIST(associated_client.seen_messages, message_loc, src)
	LAZYADDASSOCLIST(messages, message_image, associated_client)
	LAZYADDASSOC(hearers, associated_client, message_image)


///unsets any links between the client and old_image for this chat message.
///if temporary = TRUE, then we assume that this message is doing something else with the client and thus dont remove them from everything
/datum/chatmessage/proc/unassociate_client_from_image(image/old_image, client/client_hearer, temporary = FALSE)

	var/list/clients_seeing_image = messages[old_image]
	clients_seeing_image.images -= client_hearer
	hearers -= client_hearer

	if(!length(clients_seeing_image))//no other client sees this image, so remove the image from everything
		messages -= old_image

		var/maptext = "[old_image.maptext]"
		var/maptext_x = "[old_image.maptext_x]"
		var/mheight = "[old_image.maptext_height]"

		images_by_maptext[maptext] -= old_image
		if(!length(images_by_maptext[maptext]))
			images_by_maptext -= maptext

		images_by_maptext_x[maptext_x] -= old_image
		if(!length(images_by_maptext_x[maptext_x]))
			images_by_maptext_x -= maptext_x

		images_by_mheight[mheight] -= old_image
		if(!length(images_by_mheight[mheight]))
			images_by_mheight -= mheight

		approx_lines -= old_image

	if(temporary)
		return TRUE

	UnregisterSignal(client_hearer, COMSIG_PARENT_QDELETING)
	LAZYREMOVEASSOC(client_hearer.seen_messages, message_loc, src)

	return TRUE



//override_is_fading = list(hearer = is_fading)
//fadertimers_by_hearer = list(hearer = timer_hash)

/**
 * called on an already existing message when a client sees both the old message and a new message from the same target.
 * handles a few things for the old images. animates the old image upwards for the apostate, as well as adjusting the time it has until it starts fading
 * since it animates the old images upwards it has to clone the image for other clients and correctly change client-image associations
 * because otherwise clients 1 and 2 can see image A and then see different images B and C from a new message, which changes how much each client sees
 * the old message A being moved up by. thus A has to be split into two otherwise identical images.
 * Because of network delay from querying clients directly, we have to assume that even identical y_transform's on a shared image require a clone.
 *
 * Arguments:
 * * existing_image - the old image that gets cloned for apostate and effects applied to it
 * * apostate - the client associated with existing_image already
 * * y_transform - how much to move the new cloned image upwards in the animation.
 */
/datum/chatmessage/proc/handle_canon_partition(image/existing_image, client/apostate, y_transform)
	var/image/clone = new(loc = existing_image.loc)
	clone.appearance = existing_image.appearance
	unassociate_client_from_image(existing_image, apostate, temporary = TRUE)
	handle_new_image_association(clone, apostate)


/datum/chatmessage/proc/split_canon_event(client/canon_splitter, new_time_remaining)
	if(new_time_remaining <= 0)
		split_canon_eol(canon_splitter)
		return





/datum/chatmessage/proc/split_canon_eol(client/canon_splitter)

/datum/chatmessage/proc/schedule_split_canon_del(client/canon_splitter)


#define BENCHMARK_LOOP while(world.timeofday < end_time)
#define BENCHMARK_RESET iterations = 0; end_time = world.timeofday + duration
#define BENCHMARK_MESSAGE(message) message_admins("[message] got [iterations] iterations in [seconds] seconds!"); BENCHMARK_RESET

/world
	loop_checks = FALSE

/mob/proc/benchmark_chat(seconds = 5, hearers = 40)
	var/iterations = 0
	var/duration = seconds SECONDS
	var/end_time = world.timeofday + duration

	var/list/hearers_list = list()
	var/list/hearers_in_view = list()
	var/list/turfs_in_view = list()
	for(var/turf/viewed_turf in view(6))
		turfs_in_view += viewed_turf

	for(var/i in 1 to hearers)
		hearers_list += new/mob/living/hearer()

	for(var/num_hearers in 0 to hearers step 5)
		for(var/mob/living/hearer as anything in hearers_list)
			hearer.abstract_move(null)

		if(num_hearers)
			for(var/viewed_hearers in 1 to num_hearers)
				var/mob/living/hearer/hearer = hearers_list[viewed_hearers]
				hearer.abstract_move(pick(turfs_in_view))

		hearers_in_view = get_hearers_in_view(6, src)

		BENCHMARK_RESET
		BENCHMARK_LOOP
			create_chat_message(src, hearers_in_view, /datum/language/common, "blearg", list(), NONE)
			iterations++

		BENCHMARK_MESSAGE("creating a chat message the new way with [num_hearers + 1] mobs hearing the same message from one source")

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
	if(SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(speaker, TRAIT_BYPASS_MEASURES))
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

	var/atom/message_speaker = isturf(speaker) ? speaker : get_atom_on_turf(speaker)
	var/datum/chatmessage/message_to_use
	var/text_to_use

	if(runechat_flags & EMOTE_MESSAGE)
		text_to_use = raw_message
		spans = list("emote", "italics")
	else
		text_to_use = lang_treat(speaker, message_language, raw_message, spans, null, TRUE)
		spans = spans ? spans.Copy() : list()

	var/datum/chatmessage/message_to_use = SSrunechat.messages_by_creation_string["[text_to_use]-[REF(speaker)]-[message_language]-[list2params(spans)]-[CHAT_MESSAGE_LIFESPAN]-[world.time]"]
	//if an already existing message already has processed us as a hearer then we have to assume that this is from a new, identical message sent in the same tick
	//as the already existing one. thats the only time this can happen. if this is the case then null out message_to_use and create a new one
	if(message_to_use && (src in message_to_use.hearers))
		message_to_use = null

	if(!message_to_use)//no existing message that does what we need was found, create a new one
		if(runechat_flags & EMOTE_MESSAGE)//what happens if theres two messages from a speaker?
			message_to_use = new /datum/chatmessage(text_to_use, speaker, message_language, list("emote", "italics"))
		else
			message_to_use = new /datum/chatmessage(text_to_use, speaker, message_language, spans)

	message_to_use.generate_image(text_to_use, speaker, src, message_language, spans)


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

#undef CHAT_MESSAGE_SPAWN_TIME
#undef CHAT_MESSAGE_LIFESPAN
#undef CHAT_MESSAGE_EOL_FADE
#undef CHAT_MESSAGE_EXP_DECAY
#undef CHAT_MESSAGE_HEIGHT_DECAY
#undef CHAT_MESSAGE_APPROX_LHEIGHT
#undef CHAT_MESSAGE_WIDTH
#undef CHAT_LAYER_Z_STEP
#undef CHAT_LAYER_MAX_Z
#undef CHAT_MESSAGE_ICON_SIZE
