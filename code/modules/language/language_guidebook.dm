/obj/item/language_guidebook
	name = "language guide"
	desc = "Scared of other people knowing words you don't? Turn the tables by reading this!"
	var/exhausted_desc = "What gives? It's blank!"
	icon = 'icons/obj/library.dmi'
	icon_state = "book6"
	var/charges = 1

/obj/item/language_guidebook/attack_self(mob/living/user)
	if(!isliving(user))
		return
	
	if(use_charge(user))
		user.add_learn_language()
		to_chat(user, "<span class='notice'>Looking through [src], your head feels empty and ready for a new language.\nCheck your language menu.</span>")

/obj/item/language_guidebook/proc/use_charge(mob/user)
	if(charges<1)
		return FALSE
	
	charges--
	if(charges<=0)
		desc = exhausted_desc
	
	return TRUE