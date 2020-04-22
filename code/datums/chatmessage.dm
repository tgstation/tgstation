#define CHAT_MESSAGE_SPAWN_TIME		1  // 0.1 second
#define CHAT_MESSAGE_LIFESPAN		50 // 5 seconds
#define CHAT_MESSAGE_EOL_FADE		10 // 1 second
#define CHAT_MESSAGE_WIDTH			96 // pixels
#define CHAT_MESSAGE_MAX_LENGTH		110 // characters
#define WXH_TO_HEIGHT(x)			text2num(copytext((x), findtextEx((x), "x") + 1)) // thanks lummox

/client
	/// Messages currently seen by this client
	var/list/seen_messages = list()

/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  */
/datum/chatmessage
	/// The visual element of the chat messsage
	var/image/message
	/// The location in which the message is appearing
	var/atom/message_loc
	/// The client who heard this message
	var/client/owned_by

/**
  * Constructs a chat message overlay
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/New(text, atom/target, mob/owner, list/extra_classes = null, lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given for chatmessage")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return

	// Clip message
	if (length(text) > CHAT_MESSAGE_MAX_LENGTH)
		text = copytext(text, 1, CHAT_MESSAGE_MAX_LENGTH) + "..."

	// Approximate text height
	owned_by = owner.client
	var/complete_text = "<span class='center maptext [extra_classes != null ? extra_classes.Join(" ") : ""]'>[text]</span>"
	var/mheight = max(WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH)), 14)

	// Translate any existing messages upwards
	message_loc = target
	if (owned_by.seen_messages)
		for(var/datum/chatmessage/m in owned_by.seen_messages[message_loc])
			animate(m.message, pixel_y = m.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)

	// Build message image
	message = image(loc = message_loc)
	message.plane = ABOVE_ALL_MOB_LAYER
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	message.alpha = 0
	message.pixel_y = owner.bound_height * 0.95
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5
	message.maptext = complete_text

	// View the message
	LAZYADDASSOC(owned_by.seen_messages, message_loc, src)
	owned_by.images |= message
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)
	addtimer(CALLBACK(src, .proc/end_of_life), lifespan - CHAT_MESSAGE_EOL_FADE)
	QDEL_IN(src, lifespan)

/datum/chatmessage/Destroy()
	LAZYREMOVEASSOC(owned_by.seen_messages, message_loc, src)
	if (owned_by)
		owned_by.images -= message
	return ..()

/**
  * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion
  */
/datum/chatmessage/proc/end_of_life()
	animate(message, alpha = 0, time = CHAT_MESSAGE_EOL_FADE)
