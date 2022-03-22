/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME 0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN 5 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE 0.7 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY 0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY 0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT 11
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH 96
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH 110
/// The dimensions of the chat message icons
#define CHAT_MESSAGE_ICON_SIZE 9

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP

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
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/prev
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Contains ID of assigned timer for end_of_life fading event
	var/fadertimer = null
	/// States if end_of_life is being executed
	var/isFading = FALSE

	var/list/images_by_maptext = list()

	var/list/images_by_mheight = list()

	var/list/images_by_maptext_x = list()
	///concatenated string of parameters given to us at creation
	var/creation_parameters = ""

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
	var/duration = lifespan - CHAT_MESSAGE_EOL_FADE
	fadertimer = addtimer(CALLBACK(src, .proc/end_of_life), duration, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)

	LAZYADDASSOCLIST(SSrunechat.messages_by_speaker, message_loc, src)

/datum/chatmessage/Destroy()

	for(var/client/hearer in hearers)
		LAZYREMOVEASSOC(hearer.seen_messages, message_loc, src)

		if(istype(hearers[hearer], /image))
			hearer.images -= hearers[hearer]

	//acts like LAZYREMOVEASSOC() except it doesnt null the messages_by_speaker list
	SSrunechat.messages_by_speaker[message_loc] -= src
	if(!length(SSrunechat.messages_by_speaker[message_loc]))
		SSrunechat.messages_by_speaker -= message_loc

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
	isFading = TRUE
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

//preset /mutable_appearance subtype just to prefill some constant runechat image vars
/mutable_appearance/runechat_template
	plane = RUNECHAT_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	alpha = 0
	maptext_width = CHAT_MESSAGE_WIDTH

/**
 *
 */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, datum/language/language, list/extra_classes, repeated_owner = FALSE)
	set waitfor = FALSE //because this waits on client input
	/// Cached icons to show what language the user is speaking
	var/static/list/language_icons

	// Register client who hears this message
	var/client/owned_by = owner.client
	if(!repeated_owner)
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
		//var/idx = 1
		//var/combined_height = our_approx_lines

		for(var/datum/chatmessage/preexisting_message as anything in owned_by.seen_messages[message_loc])

			var/image/other_message_image = preexisting_message.hearers[owned_by]
			animate(other_message_image, pixel_y = other_message_image.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			/*combined_height += preexisting_message.approx_lines[other_message_image]

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL has been executed.
			if (!preexisting_message.isFading)
				var/sched_remaining = timeleft(preexisting_message.fadertimer, SSrunechat)
				var/remaining_time = (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height)
				if (round(DS2TICKS(remaining_time))//check if more than one tick is left at the end because reinsertion is expensive
					deltimer(preexisting_message.fadertimer, SSrunechat)
					preexisting_message.fadertimer = addtimer(CALLBACK(preexisting_message, .proc/end_of_life), remaining_time, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)
				else
					preexisting_message.end_of_life()//cant actually happen without floating point rounding
			*/ //TODOKYLER: dont thing about this yet it complicates things a lot

	var/maptext_used = MAPTEXT(complete_text)
	var/maptext_x_used = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5

	// these are the only three parameters that define a unique image, if any of these are different then a new entry must be made in all of them
	var/list/preexisting_images = images_by_maptext[maptext_used] & images_by_maptext_x["[maptext_x_used]"] & images_by_mheight["[mheight]"]

	if(preexisting_images)
		//there should only be one remaining image by this point but it doesnt really matter
		var/image/existing_image = preexisting_images[1]
		owned_by.images |= existing_image
		LAZYADDASSOCLIST(owned_by.seen_messages, message_loc, src)
		return

	var/static/mutable_appearance/runechat_template/template = new()
	template.layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx
	template.maptext_width = CHAT_MESSAGE_WIDTH
	template.maptext_height = mheight
	template.pixel_y = target.maptext_height
	template.pixel_x = (target.maptext_width * 0.5) - 16
	template.maptext_x = maptext_x_used
	template.maptext = maptext_used

	// Build message image
	var/image/message = image(loc = message_loc)
	message.appearance = template

	LAZYADDASSOCLIST(images_by_maptext, maptext_used, message)
	LAZYADDASSOCLIST(images_by_maptext_x, "[maptext_x_used]", message)
	LAZYADDASSOCLIST(images_by_mheight, "[mheight]", message)

	LAZYADDASSOCLIST(messages, message, owned_by)
	LAZYADDASSOC(hearers, owned_by, message)
	approx_lines[message] = our_approx_lines

	// View the message
	LAZYADDASSOCLIST(owned_by.seen_messages, message_loc, src)
	owned_by.images |= message
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)

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

	for(var/datum/chatmessage/existing_message in SSrunechat.messages_by_speaker[message_speaker])
		if(existing_message.creation_parameters == "[text_to_use]-[REF(speaker)]-[message_language]-[list2params(spans)]-[CHAT_MESSAGE_LIFESPAN]-[world.time]")
			message_to_use = existing_message
			break

	if(!message_to_use)
		if(runechat_flags & EMOTE_MESSAGE)//what happens if theres two messages from a speaker?
			message_to_use = new /datum/chatmessage(text_to_use, speaker, message_language, list("emote", "italics"))
		else
			message_to_use = new /datum/chatmessage(text_to_use, speaker, message_language, spans)

	message_to_use.generate_image(text_to_use, speaker, src, message_language, spans, repeated_owner = TRUE)


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
