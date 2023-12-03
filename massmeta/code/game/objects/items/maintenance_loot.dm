/obj/item/lead_pipe/Initialize(mapload)
	. = ..()
	var/sound_file = 'massmeta/sounds/sfx/metalpipefallingsound.ogg'
	var/list/sound_list = list()
	sound_list[sound_file] = 1
	AddComponent(/datum/component/squeak, sound_list, 100, 5, falloff_exponent = 20)

/obj/item/lead_pipe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is crushed under the weight of a thousand pipes!"))
	for(var/i in 1 to 8)
		playsound(user, 'massmeta/sounds/sfx/metalpipefallingsound.ogg', 50, FALSE)
		user.AddElement(/datum/element/squish, 1.5 SECONDS)
		sleep(1.5/8 SECONDS)
	user.gib()
	return MANUAL_SUICIDE
