/// Bodypart overlays focused on texturing limbs
/datum/bodypart_texture
	/// icon file for the texture
	var/texture_icon
	/// icon state for the texture
	var/texture_icon_state
	/// Cache the icon so we dont have to make a new one each time
	VAR_FINAL/icon/cached_texture_icon
	/// Priority of this texture - all textures with a lower priority will not be rendered
	var/overlay_priority = 0

/datum/bodypart_texture/New()
	. = ..()
	cached_texture_icon = icon(texture_icon, texture_icon_state)

/datum/bodypart_texture/proc/modify_bodypart_appearance(image/appearance)
	appearance.add_filter("bodypart_texture_[texture_icon_state]", 1, layering_filter(icon = cached_texture_icon, blend_mode = BLEND_INSET_OVERLAY))

/datum/bodypart_texture/proc/icon_render_key()
	return type

/datum/bodypart_texture/proc/can_texture_bodypart(obj/item/bodypart/bodypart_owner)
	for (var/datum/bodypart_texture/other_texture as anything in bodypart_owner.bodypart_textures)
		if (other_texture.overlay_priority > overlay_priority)
			return FALSE
	return TRUE

/datum/bodypart_texture/spacey
	texture_icon_state = "spacey"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_VOIDWALKER_CURSE

/datum/bodypart_texture/carpskin
	texture_icon_state = "carpskin"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_CARP_INFUSION

/datum/bodypart_texture/checkered
	texture_icon_state = "checkered"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_CSS_SUICIDE

/datum/bodypart_texture/checkered/modify_bodypart_appearance(image/appearance)
	. = ..()
	appearance.color = COLOR_WHITE

/datum/bodypart_texture/fishscale
	texture_icon_state = "fishscale"
	texture_icon = 'icons/mob/human/textures.dmi'
	overlay_priority = BODYPART_OVERLAY_FISH_INFUSION

/datum/bodypart_texture/mesh
	texture_icon_state = "mesh_mask"
	texture_icon = 'icons/mob/clothing/tail_suit_mask.dmi'
	overlay_priority = BODYPART_OVERLAY_MESH
	/// Icon state for displacement map that comes with the texture
	var/displacement_icon_state = "mesh_mask_displacement"
	/// Icon file for the displacement map that comes with the texture.
	var/displacement_icon = 'icons/mob/clothing/tail_suit_mask.dmi'
	/// Cache the displacement icon so we dont have to make a new one each time
	VAR_FINAL/icon/cached_displacement_icon

	/// Icon state for the lighting map that comes with the texture.
	var/lighting_icon_state = "mesh_mask_lighting"
	/// Icon file for the lighting map that comes with the texture.
	var/lighting_icon = 'icons/mob/clothing/tail_suit_mask.dmi'
	/// Cache the lighting icon so we dont have to make a new one each time
	VAR_FINAL/icon/cached_lighting_icon

	/// Color used for the outline filter
	var/outline_color = "#080808"

/datum/bodypart_texture/mesh/New()
	. = ..()
	cached_displacement_icon = icon(displacement_icon, displacement_icon_state)
	cached_lighting_icon = icon(lighting_icon, lighting_icon_state)

/datum/bodypart_texture/mesh/modify_bodypart_appearance(image/appearance)
	if(!should_modify(appearance))
		return

	. = ..()
	// adds a displacement map so the outline lines up with the bottom of the sprite
	appearance.add_filter("displacement", 2, displacement_map_filter(cached_displacement_icon, size = 1))
	// adds an outline so the texture doesn't end abruptly
	appearance.add_filter("outline", 3, outline_filter(1, outline_color, OUTLINE_SHARP))
	// adds a bit of lighting to make the texture look less flat
	appearance.add_filter("lighting", 4, layering_filter(cached_lighting_icon, blend_mode = BLEND_MULTIPLY))
	// forces white (blends better with the texture)
	appearance.color = COLOR_WHITE

/datum/bodypart_texture/mesh/proc/should_modify(image/appearance)
	// only apply to other mutant bodyparts. we filter by layer which is *absolutely* not ideal, but hey, work with what you got
	var/appearance_layer = abs(appearance.layer)
	return appearance_layer == BODY_ADJ_LAYER || appearance_layer == BODY_FRONT_LAYER || appearance_layer == BODY_BEHIND_LAYER

/datum/bodypart_texture/mesh/black
	texture_icon_state = "mesh_mask"
	outline_color = "#080808"

/datum/bodypart_texture/mesh/white
	texture_icon_state = "mesh_mask_white"
	outline_color = "#B2B2B2"

/datum/bodypart_texture/mesh/biosuit
	texture_icon_state = "mesh_mask_biosuit"
	outline_color = "#747182"

/datum/bodypart_texture/mesh/biosuit_dark
	texture_icon_state = "mesh_mask_biosuit_dark"
	outline_color = "#514F5B"

/datum/bodypart_texture/mesh/bombsuit
	texture_icon_state = "mesh_mask_bombsuit"
	outline_color = "#897B51"

/datum/bodypart_texture/mesh/bombsuit_white
	texture_icon_state = "mesh_mask_bombsuit_white"
	outline_color = "#A58975"

/datum/bodypart_texture/mesh/bombsuit_red
	texture_icon_state = "mesh_mask_bombsuit_red"
	outline_color = "#511D19"

/datum/bodypart_texture/mesh/firesuit
	texture_icon_state = "mesh_mask_firesuit"
	outline_color = "#262A33"

/datum/bodypart_texture/mesh/drake
	texture_icon_state = "mesh_mask_drake"
	outline_color = "#2B1B17"

/datum/bodypart_texture/mesh/cult
	texture_icon_state = "mesh_mask_cult"
	outline_color = "#413F3B"

/datum/bodypart_texture/mesh/heretic
	texture_icon_state = "mesh_mask_heretic"
	outline_color = "#270B08"

/datum/bodypart_texture/mesh/space
	texture_icon_state = "mesh_mask_space"
	outline_color = "#1F1F1F"
