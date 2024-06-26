/obj/item/taster
	name = "taster"
	desc = "Tastes things, so you don't have to!"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "tongue"

	w_class = WEIGHT_CLASS_TINY

	var/taste_sensitivity = 15

/obj/item/taster/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with.reagents)
		to_chat(user, span_notice("[src] cannot taste [interacting_with], since [interacting_with.p_they()] [interacting_with.p_have()] have no reagents."))
	else if(interacting_with.reagents.total_volume == 0)
		to_chat(user, span_notice("[src] cannot taste [interacting_with], since [interacting_with.p_they()] [interacting_with.p_are()] empty."))
	else
		var/message = interacting_with.reagents.generate_taste_message(user, taste_sensitivity)
		to_chat(user, span_notice("[src] tastes <i>[message]</i> in [interacting_with]."))
	return ITEM_INTERACT_SUCCESS
