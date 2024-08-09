/obj/item/book/granter/martial/tribal_claw
	martial = /datum/martial_art/tribal_claw
	name = "old scroll"
	martial_name = "tribal claw"
	desc = "A scroll filled with ancient draconic markings."
	greet = span_sciradio("You have learned the ancient martial art of the Tribal Claw! You are now able to use your tail and claws in a fight much better than before. \
	Check the combos you are now able to perform using the Recall Teachings verb in the Tribal Claw tab")
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("I must prove myself worthy to the masters of the Knoises clan...",
		"Use your tail to surprise any enemy...",
		"Your sharp claws can disorient them...",
		"I don't think this would combine with other martial arts...",
		"Ooga Booga..."
	)

/obj/item/book/granter/martial/tribal_claw/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/tribal_claw/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

/obj/item/book/granter/martial/tribal_claw/can_learn(mob/user)
	if(!islizard(user))
		to_chat(user, span_warning("You try to read the scroll but can't comprehend any of it."))
		return FALSE
	else
		return TRUE

