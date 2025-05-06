/obj/item/book/granter/martial/breacherknuckle
	martial = /datum/martial_art/breacher_knuckle
	name = "salty scroll"
	martial_name = "breacher_knuckle"
	desc = "smells like debug."
	greet = span_sciradio("kung fu fuck you.")
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "sleepingcarp"
	worn_icon_state = "scroll"
	remarks = list(
		"Wait, a high protein diet is really all it takes to become stabproof...?",
		"Overwhelming force, immovable object...",
		"Focus... And you'll be able to incapacitate any foe in seconds...",
		"I must pierce armor for maximum damage...",
		"I don't think this would combine with other martial arts...",
		"Become one with the carp...",
		"Glub...",
	)

/obj/item/book/granter/martial/breacherknuckle/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/breacherknuckle/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
