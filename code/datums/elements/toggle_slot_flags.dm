/datum/element/toggle_suit_flags
	var/changed_target //what suit flag it will turn into

/datum/element/toggle_suit_flags/Attach(datum/target, changed_target = ITEM_SLOT_NECK)
	src.changed_target = changed_target

/datum/element/toggle_suit_flags/proc/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/char = user
		if((char.get_item_by_slot(ITEM_SLOT_NECK) == src) || (char.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src))
			to_chat(user, span_warning("You can't adjust [src] while wearing it!"))
			return
		if(!user.is_holding(src))
			to_chat(user, span_warning("You must be holding [src] in order to adjust it!"))
			return
		if(slot_flags & ITEM_SLOT_OCLOTHING)
			slot_flags = ITEM_SLOT_NECK
			set_armor(/datum/armor/none)
			user.visible_message(span_notice("[user] adjusts their [src] for ceremonial use."), span_notice("You adjust your [src] for ceremonial use."))
		else
			slot_flags = initial(slot_flags)
			set_armor(initial(armor_type))
			user.visible_message(span_notice("[user] adjusts their [src] for defensive use."), span_notice("You adjust your [src] for defensive use."))
