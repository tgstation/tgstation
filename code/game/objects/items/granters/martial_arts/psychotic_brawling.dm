/obj/item/book/granter/martial/psychotic_brawling
	martial = /datum/martial_art/psychotic_brawling
	name = "blood-stained paper"
	martial_name = "psychotic brawling"
	desc = "A piece of blood-stained paper that emanates pure rage. Just holding it makes you want to punch someone."
	greet = "<span class='boldannounce'>You have learned the tried and true art of Psychotic Brawling. \
		You will be unable to disarm or grab, but your punches have a chance to do serious damage.</span>"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper_talisman"
	remarks = list(
		"Just keep punching...",
		"Let go of your inhibitions...",
		"Methamphetamine...",
		"Embrace Space Florida...",
		"Become too angry to die..."
	)

/obj/item/book/granter/martial/psychotic_brawling/on_reading_finished(mob/living/carbon/user)
	. = ..()
	if(!uses)
		to_chat(user, span_notice("All of the blood on the paper seems to have vanished."))
		user.dropItemToGround(src)
		qdel(src)
		user.put_in_hands(new /obj/item/paper)
