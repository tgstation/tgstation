/datum/emote/silicon
	mob_type_allowed_typecache = list(/mob/living/silicon)
	emote_type = EMOTE_AUDIBLE

/datum/emote/sound/silicon
	mob_type_allowed_typecache = list(/mob/living/silicon)
	emote_type = EMOTE_AUDIBLE

/datum/emote/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."
	message_param = "boops %t."

/datum/emote/sound/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/sound/silicon/buzz2
	key = "buzz2"
	message = "buzzes twice."
	message_param = "buzzes twice at %t"
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/sound/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	message_param = "chimes at %t"
	sound = 'sound/machines/chime.ogg'

/datum/emote/sound/silicon/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks."
	message_param = "honks at %t"
	vary = TRUE
	sound = 'sound/items/bikehorn.ogg'

/datum/emote/sound/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	sound = 'sound/machines/ping.ogg'

/datum/emote/sound/silicon/sad
	key = "sad"
	message = "plays a sad trombone..."
	sound = 'sound/misc/sadtrombone.ogg'

/datum/emote/sound/silicon/warn
	key = "warn"
	key_third_person = "warns"
	message = "blares an alarm!"
	message_param = "warns %t!"
	sound = 'sound/machines/warning-buzzer.ogg'

/datum/emote/sound/silicon/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps enthusiastically!"
	message_param = "beeps enthusiastically at %t!"
	sound = 'sound/machines/cyborg/Cyborg-emote-chipper.ogg'

/datum/emote/sound/silicon/chuckle
	key = "chuckle"
	key_third_person = "chortle"
	message = "chortles."
	message_param = "chortles at %t."
	sound = 'sound/machines/cyborg/Cyborg-emote-chuckle.ogg'

/datum/emote/sound/silicon/query
	key = "?"
	key_third_person = "what"
	message = "queries."
	message_param = "queries at %t."
	sound = 'sound/machines/cyborg/Cyborg-emote-confused.ogg'

/datum/emote/sound/silicon/okay
	key = "okay"
	key_third_person = "alright"
	message = "acknowledges."
	message_param = "acknowledges %t"
	sound = 'sound/machines/cyborg/Cyborg-emote-okay.ogg'


/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(stat == CONSCIOUS)
		if(!cell || !cell.charge)
			visible_message("The power warning light on <span class='name'>[src]</span> flashes urgently.",\
							"You announce you are operating in low power mode.")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
		else
			to_chat(src, "<span class='warning'>You can only use this emote when you're out of charge.</span>")
