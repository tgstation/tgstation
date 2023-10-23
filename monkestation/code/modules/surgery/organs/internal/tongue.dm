/obj/item/organ/internal/tongue/robot/clockwork
	name = "dynamic micro-phonograph"
	desc = "An old-timey looking device connected to an odd, shifting cylinder."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "tongueclock"

/obj/item/organ/internal/tongue/robot/clockwork/better
	name = "amplified dynamic micro-phonograph"

/obj/item/organ/internal/tongue/robot/clockwork/better/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT
	//speech_args[SPEECH_SPANS] |= SPAN_REALLYBIG  //i disabled this, its abnoxious and makes their chat take 3 times as much space in chat

/obj/item/organ/internal/tongue/arachnid
	name = "arachnid tongue"
	desc = "The tongue of an Arachnid. Mostly used for lying."
	say_mod = "chitters"
	modifies_speech = TRUE

/obj/item/organ/internal/tongue/arachnid/modify_speech(datum/source, list/speech_args) //This is flypeople speech
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/arachnid/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/internal/tongue/oozeling
	name = "oozeling tongue"
	desc = "A goopy organ that mimics the tongues of other carbon beings."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "tongue_oozeling"
	say_mod = "blurbles"
	alpha = 200

// Oozeling tongues can speak all default + slime
/obj/item/organ/internal/tongue/oozeling/get_possible_languages()
	return ..() + /datum/language/slime
