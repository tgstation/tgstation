
/obj/item/monkey_paw
	name = "monkey paw"
	desc = "A severed primate arm, which is already gross on its own, this one has an aura of both dread and wonder to it..."
	icon = 'icons/mob/species/monkey/monkey_paw.dmi'
	icon_state = "monkey_paw"
	/// whether the paw has been used 
	var/used = FALSE

/obj/item/monkey_paw/examine(mob/user)
	. = ..()
	. += span_notice("You can use it to wish for what you want.")
	. += span_warning("But be warned, your wish might be turned against you...")

/obj/item/monkey_paw/attack_self(mob/user, modifiers)
	. = ..()
	if(!user.client)
		return
	var/monkey_wish = tgui_input_text(user, "What do you wish?", "Monkey Paw")
	if(!monkey_wish || used)
		return
	GLOB.requests.monkey_paw_wish(user.client, monkey_wish)
