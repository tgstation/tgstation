/obj/item/taster
	name = "taster"
	desc = "Tastes things, so you don't have to!"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "tongue"

	w_class = WEIGHT_CLASS_TINY

	var/taste_sensitivity = 15

/obj/item/taster/afterattack(atom/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	if(!O.reagents)
		to_chat(user, span_notice("[src] cannot taste [O], since [O.p_they()] [O.p_have()] have no reagents."))
	else if(O.reagents.total_volume == 0)
		to_chat(user, "<span class='notice'>[src] cannot taste [O], since [O.p_they()] [O.p_are()] empty.</span>")
	else
		var/message = O.reagents.generate_taste_message(user, taste_sensitivity)
		to_chat(user, "<span class='notice'>[src] tastes <span class='italics'>[message]</span> in [O].</span>")
