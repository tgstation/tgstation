/proc/generate_genitals_shot(datum/sprite_accessory/sprite_accessory, key)
	var/icon/final_icon = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_f", SOUTH)

	if (!isnull(sprite_accessory))
		var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", SOUTH)
		var/icon/accessory_icon_2 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_2", SOUTH)
		accessory_icon_2.Blend(COLOR_RED, ICON_MULTIPLY)
		var/icon/accessory_icon_3 = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ_3", SOUTH)
		accessory_icon_3.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_2, ICON_OVERLAY)
		final_icon.Blend(accessory_icon_3, ICON_OVERLAY)

	final_icon.Crop(10, 8, 22, 23)
	final_icon.Scale(26, 32)
	final_icon.Crop(-2, 1, 29, 32)

	return final_icon
