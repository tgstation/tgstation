// Adds a sound to blushing ( ??? )

/datum/emote/living/blush
	sound = 'modular_doppler/emotes/sound/blush.ogg'

// Snapping multiple times in a row (If you do the nova roleplayer with this I'm removing it)

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	message_param = "snaps twice at %t."
	emote_type = EMOTE_AUDIBLE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/snap2.ogg'

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	message_param = "snaps thrice at %t."
	emote_type = EMOTE_AUDIBLE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/snap3.ogg'

// Makes sniffing immune to being muffled

/datum/emote/living/sniff
	vary = TRUE
	cant_muffle = TRUE

// Insane clapping gameplay

/datum/emote/living/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps."
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE
	specific_emote_audio_cooldown = 5 SECONDS
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/clap/get_sound(mob/living/user)
	return pick('modular_doppler/emotes/sound/clap1.ogg',
				'modular_doppler/emotes/sound/clap2.ogg',
				'modular_doppler/emotes/sound/clap3.ogg',
				'modular_doppler/emotes/sound/clap4.ogg')

/datum/emote/living/clap/can_run_emote(mob/living/carbon/user, status_check = TRUE , intentional, params)
	if(user.usable_hands < 2)
		return FALSE
	return ..()

/datum/emote/living/clap1
	key = "clap1"
	key_third_person = "claps once"
	message = "claps once."
	emote_type = EMOTE_AUDIBLE
	hands_use_check = TRUE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/clap1/get_sound(mob/living/user)
	return pick('modular_doppler/emotes/sound/claponce1.ogg',
				'modular_doppler/emotes/sound/claponce2.ogg')

/datum/emote/living/clap1/can_run_emote(mob/living/carbon/user, status_check = TRUE , intentional, params)
	if(user.usable_hands < 2)
		return FALSE
	return ..()

// Tilting your head can go here, right?

/datum/emote/living/headtilt
	key = "tilt"
	key_third_person = "tilts"
	message = "tilts their head."
	message_AI = "tilts the image on their display."

// Blinking

/datum/emote/living/blink2
	key = "blink2"
	key_third_person = "blinks twice"
	message = "blinks twice."
	message_AI = "flashes their display twice."

/datum/emote/living/rblink
	key = "rblink"
	key_third_person = "rapidly blinks"
	message = "rapidly blinks!"
	message_AI = "flashes their display rapidly!"

// You suck at blinking

/datum/emote/living/squint
	key = "squint"
	key_third_person = "squints"
	message = "squints."
	message_AI = "zooms in."

// Random facial expressions

/datum/emote/living/smirk
	key = "smirk"
	key_third_person = "smirks"
	message = "smirks."

/datum/emote/living/eyeroll
	key = "eyeroll"
	key_third_person = "rolls their eyes"
	message = "rolls their eyes."

/datum/emote/living/etwitch
	key = "etwitch"
	key_third_person = "twitches their ears"
	message = "twitches their ears!"

// Random noises

/datum/emote/living/huff
	key = "huffs"
	key_third_person = "huffs"
	message = "huffs!"

/datum/emote/living/clear
	key = "clear"
	key_third_person = "clears their throat"
	message = "clears their throat."
