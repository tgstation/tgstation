/// Lets you make monkey paw wishes, a type of praying where the admin is supposed to twist your request.
/obj/item/monkey_paw
	name = "monkey paw"
	desc = "A severed primate arm, which is already gross on its own, this one has an aura of both dread and wonder to it..."
	icon = 'icons/mob/species/monkey/monkey_paw.dmi'
	icon_state = "monkey_paw"
	/// whether the paw is being used
	var/using = FALSE
	/// makes the paw not get deleted on use
	var/infinite = FALSE

/obj/item/monkey_paw/examine(mob/user)
	. = ..()
	. += span_notice("You can use it to wish for what you want[infinite ? ", all you want" : ""].")
	. += span_warning("But be warned, your wish[infinite ? "es" : ""] might be turned against you...")

/obj/item/monkey_paw/attack_self(mob/user, modifiers)
	. = ..()
	if(!user.client)
		return
	if(using)
		return
	using = TRUE
	var/monkey_wish = tgui_input_text(user, "What do you wish?", "Monkey Paw")
	using = FALSE
	if(!monkey_wish)
		return
	GLOB.requests.monkey_paw_wish(user.client, monkey_wish)
	to_chat(user, span_warning("[src] curls, and a sinister feeling washes over you as it rapidly turns to dust in your hands."))
	if(!infinite)
		qdel(src)

/obj/item/monkey_paw/infinite
	name = "ominous monkey paw"
	infinite = TRUE
