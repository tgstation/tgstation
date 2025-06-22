/// Bodypart overlays focused on texturing limbs
/datum/bodypart_overlay/texture
	/// icon file for the texture
	var/texture_icon
	/// icon state for the texture
	var/texture_icon_state
	/// Cache the icon so we dont have to make a new one each time
	var/cached_texture_icon
	/// Priority of this texture - all textures with a lower priority will not be rendered
	var/overlay_priority = 0

/datum/bodypart_overlay/texture/New()
	. = ..()
	cached_texture_icon = icon(texture_icon, texture_icon_state)

/datum/bodypart_overlay/texture/modify_bodypart_appearance(datum/appearance)
	appearance.add_filter("bodypart_texture_[texture_icon_state]", 1, layering_filter(icon = cached_texture_icon, blend_mode = BLEND_INSET_OVERLAY))

/datum/bodypart_overlay/texture/generate_icon_cache()
	return "[type]"

/datum/bodypart_overlay/texture/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	for (var/datum/bodypart_overlay/texture/other_texture in bodypart_owner.bodypart_overlays)
		if (other_texture.overlay_priority > overlay_priority)
			return FALSE
	return TRUE

/datum/bodypart_overlay/texture/spacey
	blocks_emissive = EMISSIVE_BLOCK_NONE
	texture_icon_state = "spacey"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_VOIDWALKER_CURSE

/datum/bodypart_overlay/texture/carpskin
	texture_icon_state = "carpskin"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_CARP_INFUSION

/datum/bodypart_overlay/texture/checkered
	texture_icon_state = "checkered"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_CSS_SUICIDE

/datum/bodypart_overlay/texture/fishscale
	texture_icon_state = "fishscale"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_FISH_INFUSION
