
#ifdef TESTING
ADMIN_VERB(missing_sprites, "Debug Worn Item Sprites", "We're cancelling the Spritemageddon. (This will create a LOT of runtimes! Don't run on live!)", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/actual_file_name
	for(var/test_obj in subtypesof(/obj/item))
		var/obj/item/sprite = new test_obj
		if(!sprite.slot_flags || (sprite.item_flags & ABSTRACT))
			continue
		//Is there an explicit worn_icon to pick against the worn_icon_state? Easy street expected behavior.
		if(sprite.worn_icon)
			if(!(sprite.icon_state in icon_states(sprite.worn_icon)))
				to_chat(user, span_warning("ERROR sprites for [sprite.type]. Slot Flags are [sprite.slot_flags]."), confidential = TRUE)
		else if(sprite.worn_icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
		else if(sprite.icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Mask slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Neck slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Back slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Head slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Belt slot."), confidential = TRUE)
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(user, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."), confidential = TRUE)
#endif
