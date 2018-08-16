// Modular stuff to use with Citadel-specific moods.

// box of hugs
/obj/item/storage/box/hug/attack_self(mob/user)
	. = ..()
	GET_COMPONENT_FROM(mood, /datum/component/mood, user)
	if(mood)
		mood.add_event("hugbox", /datum/mood_event/hugbox)

// headpats (IMPORTANT)
/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	. = ..()
	GET_COMPONENT_FROM(mood, /datum/component/mood, src)
	if(mood)
		mood.add_event("headpat", /datum/mood_event/headpat)

// plush petting
/obj/item/toy/plush/attack_self(mob/user)
	. = ..()
	if(stuffed || grenade)
		GET_COMPONENT_FROM(mood, /datum/component/mood, user)
		if(mood)
			mood.add_event("plushpet", /datum/mood_event/plushpet)
	else
		GET_COMPONENT_FROM(mood, /datum/component/mood, user)
		if(mood)
			mood.add_event("plush_nostuffing", /datum/mood_event/plush_nostuffing)

// Jack the Ripper starring plush
/obj/item/toy/plush/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(I.is_sharp())
		if(!grenade)
			GET_COMPONENT_FROM(mood, /datum/component/mood, user)
			if(mood)
				mood.add_event("plushjack", /datum/mood_event/plushjack)

// plush playing (plush-on-plush action)
	if(istype(I, /obj/item/toy/plush))
		GET_COMPONENT_FROM(mood, /datum/component/mood, user)
		if(mood)
			mood.add_event("plushplay", /datum/mood_event/plushplay)
