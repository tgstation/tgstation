/obj/item/lead_pipe
	drop_sound = 'massmeta/sounds/sfx/metalpipefallingsound.ogg'
	hitsound = 'massmeta/sounds/sfx/metalpipefallingsound.ogg'
/obj/item/lead_pipe/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is crushed under the pressure of a thousand pipes!"))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, gib), null, null, TRUE, TRUE), 15)
	for(var/i=0, i<10, i++)
		playsound(user, 'massmeta/sounds/sfx/metalpipefallingsound.ogg', 50, TRUE)
		user.AddElement(/datum/element/squish, 1.5 SECONDS)
		sleep(1.5/10 SECONDS)
	return MANUAL_SUICIDE
