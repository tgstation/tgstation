/**
  * A solution to any amount of arguments passed into [/atom/movable/proc/Hear], and alike.
  *
  * This class should be used as a builder of sorts that is passed in all hearing-speaking related procs.
  * This class expects "message" argument to be pre-sanitized.
  */
/datum/spoken_info
	// What has sent us this message. Please set via [/datum/spoken_info/proc/setSource].
	var/atom/movable/source
	// Who is currently perceiving this info. Please set via [/datum/spoken_info/proc/setHearer].
	var/atom/movable/hearer

	// The range in which this message can be heard. Please set via [/datum/spoken_info/proc/setRawMessage].
	var/message_range

	// Not actually(assumingly) raw, a sanitized string of what was spoken.
	var/raw_message

	// In what was is the message conveyed.
	var/message_mode

	// The language in which this message was spoken. Please set via [/datum/spoken_info/proc/setLanguage].
	var/datum/language/message_language

	// What radio freq the message was sent on, if any. Please set via [/datum/spoken_info/proc/setRadioFreq].
	var/radio_freq

	// What spans should apply to this message.
	var/list/spans

	// The type of bubble to display above source. Please set via [/datum/spoken_info/proc/setBubbleType].
	var/bubble_type

	/*
		All of the vars below are used in text rendering, and are saved for efficency.
	*/
	// Basic span
	var/spanpart1 = "<span class='game say'>"
	// Radio freq/name display
	var/freqpart
	//Speaker name
	var/namepart

	// How does a creature that *understands* the message perceive it.
	var/comprehended_message
	// How does a creature that doesn't understand the message perceive it.
	var/scrambled_message

	// The icon of message spoken.
	var/languageicon = ""

	// The bubble image displayed to all of those whom it may concern.
	var/image/bubble_image

/datum/spoken_info/New(message, message_range, message_mode, buble_type, atom/movable/source = null, atom/movable/hearer = null, datum/language/language = null, freq = null, list/spans = null)
	src.message_mode = message_mode

	setRawMessage(message)

	setBubbleType(bubble_type)

	if(language)
		setLanguage(language)

	if(source)
		setSource(source)

	if(hearer)
		setHearer(hearer)

	src.message_range = message_range

	if(radio_freq)
		setRadioFreq(freq)

	src.spans = spans

/datum/spoken_info/Destroy()
	source = null
	hearer = null
	QDEL_NULL(bubble_image)
	return ..()

/**
  * This proc sets the raw message, and updates contents for "processed" messages.
  *
  */
/datum/spoken_info/proc/setRawMessage(message)
	if(raw_message == message)
		return

	raw_message = message

	updateBubble()
	updatePerception()

/**
  * This proc updates the bubble image.
  *
  */
/datum/spoken_info/proc/setBubbleType(new_bubble_type)
	if(bubble_type == new_bubble_type)
		return

	bubble_type = new_bubble_type

	updateBubble()

/**
  * This proc sets the source for src, and updates all required stuff.
  *
  */
/datum/spoken_info/proc/setSource(atom/movable/new_source)
	if(source == new_source)
		return

	source = new_source

	var/namepart = "[source.GetVoice()][source.get_alt_name()]"
	if(source.face_name && ishuman(source))
		var/mob/living/carbon/human/H = source
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised

	updateBubble()
	updatePerception()

/**
  * This proc sets the hearer for src, and updates all required stuff.
  *
  */
/datum/spoken_info/proc/setHearer(atom/movable/new_hearer)
	if(hearer == new_hearer)
		return

	hearer = new_hearer
	updateLangIcon()

/**
  * This proc sets the language of src, and updates all required stuff.
  *
  */
/datum/spoken_info/proc/setLanguage(datum/language/L)
	if(message_language == L)
		return

	message_language = L

	updatePerception()
	updateLangIcon()

/datum/spoken_info/proc/setRadioFreq(freq)
	radio_freq = freq
	freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"

/**
  * This proc updates the message's contents on change of source, or language.
  *
  */
/datum/spoken_info/proc/updatePerception()
	if(!source)
		return

	if(!message_language)
		comprehended_message = "makes a strange, yet familiar sound."
		scrambled_message = "makes a strange sound."
		return

	var/datum/language/D = GLOB.language_datum_instances[message_language]
	var/lang_mes = D.scramble(raw_message)

	var/atom/movable/virtual_source = source.GetSource()
	var/atom/movable/AM = virtual_source ? virtual_source : source

	comprehended_message = AM.say_quote(raw_message, spans, message_mode)
	scrambled_message = AM.say_quote(lang_mes, spans, message_mode)

/**
  * This proc updates language icon if new language is set, or a new hearer is set.
  *
  */
/datum/spoken_info/proc/updateLangIcon()
	if(!hearer || !message_language)
		languageicon = ""
		return

	var/datum/language/D = GLOB.language_datum_instances[message_language]
	if(istype(D) && D.display_icon(hearer))
		languageicon = "[D.get_icon()]"

/**
  * This proc updates the speech bubble if a new source, or bubble type is set.
  *
  */
/datum/spoken_info/proc/updateBubble()
	if(!source || !bubble_type || !raw_message)
		QDEL_NULL(bubble_image)
		return

	QDEL_NULL(bubble_image)

	bubble_image = image('icons/mob/talk.dmi', source, "[bubble_type][say_test(raw_message)]", FLY_LAYER)
	bubble_image.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

/**
  * The proc used to merge two instances of spoken info, if conflicts arise.
  * It intentionally ignores set-procs, as to allow for creating confusion by mingling directly with
  * spanpart1, freqpart, endpart, etc.
  *
  * The procs assumes that the instance which other instance is merged into is "dominant"
  * and all non-null fields are to be preserved, unless *forced* to not be.
  * Arguments:
  * * datum/spoken_info/new_info - the instance merged into src.
  * * force - Whether to force all of fields to be passed onto src.
  */
/datum/spoken_info/proc/merge(datum/spoken_info/new_info, force = FALSE)
	if(!source || force)
		source = new_info.source

	// isnull() is used since strings can be falsey.
	if(isnull(raw_message) || force)
		raw_message = new_info.raw_message

	// isnull() is used since 0 is falsey.
	if(isnull(message_range) || force)
		message_range = new_info.message_range

	if(isnull(message_mode) || force)
		message_mode = new_info.message_mode

	if(!message_language || force)
		message_language = new_info.message_language

	if(isnull(radio_freq) || force)
		radio_freq = new_info.radio_freq

	if(!spans || force)
		spans = new_info.spans

	if(isnull(spanpart1) || force)
		spanpart1 = new_info.spanpart1

	if(isnull(freqpart) || force)
		freqpart = new_info.freqpart

	if(isnull(namepart) || force)
		namepart = new_info.namepart

	if(isnull(comprehended_message) || force)
		comprehended_message = new_info.comprehended_message

	if(isnull(scrambled_message) || force)
		scrambled_message = new_info.scrambled_message

	if(!languageicon || force)
		languageicon = new_info.languageicon

	if(!bubble_image || force)
		setBubbleType(new_info.bubble_type)

/**
  * This proc creates a copy of current spoken_info instance *correctly*.
  *
  */
/datum/spoken_info/proc/getCopy()
	var/datum/spoken_info/C = new
	C.merge(src, TRUE)
	return C

/**
  * This proc gets rendered message for current set of source-hearer, and all other related vars.
  *
  */
/datum/spoken_info/proc/getMsg()
	if(!hearer)
		return "But if there was none to perceive it, was the message even really there?"

	//Start name span
	var/spanpart2 = "<span class='name'>"
	//End name span.
	var/endspanpart = "</span>"

	var/messagepart = hearer.has_language(message_language) ? comprehended_message : scrambled_message

	return "[spanpart1][spanpart2][freqpart][languageicon][hearer.compose_track_href(source, namepart)][namepart][hearer.compose_job(source, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/**
  * This proc shows hearer the bubble they ought to perceive.
  *
  */
/datum/spoken_info/proc/showBubble()
	return
