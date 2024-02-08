/datum/species/proc/return_accessory_layer(layer, datum/sprite_accessory/added_accessory, mob/living/carbon/human/host, passed_color)
	var/list/return_list = list()
	var/layertext = mutant_bodyparts_layertext(layer)
	var/g = (host.physique == FEMALE) ? "f" : "m"

	// add overlay on "external_slots" like tail, head and other parts
	// one by one...
	for(var/list_item in added_accessory.external_slots)
		var/can_hidden_render = return_exernal_render_state(list_item, host)
		if(!can_hidden_render)
			continue // we failed the render check just dont bother (we just don't need to render it)
		if(!host.get_organ_slot(list_item))
			continue

		var/obj/item/organ/external/external_organ = host.get_organ_slot(list_item)
		var/external_sprite = external_organ.bodypart_overlay.sprite_datum.icon_state


		if(external_organ) // i made this proc to dejank this shit than I add this... the codebase has fallen - Borbop P.S Ignore whatever the hell is going on above this.
			if(istype(external_organ.bodypart_overlay, /datum/bodypart_overlay/mutant/tail))
				var/datum/bodypart_overlay/mutant/tail/tail = external_organ.bodypart_overlay
				if(tail.wagging)
					list_item = "[list_item]_wagging"

		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[external_sprite]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[external_sprite]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay
		//if(added_accessory.is_emissive)
			//return_list += emissive_appearance_copy(new_overlay, host)

	// add overlay on body only
	for(var/list_item in added_accessory.body_slots)
		if(!host.get_bodypart(list_item))
			continue
		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay
		//if(added_accessory.is_emissive)
			//return_list += emissive_appearance_copy(new_overlay, host)

	return return_list


// check for covered parts by something
/proc/return_exernal_render_state(external_slot, mob/living/carbon/human/human)
	switch(external_slot)
		if(ORGAN_SLOT_EXTERNAL_TAIL)
			if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
				return FALSE
			return TRUE
		if(ORGAN_SLOT_EXTERNAL_SNOUT)
			if(!(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
				return TRUE
			return FALSE
		if(ORGAN_SLOT_EXTERNAL_FRILLS)
			if(!(human.head?.flags_inv & HIDEEARS))
				return TRUE
			return FALSE
		if(ORGAN_SLOT_EXTERNAL_SPINES)
			return TRUE //todo
		if(ORGAN_SLOT_EXTERNAL_WINGS)
			if(!human.wear_suit)
				return TRUE
			if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
				return TRUE
			return FALSE
		if(ORGAN_SLOT_EXTERNAL_ANTENNAE)
			return TRUE //todo
		if(ORGAN_SLOT_EXTERNAL_POD_HAIR)
			if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
				return FALSE
			return TRUE
