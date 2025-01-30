/mob/verb/irc_verb(message as message)
	set name = "IRC"
	set category = "IC"
	set instant = TRUE

	if(GLOB.say_disabled)
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(message)
		QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(src, TYPE_VERB_REF(/mob/living, irc_actual_verb), message), SSspeech_controller)

/mob/living/verb/irc_actual_verb(message as message)
	var/obj/item/modular_computer/our_computer = irc_checks(message) // yeah our check returns a modular computer object, so what, HUH???
	if (!message || !our_computer)
		return

	if (!try_speak(message)) // ensure we pass the vibe check (filters, etc)
		return

	// we now have a modular computer and checks have promised us that it is a viable one, so use it
	//get the program reference from stored files
	var/datum/computer_file/program/chatclient/chat = locate() in our_computer.stored_files
	// let's just flub a UI_act, janky but keeps it all contained (this probably will not work)
	// really jank and we probably shouldn't do this (somehow it works)
	chat.ui_act("PRG_speak", list("message" = message), null, null)
