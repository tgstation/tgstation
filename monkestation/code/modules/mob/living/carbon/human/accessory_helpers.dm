/datum/species/proc/return_accessory_layer(layer, datum/sprite_accessory/added_accessory, mob/living/carbon/human/host, passed_color)
	var/list/return_list = list()
	var/layertext = mutant_bodyparts_layertext(layer)
	var/g = (host.physique == FEMALE) ? "f" : "m"
	for(var/list_item in added_accessory.external_slots)
		if(!host.get_organ_slot(list_item) && !istype(host, /mob/living/carbon/human/dummy/extra_tall))
			continue
		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay

	for(var/list_item in added_accessory.body_slots)
		if(!host.get_bodypart(list_item) && !istype(host, /mob/living/carbon/human/dummy/extra_tall))
			continue
		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay
	if(istype(host, /mob/living/carbon/human/dummy/extra_tall))
		var/mob/living/carbon/human/dummy/extra_tall/bleh = host
		bleh.extra_bodyparts += return_list

	return return_list
