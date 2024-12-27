/// Bodypart overlays focused on texturing limbs
/datum/bodypart_overlay/texture
	/// icon file for the texture
	var/texture_icon
	/// icon state for the texture
	var/texture_icon_state
	/// Cache the icon so we dont have to make a new one each time
	var/cached_texture_icon

/datum/bodypart_overlay/texture/New()
	. = ..()

	cached_texture_icon = icon(texture_icon, texture_icon_state)

/datum/bodypart_overlay/texture/modify_bodypart_appearance(datum/appearance)
	appearance.add_filter("bodypart_texture_[texture_icon_state]", 1, layering_filter(icon = cached_texture_icon,blend_mode = BLEND_INSET_OVERLAY))

/datum/bodypart_overlay/texture/generate_icon_cache()
	return "[type]"

/datum/bodypart_overlay/texture/spacey
	blocks_emissive = EMISSIVE_BLOCK_NONE
	texture_icon_state = "spacey"
	texture_icon = 'icons/mob/human/textures.dmi'

/datum/bodypart_overlay/texture/carpskin
	texture_icon_state = "carpskin"
	texture_icon = 'icons/mob/human/textures.dmi'

/datum/bodypart_overlay/texture/checkered
	texture_icon_state = "checkered"
	texture_icon = 'icons/mob/human/textures.dmi'
