/datum/species/proc/return_accessory_layer(layer, datum/sprite_accessory/added_accessory, mob/living/carbon/human/host, passed_color)
	var/list/return_list = list()
	var/layertext = mutant_bodyparts_layertext(layer)
	var/g = (host.physique == FEMALE) ? "f" : "m"

	// add overlay on "external_slots" like tail, head and other parts
	for(var/list_item in added_accessory.external_slots)

		var/can_hidden_render = return_exernal_render_state(list_item, host)
		if(!can_hidden_render)
			continue // we failed the render check just dont bother (we just don't need to render it)

		if(!host.get_organ_slot(list_item))
			continue

		var/obj/item/organ/external/external_organ = host.get_organ_slot(list_item)

		if(!external_organ)
			continue

		var/external_sprite = external_organ.bodypart_overlay.sprite_datum.icon_state

		if(istype(external_organ.bodypart_overlay, /datum/bodypart_overlay/mutant/tail))
			var/datum/bodypart_overlay/mutant/tail/tail = external_organ.bodypart_overlay
			if(tail.wagging)
				list_item = "[list_item]_wagging"

		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		// we only use here m-gender icons because they are same as f-icons
		new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[external_sprite]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay

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
