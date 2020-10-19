/obj/item/radio/headset
	var/radiosound = 'modular_skyrat/modules/radiosound/sound/radio/common.ogg'

/obj/item/radio/headset/syndicate //disguised to look like a normal headset for stealth ops
	radiosound = 'modular_skyrat/modules/radiosound/sound/radio/syndie.ogg'

/obj/item/radio/headset/headset_sec
	radiosound = 'modular_skyrat/modules/radiosound/sound/radio/security.ogg'

/obj/item/radio/headset/talk_into(mob/living/M, message, channel, list/spans, datum/language/language, list/message_mods, direct = TRUE)
	if(!listening)
		return ITALICS | REDUCE_RANGE
	if(radiosound)
		playsound(M, radiosound, rand(20, 30), 0, 0, 0)
	. = ..()
