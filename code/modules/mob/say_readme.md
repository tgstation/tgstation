# Say code basics

This document is a little dated but I believe it's accurate mostly (oranges 2019)

# MIAUW'S SAY REWRITE

This is a basic explanation of how say() works. Read this if you don't understand something.

The basic "flow" of say() is that a speaker says a message, which is heard by hearers. What appears on screen
is constructed by each hearer separately, and not by the speaker.

This rewrite was needed, but is far from perfect. Report any bugs you come across and feel free to fix things up.
Radio code, while very much related to saycode, is not something I wanted to touch, so the code related to that may be messy.

If you came here to see how to use saycode, all you will ever really need to call is say(message).
To have things react when other things speak around them, add the HEAR_1 flag to their flags variable and
override their Hear() proc.

# PROCS & VARIABLES

Here follows a list of say()-related procs and variables.

```
global procs
	get_radio_span(freq)
		Returns the span class associated with that frequency.

	get_radio_name(freq)
		Returns the name of that frequency.

	get_hearers_in_view(R, atom/source)
		Self-explanatory. Calls get_hear() and then calls recursive_hear_check on everything that get_hear() returns.

	recursive_hear_check(atom/O)
		Checks for hearers by looping through the contents of O and the contents of the contents of O and etc and checking
		each object for the HEAR_1 flag. Returns a list of objects with the HEAR_1 flag.

	get_hear(range, atom/source)
		Like view(), but ignores luminosity.

	message_spans_start(spans)
		Turns each element of spans into a span class.

	attach_spans(input, spans)
		Attaches span classes around input.

/atom/movable
	flags
		The HEAR_1 flag determines whether something is a hearer or not.
		Hear() is only called on procs with this flag.

	languages
		languages live either in datum/languages_holder or in the mind.

	verb_say/verb_ask/verb_exclaim/verb_yell/verb_sing
		These determine what the verb is for their respective action. Used in generate_messagepart().

	say(message, bubble_type, var/list/spans, sanitize, datum/language/language, ignore_spam, forced)
		Say() is the "mother-proc". It calls all the other procs required for speaking, but does little itself.
		At the atom/movable level, say() just calls send_speech.

	try_speak()
		Checks that our atom can speak the passed messages.
		Includes feedback to the speaker if they cannot speak.

	can_speak()
		Checks that our atom can vocally speak at all.
		Does not (and should not) include any feedback on its own.

	Hear(atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mods, message_range)
		This proc handles hearing. What it does varies. For mobs, it treats the message with hearer-specific things
		like language and deafness, then outputs it to the hearer.

		IMPORTANT NOTE: If radio_freq is not null, the code will assume that the speaker is virtual! (more info on this in the Radios section below)

	send_speech(message, range, source, bubble_type, spans, list/message_mods)
		This proc composes a list of hearers (things with the HEAR_1 flag + dead people) and calls Hear() on them.
		Message treatment or composition of output are not done by this proc, these are handled by the rest of
		say() and the hearer respectively.

	translate_language(message, atom/movable/speaker, message_langs, raw_message)
		Modifies the message by comparing the languages of the speaker with the languages of the hearer.
		Called on the hearer.

	generate_messagepart(input, spans, list/message_mods)
		Either adds a lone custom say verb, or a verb and quotes to a message. Also attaches span classes to a message.
		Verbs are determined by verb_say/verb_ask/verb_yell/verb_sing variables. Called on the speaker.

/mob
	say_dead(message)
		Sends a message to all dead people. Does not use Hear().

	compose_message(message, atom/movable/speaker, message_langs, raw_message, radio_freq, freq_name, freq_color, spans, list/message_mods)
		Composes the message mobs see on their screen when they hear something.

	compose_track_href(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		Composes the href tags used by the AI for tracking. Returns "" for all mobs except AIs.

	compose_job(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
		Composes the job and the end tag for tracking hrefs. Returns "" for all mobs except AIs.

	hivecheck()
		Returns TRUE if the mob can hear and talk in the alien hivemind.

/mob/living
	say(message, bubble_type, var/list/spans, sanitize, datum/language/languag, ignore_spam, forced)
		The say() of mob_living is significantly more complex than that of objects.
		Most of the extra code has to do with radios and message treatment.

	send_speech(message, range, source, bubble_type, spans, list/message_mods)
		mob/living's send_speech allows mobs one tile outside of the defined range to still hear the message,
		but starred with the stars() proc.

	check_emote(message)
		Checks if the message begins with an * and is thus an emote.

	get_message_mods(message, list/message_mods)
		Checks the start of the message for each of the components it could contain, stores that info in mods, and returns a trimmed list

	treat_message(message)
		What it says on the tin. Treats the message according to flags set on the mob.
		Also handles captilization of the message

	radio(message, list/message_mods = list(), spans)
		Handles talking into radios. Uses a switch to determine what radio to speak into and in which manner to do so.

		Return is a bitflag.
		NOPASS = terminate say()
		ITALICS = add italics to the message
		REDUCE_RANGE = reduce the message range to one tile.

		Return 0 if no radio was spoken into.
		IMPORTANT: remember to call ..() and check for ..()'s return value properly!

/datum/saymode
	This is made to handle things like admin or alien chat.
	Features that look like radio, but aren't quite

	key
		The key used to talk on this channel, in combination with : or .
	mode
		The UID we use for this channel

	handle_message(message, list/message_mods, datum/language/language)
		Intercepts say() after it's done all of it's message building.
		If this returns true we stop say(), if it returns false we keep going
```

# RADIOS

I did not want to interfere with radios too much, but I sort of had to.
For future generations, here is how radio code works:
First, talk_into() is called on a radio. This sends a signal datum into the magic machine that is tcomms, which
eventually results in broadcast_message() being called.

Broadcast_message() does NOT call say() on radios, but rather calls Hear() on everyone in range of a radio.
This is because the system does not like repeating says.

Furthermore, I changed radios to not be in the SSradio. Instead, they are in a global list called all_radios.
This is an associative list, and the numbers as strings are the keys. The values are lists of radios that can hear said frequency.

To add a radio, simply use add_radio(radio, frequency). To remove a radio, use remove_radio(radio, frequency).
To remove a radio from ALL frequencies, use remove_radio_all(radio).

## VIRTUAL SPEAKERS:

Virtual speakers are simply atom/movables with a few extra variables.
If radio_freq is not null, the code will rely on the fact that the speaker is virtual. This means that several procs will return something:

```
	(all of these procs are defined at the atom/movable level and return "" at that level.)
	GetJob()
		Returns the job string variable of the virtual speaker.
	GetTrack()
		Returns wether the tracking href should be fake or not.
	GetSource()
		Returns the source of the virtual speaker.
	GetRadio()
		Returns the radio that was spoken through by the source. Needed for AI tracking.
```

This is fairly hacky, but it means that I can advoid using istypes. It's mainly relevant for AI tracking and AI job display.

That's all, folks!
