/obj/item/book/granter/action/wirecrawl
	name = "modified yellow slime extract"
	desc = "An experimental yellow slime extract that when absorbed by an Ethereal, grants control over electrical powers."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "myellow"
	granted_action = /datum/action/cooldown/spell/jaunt/wirecrawl
	action_name = "Wirecrawling"
	drop_sound = null
	pickup_sound = null
	remarks = list(
		"Shock...",
		"Zap...",
		"High Voltage...",
		"Dissolve...",
		"Dissipate...",
		"Disperse...",
		"Red Hot...",
		"Spiral...",
		"Electro-magnetic...",
		"Turbo...")
	book_sounds = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg')
	var/admin = FALSE

/obj/item/book/granter/action/wirecrawl/on_reading_start(mob/user)
	to_chat(user, span_notice("You hold \the [src] directly to your chest..."))
	return TRUE

/obj/item/book/granter/action/wirecrawl/can_learn(mob/user)
	if(isethereal(user) || admin)
		return ..()
	to_chat(user, span_warning("Yup, that's a slime extract alright."))
	return FALSE

/obj/item/book/granter/action/wirecrawl/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		qdel(src)

/obj/item/book/granter/action/wirecrawl/admin //if someone wants to spawn it in
	admin = TRUE