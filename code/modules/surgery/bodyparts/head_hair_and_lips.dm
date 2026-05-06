/obj/item/bodypart/head/proc/copy_appearance_from(mob/living/carbon/human/target, overwrite_eyes = FALSE)
	var/datum/species/target_species = target.dna.species

	lip_style = target.lip_style
	lip_color = target.lip_color
	hairstyle = target.hairstyle
	hair_alpha = target_species.hair_alpha
	hair_color = target.hair_color
	facial_hairstyle = target.facial_hairstyle
	facial_hair_alpha = target_species.facial_hair_alpha
	facial_hair_color = target.facial_hair_color
	fixed_hair_color = target_species.get_fixed_hair_color(target) //Can be null
	gradient_styles = LAZYCOPY(target.grad_style)
	gradient_colors = LAZYCOPY(target.grad_color)
	var/obj/item/organ/eyes/peepers = locate() in src
	if(peepers)
		if(overwrite_eyes || isnull(initial(peepers.eye_color_left)))
			peepers.eye_color_left = target.eye_color_left
		if(overwrite_eyes || isnull(initial(peepers.eye_color_right)))
			peepers.eye_color_right = target.eye_color_right

	if(HAS_TRAIT(target, TRAIT_USES_SKINTONES))
		skin_tone = target.skin_tone
	else if(HAS_TRAIT(target, TRAIT_MUTANT_COLORS))
		skin_tone = ""
		if(target_species.fixed_mut_color)
			species_color = target_species.fixed_mut_color
		else
			species_color = target.dna.features["mcolor"]
	else
		skin_tone = ""
		species_color = ""

/// Returns a list of all overlays associated with the lips
/obj/item/bodypart/head/proc/get_lips_overlays(dropped)
	. = list()
	if(!lip_style || is_husked || is_invisible || (owner?.obscured_slots & HIDEFACIALHAIR) || !(head_flags & HEAD_LIPS))
		return .

	var/image/lip_overlay = image('icons/mob/human/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, dir = (dropped ? SOUTH : null))
	lip_overlay.color = lip_color
	worn_face_offset?.apply_offset(lip_overlay)
	. += lip_overlay
	return .

/// Returns a list of all hair/facial hair related overlays, or alternatively the debrained overlay if applicable
/obj/item/bodypart/head/proc/get_hair_overlays(dropped)
	. = list()
	var/hair_hidden = is_husked || is_invisible || (owner?.obscured_slots & HIDEHAIR)
	var/facial_hair_hidden = is_husked || is_invisible || (owner?.obscured_slots & HIDEFACIALHAIR)

	if(!facial_hair_hidden && (head_flags & HEAD_FACIAL_HAIR))
		. += get_base_facial_hair_overlays(dropped)

	if(!hair_hidden)
		var/obj/item/organ/brain/brain = locate() in src
		if(QDELETED(brain) && (head_flags & HEAD_DEBRAIN))
			. += get_debrain_overlay(dropped)
		else if(head_flags & HEAD_HAIR)
			. += get_base_hair_overlays(dropped)

	return .

/// Used in constructing the hair overlays - handles just facial hair
/obj/item/bodypart/head/proc/get_base_facial_hair_overlays(dropped)
	PRIVATE_PROC(TRUE)
	. = list()
	var/datum/sprite_accessory/facial_hair/sprite_accessory = SSaccessories.facial_hairstyles_list[facial_hairstyle]
	if(!sprite_accessory || sprite_accessory.icon_state == SPRITE_ACCESSORY_NONE)
		return .

	var/atom/location = loc || owner || src
	var/image_dir = dropped ? SOUTH : null

	// Overlay
	var/image/facial_hair_overlay = image(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER, dir = image_dir)
	facial_hair_overlay.alpha = facial_hair_alpha
	set_overlay_hair_color(facial_hair_overlay)
	// Emissive blocker
	if(blocks_emissive != EMISSIVE_BLOCK_NONE)
		var/mutable_appearance/em_block = emissive_blocker(facial_hair_overlay.icon, facial_hair_overlay.icon_state, location, alpha = facial_hair_alpha)
		if (dropped)
			em_block = image(em_block, dir = SOUTH)
		facial_hair_overlay.overlays += em_block

	//Offsets
	worn_face_offset?.apply_offset(facial_hair_overlay)
	. += facial_hair_overlay

	//Gradients
	var/facial_hair_gradient_style = get_hair_gradient_style(GRADIENT_FACIAL_HAIR_KEY)
	if(facial_hair_gradient_style != SPRITE_ACCESSORY_NONE)
		var/facial_hair_gradient_color = get_hair_gradient_color(GRADIENT_FACIAL_HAIR_KEY)
		var/image/facial_hair_gradient_overlay = get_gradient_overlay(icon(sprite_accessory.icon, sprite_accessory.icon_state), -HAIR_LAYER, SSaccessories.facial_hair_gradients_list[facial_hair_gradient_style], facial_hair_gradient_color, dropped)
		. += facial_hair_gradient_overlay

	return .

/// Used in constructing the hair overlays - handles just the hair on top of the head
/obj/item/bodypart/head/proc/get_base_hair_overlays(dropped)
	PRIVATE_PROC(TRUE)
	. = list()
	var/datum/sprite_accessory/hair/hair_sprite_accessory = SSaccessories.hairstyles_list[hairstyle]
	if(!hair_sprite_accessory || hair_sprite_accessory.icon_state == SPRITE_ACCESSORY_NONE)
		return .

	var/atom/location = loc || owner || src
	var/image_dir = dropped ? SOUTH : null

	var/list/all_hair_overlays = list()
	// Hair masks
	var/icon/base_icon = icon(hair_sprite_accessory.getCachedIcon(owner?.hair_masks))
	// Overlay
	all_hair_overlays += image(base_icon, layer = -HAIR_LAYER, dir = image_dir)
	// If we have any hair appendages (ponytails, etc.) sticking out on a particular side,
	// we need to add an additional hair layer to go above hats/helmets for the sides they stick out on
	if(LAZYLEN(hair_sprite_accessory.hair_appendages_outer))
		var/strictly_masked_zones = NONE
		for(var/datum/hair_mask/mask as anything in owner?.hair_masks)
			strictly_masked_zones |= mask.strict_coverage_zones
		for(var/appendage_icon_state in hair_sprite_accessory.hair_appendages_outer)
			var/appendage_zone = hair_sprite_accessory.hair_appendages_outer[appendage_icon_state]
			if(!(appendage_zone & strictly_masked_zones)) // if there are no strict masks in this zone
				all_hair_overlays += image(hair_sprite_accessory.icon, icon_state = appendage_icon_state, layer = -OUTER_HAIR_LAYER, dir = image_dir)

	for(var/image/hair_overlay as anything in all_hair_overlays)
		set_overlay_hair_color(hair_overlay)
		hair_overlay.alpha = hair_alpha
		hair_overlay.pixel_z = hair_sprite_accessory.y_offset
		// Emissive blocker
		if(blocks_emissive != EMISSIVE_BLOCK_NONE)
			var/mutable_appearance/em_block = emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, location, alpha = hair_alpha)
			if (dropped)
				em_block = image(em_block, dir = SOUTH)
			hair_overlay.overlays += em_block
		// Offsets
		worn_face_offset?.apply_offset(hair_overlay)
		. += hair_overlay
		// Gradients
		var/hair_gradient_style = get_hair_gradient_style(GRADIENT_HAIR_KEY)
		if(hair_gradient_style != SPRITE_ACCESSORY_NONE)
			var/hair_gradient_color = get_hair_gradient_color(GRADIENT_HAIR_KEY)
			var/image/hair_gradient_overlay = get_gradient_overlay(base_icon, hair_overlay.layer, SSaccessories.hair_gradients_list[hair_gradient_style], hair_gradient_color, dropped)
			hair_gradient_overlay.pixel_z = hair_sprite_accessory.y_offset
			. += hair_gradient_overlay

	return .

/// Helper for setting hair color of an overlay appropriately
/obj/item/bodypart/head/proc/set_overlay_hair_color(image/hair_overlay)
	PRIVATE_PROC(TRUE)
	if(override_hair_color)
		hair_overlay.color = override_hair_color
	else if(fixed_hair_color)
		hair_overlay.color = fixed_hair_color
	else
		hair_overlay.color = hair_color

/// Returns a list of all eye related overlays, or an eyeless overlay if applicable
/obj/item/bodypart/head/proc/get_eye_overlays(dropped)
	. = list()

	var/obj/item/organ/eyes/eyes = locate() in src
	if(QDELETED(eyes))
		if(head_flags & HEAD_EYEHOLES)
			. += get_eyeless_overlay(dropped)
		return .

	if(head_flags & HEAD_EYESPRITES)
		. += eyes.generate_body_overlay(src)

	return .

/// Returns an appropriate debrained overlay
/obj/item/bodypart/head/proc/get_debrain_overlay(dropped)
	RETURN_TYPE(/image)
	var/debrain_icon = 'icons/mob/human/human_face.dmi'
	var/debrain_icon_state = "debrained"
	if(bodytype & BODYTYPE_ALIEN)
		debrain_icon = 'icons/mob/human/species/alien/bodyparts.dmi'
		debrain_icon_state = "debrained_alien"
	else if(bodytype & BODYTYPE_LARVA_PLACEHOLDER)
		debrain_icon = 'icons/mob/human/species/alien/bodyparts.dmi'
		debrain_icon_state = "debrained_larva"
	else if(bodytype & BODYTYPE_GOLEM)
		debrain_icon = 'icons/mob/human/species/golems.dmi'
		debrain_icon_state = "debrained"

	var/image/debrain_overlay = mutable_appearance(debrain_icon, debrain_icon_state, -HAIR_LAYER)
	if (dropped)
		debrain_overlay = image(debrain_overlay, dir = SOUTH)
	worn_face_offset?.apply_offset(debrain_overlay)
	return debrain_overlay

/// Returns an appropriate missing eyes overlay
/obj/item/bodypart/head/proc/get_eyeless_overlay(dropped)
	RETURN_TYPE(/image)
	var/eyeless_icon = 'icons/mob/human/human_eyes.dmi'
	var/eyeless_icon_state = "eyes_missing"

	var/image/eyeless_overlay = mutable_appearance(eyeless_icon, eyeless_icon_state, -HAIR_LAYER)
	if (dropped)
		eyeless_overlay = image(eyeless_overlay, dir = SOUTH)
	worn_face_offset?.apply_offset(eyeless_overlay)
	return eyeless_overlay

/// Returns an appropriate hair/facial hair gradient overlay
/obj/item/bodypart/head/proc/get_gradient_overlay(icon/base_icon, layer, datum/sprite_accessory/gradient, grad_color, dropped)
	RETURN_TYPE(/mutable_appearance)

	var/mutable_appearance/gradient_overlay = mutable_appearance(layer = layer)
	var/icon/temp = icon(gradient.icon, gradient.icon_state)
	var/icon/temp_hair = icon(base_icon)
	temp.Blend(temp_hair, ICON_ADD)
	gradient_overlay.icon = temp
	gradient_overlay.color = grad_color
	if (dropped)
		gradient_overlay = image(gradient_overlay, dir = SOUTH)
	worn_face_offset?.apply_offset(gradient_overlay)
	return gradient_overlay

/**
 * Used to update the makeup on a human and apply/remove lipstick traits, then store/unstore them on the head object in case it gets severed
 **/
/mob/living/proc/update_lips(new_style, new_color, apply_trait, update = TRUE)
	return

/mob/living/carbon/human/update_lips(new_style, new_color, apply_trait, update = TRUE)
	lip_style = new_style
	lip_color = new_color

	var/obj/item/bodypart/head/hopefully_a_head = get_bodypart(BODY_ZONE_HEAD)
	REMOVE_TRAITS_IN(src, LIPSTICK_TRAIT)
	if(hopefully_a_head)
		hopefully_a_head.stored_lipstick_trait = null
		hopefully_a_head.lip_style = new_style
		hopefully_a_head.lip_color = new_color
	if(new_style && apply_trait)
		ADD_TRAIT(src, apply_trait, LIPSTICK_TRAIT)
		hopefully_a_head?.stored_lipstick_trait = apply_trait

	if(update)
		update_body() // lips is done as a body layer

/**
 * A wrapper for [mob/living/carbon/human/proc/update_lips] that sets the lip style and color to null.
 **/
/mob/living/proc/clean_lips()
	return

/mob/living/carbon/human/clean_lips()
	if(!lip_style)
		return FALSE
	update_lips(null, null, update = TRUE)
	return TRUE

/**
 * Set the hair style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_hairstyle(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_hairstyle(new_style, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	hairstyle = new_style
	my_head?.hairstyle = new_style

	if(update)
		update_hair()

/**
 * Set the hair color of a human.
 * Override instead sets the override value, it will not be changed away from the override value until override is set to null.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_haircolor(hex_string, override, update = TRUE)
	return

/mob/living/carbon/human/set_haircolor(hex_string, override, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	if(override)
		// aight, no head? tough luck
		my_head?.override_hair_color = hex_string
	else
		hair_color = hex_string
		my_head?.hair_color = hex_string

	if(update)
		update_hair()

/**
 * Get the hair gradient style of a human.
 * Defaults to "None".
 * arguments:
 * * key (optional) - corresponds to hair or facial hair index. If no key is provided returns whole list.
 **/
/mob/living/proc/get_hair_gradient_style(key)
	return

/mob/living/carbon/human/get_hair_gradient_style(key)
	if(key)
		return LAZYACCESS(grad_style, key) || "None"

	return grad_style || list(
		"None",	//Hair Gradient Style
		"None",	//Facial Hair Gradient Style
	)

/**
 * Get the hair gradient style of a head.
 * Defaults to "None".
 * arguments:
 * * key (optional) - corresponds to hair or facial hair index. If no key is provided returns whole list.
 **/
/obj/item/bodypart/head/proc/get_hair_gradient_style(key)
	if(key)
		return LAZYACCESS(gradient_styles, key) || "None"

	return gradient_styles || list(
		"None",	//Hair Gradient Style
		"None",	//Facial Hair Gradient Style
	)

/**
 * Set the hair gradient style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_hair_gradient_style(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_hair_gradient_style(new_style, update = TRUE)
	if(LAZYACCESS(grad_style, GRADIENT_HAIR_KEY) == new_style)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSET(grad_style, GRADIENT_HAIR_KEY, new_style)
	if(my_head)
		LAZYSET(my_head.gradient_styles, GRADIENT_HAIR_KEY, new_style)

	if(update)
		update_hair()

/**
 * Get the hair gradient color of a human.
 * Defaults to black.
 *
 * arguments:
 * * key (optional) - corresponds to hair or facial hair index. If no key is provided returns whole list.
 **/
/mob/living/proc/get_hair_gradient_color(key)
	return

/mob/living/carbon/human/get_hair_gradient_color(key)
	if(key)
		return LAZYACCESS(grad_color, key) || COLOR_BLACK

	return grad_color || list(
		COLOR_BLACK,	//Hair Gradient Color
		COLOR_BLACK,	//Facial Hair Gradient Color
	)

/**
 * Get the hair gradient color of a head.
 * Defaults to black.
 *
 * arguments:
 * * key (optional) - corresponds to hair or facial hair index. If no key is provided returns whole list.
 **/
/obj/item/bodypart/head/proc/get_hair_gradient_color(key)
	if(key)
		return LAZYACCESS(gradient_colors, key) || COLOR_BLACK

	return gradient_colors || list(
		COLOR_BLACK,	//Hair Gradient Color
		COLOR_BLACK,	//Facial Hair Gradient Color
	)

/**
 * Set the hair gradient color of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_hair_gradient_color(new_color, update = TRUE)
	return

/mob/living/carbon/human/set_hair_gradient_color(new_color, update = TRUE)
	if(LAZYACCESS(grad_color, GRADIENT_HAIR_KEY) == new_color)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSET(grad_color, GRADIENT_HAIR_KEY, new_color)
	if(my_head)
		LAZYSET(my_head.gradient_colors, GRADIENT_HAIR_KEY, new_color)

	if(update)
		update_hair()

/**
 * Set the facial hair style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_hairstyle(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_facial_hairstyle(new_style, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	facial_hairstyle = new_style
	my_head?.facial_hairstyle = new_style

	if(update)
		update_hair()

/**
 * Set the facial hair color of a human.
 * Override instead sets the override value, it will not be changed away from the override value until override is set to null.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_haircolor(hex_string, override, update = TRUE)
	return

/mob/living/carbon/human/set_facial_haircolor(hex_string, override, update = TRUE)
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	if(override)
		// so no head? tough luck
		my_head?.override_hair_color = hex_string
	else
		facial_hair_color = hex_string
		my_head?.facial_hair_color = hex_string

	if(update)
		update_hair()

/**
 * Set the facial hair gradient style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_hair_gradient_style(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_facial_hair_gradient_style(new_style, update = TRUE)
	if(LAZYACCESS(grad_style, GRADIENT_FACIAL_HAIR_KEY) == new_style)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSET(grad_style, GRADIENT_FACIAL_HAIR_KEY, new_style)
	if(my_head)
		LAZYSET(my_head.gradient_styles, GRADIENT_FACIAL_HAIR_KEY, new_style)

	if(update)
		update_hair()

/**
 * Set the facial hair gradient color of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_hair_gradient_color(new_color, update = TRUE)
	return

/mob/living/carbon/human/set_facial_hair_gradient_color(new_color, update = TRUE)
	if(LAZYACCESS(grad_color, GRADIENT_FACIAL_HAIR_KEY) == new_color)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSET(grad_color, GRADIENT_FACIAL_HAIR_KEY, new_color)
	if(my_head)
		LAZYSET(my_head.gradient_colors, GRADIENT_FACIAL_HAIR_KEY, new_color)

	if(update)
		update_hair()
