// This code handles the strip menu minutae for re-enabling someone's deactivated entombed suit.

/datum/strippable_item/mob_item_slot/back/get_alternate_actions(atom/source, mob/user)
	. = ..()
	var/obj/item/mod/control/pre_equipped/entombed/entombed_suit = get_item(source)
	if(!istype(entombed_suit))
		return

	if(!entombed_suit.active)
		return list("entombed_emergency_reactivate")

/datum/strippable_item/mob_item_slot/back/perform_alternate_action(atom/source, mob/user, action_key)
	. = ..()
	var/obj/item/mod/control/pre_equipped/entombed/entombed_suit = get_item(source)
	if(!istype(entombed_suit))
		return null

	switch(action_key)
		if("entombed_emergency_reactivate")
			if(!entombed_suit.active)
				user.visible_message(span_info("[user] begins initiating emergency reactivation procedures on [entombed_suit]..."))
				if(do_after(user, 3 SECONDS, entombed_suit.wearer))
					// deploy all our parts so activation actually works
					for(var/obj/item/part as anything in entombed_suit.get_parts())
						entombed_suit.deploy(user, part)
					entombed_suit.toggle_activate(user, TRUE)
			else
				user.balloon_alert(usr, "their suit is already online!")
