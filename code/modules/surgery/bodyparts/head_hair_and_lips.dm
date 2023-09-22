#define SET_OVERLAY_VALUE(overlay,variable,value) if(overlay) overlay.variable = value

/// Part of `update_limb()`, basically does all the head specific icon stuff.
/obj/item/bodypart/head/proc/update_hair_and_lips(dropping_limb, is_creating)
	var/mob/living/carbon/human/human_head_owner = owner
	var/datum/species/owner_species = human_head_owner?.dna.species

	//HIDDEN CHECKS START
	hair_hidden = FALSE
	facial_hair_hidden = FALSE
	if(human_head_owner)
		if(human_head_owner.head)
			var/obj/item/hat = human_head_owner.head
			if(hat.flags_inv & HIDEHAIR)
				hair_hidden = TRUE
			if(hat.flags_inv & HIDEFACIALHAIR)
				facial_hair_hidden = TRUE

		if(human_head_owner.wear_mask)
			var/obj/item/mask = human_head_owner.wear_mask
			if(mask.flags_inv & HIDEHAIR)
				hair_hidden = TRUE
			if(mask.flags_inv & HIDEFACIALHAIR)
				facial_hair_hidden = TRUE

		if(human_head_owner.w_uniform)
			var/obj/item/item_uniform = human_head_owner.w_uniform
			if(item_uniform.flags_inv & HIDEHAIR)
				hair_hidden = TRUE
			if(item_uniform.flags_inv & HIDEFACIALHAIR)
				facial_hair_hidden = TRUE
		//invisibility and husk stuff
		if(HAS_TRAIT(human_head_owner, TRAIT_INVISIBLE_MAN) || HAS_TRAIT(human_head_owner, TRAIT_HUSK))
			hair_hidden = TRUE
			facial_hair_hidden = TRUE
	if(is_husked)
		hair_hidden = TRUE
		facial_hair_hidden = TRUE
	//HIDDEN CHECKS END

	if(owner)
		if(!hair_hidden && !owner.get_organ_slot(ORGAN_SLOT_BRAIN) && !HAS_TRAIT(owner, TRAIT_NO_DEBRAIN_OVERLAY))
			show_debrained = TRUE
		else
			show_debrained = FALSE

		if(!owner.get_organ_slot(ORGAN_SLOT_EYES))
			show_eyeless = TRUE
		else
			show_eyeless = FALSE
	else
		if(!hair_hidden && !brain)
			show_debrained = TRUE
		else
			show_debrained = FALSE

		if(!eyes)
			show_eyeless = TRUE
		else
			show_eyeless = FALSE

	if(!is_creating || !owner)
		return

	lip_style = human_head_owner.lip_style
	lip_color = human_head_owner.lip_color
	hairstyle = human_head_owner.hairstyle
	hair_alpha = owner_species.hair_alpha
	hair_color = human_head_owner.hair_color
	facial_hairstyle = human_head_owner.facial_hairstyle
	facial_hair_alpha = owner_species.facial_hair_alpha
	facial_hair_color = human_head_owner.facial_hair_color
	fixed_hair_color = owner_species.fixed_hair_color //Can be null
	gradient_styles = human_head_owner.grad_style?.Copy()
	gradient_colors = human_head_owner.grad_color?.Copy()

/obj/item/bodypart/head/proc/get_hair_and_lips_icon(dropped)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)
	. = list()

	var/atom/location = loc || owner || src
	var/image_dir = NONE
	if(dropped)
		image_dir = SOUTH

	var/datum/sprite_accessory/sprite_accessory
	if(!facial_hair_hidden && lip_style && (head_flags & HEAD_LIPS))
		//not a sprite accessory, don't ask
		//Overlay
		var/image/lip_overlay = image('icons/mob/human/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, image_dir)
		lip_overlay.color = lip_color
		//Emissive blocker
		if(blocks_emissive != EMISSIVE_BLOCK_NONE)
			lip_overlay.overlays += emissive_blocker(lip_overlay.icon, lip_overlay.icon_state, location, alpha = facial_hair_alpha)
		//Offsets
		worn_face_offset?.apply_offset(lip_overlay)
		. += lip_overlay

	var/image/facial_hair_overlay
	if(!facial_hair_hidden && facial_hairstyle && (head_flags & HEAD_FACIAL_HAIR))
		sprite_accessory = GLOB.facial_hairstyles_list[facial_hairstyle]
		if(sprite_accessory)
			//Overlay
			facial_hair_overlay = image(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER, image_dir)
			facial_hair_overlay.alpha = facial_hair_alpha
			//Emissive blocker
			if(blocks_emissive != EMISSIVE_BLOCK_NONE)
				facial_hair_overlay.overlays += emissive_blocker(facial_hair_overlay.icon, facial_hair_overlay.icon_state, location, alpha = facial_hair_alpha)
			//Offsets
			worn_face_offset?.apply_offset(facial_hair_overlay)
			. += facial_hair_overlay
			//Gradients
			var/facial_hair_gradient_style = LAZYACCESS(gradient_styles, GRADIENT_FACIAL_HAIR_KEY)
			if(facial_hair_gradient_style)
				var/facial_hair_gradient_color = LAZYACCESS(gradient_colors, GRADIENT_FACIAL_HAIR_KEY)
				var/image/facial_hair_gradient_overlay = get_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER, GLOB.facial_hair_gradients_list[facial_hair_gradient_style], facial_hair_gradient_color)
				. += facial_hair_gradient_overlay

	var/image/hair_overlay
	if(!(show_debrained && (head_flags & HEAD_DEBRAIN)) && !hair_hidden && hairstyle && (head_flags & HEAD_HAIR))
		sprite_accessory = GLOB.hairstyles_list[hairstyle]
		if(sprite_accessory)
			//Overlay
			hair_overlay = image(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER, image_dir)
			hair_overlay.alpha = hair_alpha
			//Emissive blocker
			if(blocks_emissive != EMISSIVE_BLOCK_NONE)
				hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, location, alpha = hair_alpha)
			//Offsets
			worn_face_offset?.apply_offset(hair_overlay)
			. += hair_overlay
			//Gradients
			var/hair_gradient_style = LAZYACCESS(gradient_styles, GRADIENT_HAIR_KEY)
			if(hair_gradient_style)
				var/hair_gradient_color = LAZYACCESS(gradient_colors, GRADIENT_HAIR_KEY)
				var/image/hair_gradient_overlay = get_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER, GLOB.hair_gradients_list[hair_gradient_style], hair_gradient_color)
				. += hair_gradient_overlay

	if(show_debrained && (head_flags & HEAD_DEBRAIN))
		. += get_debrain_overlay(can_rotate = !dropped)

	if(show_eyeless && (head_flags & HEAD_EYEHOLES))
		. += get_eyeless_overlay(can_rotate = !dropped)

	//HAIR COLOR START
	if(override_hair_color)
		SET_OVERLAY_VALUE(facial_hair_overlay, color, override_hair_color)
		SET_OVERLAY_VALUE(hair_overlay, color, override_hair_color)
	else if(fixed_hair_color)
		SET_OVERLAY_VALUE(facial_hair_overlay, color, fixed_hair_color)
		SET_OVERLAY_VALUE(hair_overlay, color, fixed_hair_color)
	else
		SET_OVERLAY_VALUE(facial_hair_overlay, color, facial_hair_color)
		SET_OVERLAY_VALUE(hair_overlay, color, hair_color)
	//HAIR COLOR END

	return .

#undef SET_OVERLAY_VALUE

/// Returns an appropriate debrained overlay
/obj/item/bodypart/head/proc/get_debrain_overlay(can_rotate = TRUE)
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

	var/image/debrain_overlay
	if(can_rotate)
		debrain_overlay = mutable_appearance(debrain_icon, debrain_icon_state, HAIR_LAYER)
	else
		debrain_overlay = image(debrain_icon, debrain_icon_state, -HAIR_LAYER, SOUTH)
	worn_face_offset?.apply_offset(debrain_overlay)
	return debrain_overlay

/// Returns an appropriate missing eyes overlay
/obj/item/bodypart/head/proc/get_eyeless_overlay(can_rotate = TRUE)
	RETURN_TYPE(/image)
	var/eyeless_icon = 'icons/mob/human/human_face.dmi'
	var/eyeless_icon_state = "eyes_missing"

	var/image/eyeless_overlay
	if(can_rotate)
		eyeless_overlay = mutable_appearance(eyeless_icon, eyeless_icon_state, HAIR_LAYER)
	else
		eyeless_overlay = image(eyeless_icon, eyeless_icon_state, -HAIR_LAYER, SOUTH)
	worn_face_offset?.apply_offset(eyeless_overlay)
	return eyeless_overlay

/// Returns an appropriate hair/facial hair gradient overlay
/obj/item/bodypart/head/proc/get_gradient_overlay(file, icon, layer, datum/sprite_accessory/gradient, grad_color)
	RETURN_TYPE(/mutable_appearance)

	var/mutable_appearance/gradient_overlay = mutable_appearance(layer = layer)
	var/icon/temp = icon(gradient.icon, gradient.icon_state)
	var/icon/temp_hair = icon(file, icon)
	temp.Blend(temp_hair, ICON_ADD)
	gradient_overlay.icon = temp
	gradient_overlay.color = grad_color
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
		update_body_parts()

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
		update_body_parts()

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
		update_body_parts()

/**
 * Set the hair gradient style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_hair_gradient_style(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_hair_gradient_style(new_style, update = TRUE)
	if(new_style == "None")
		new_style = null
	if(LAZYACCESS(grad_style, GRADIENT_HAIR_KEY) == new_style)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSETLEN(grad_style, GRADIENTS_LEN)
	LAZYSETLEN(grad_color, GRADIENTS_LEN)
	grad_style[GRADIENT_HAIR_KEY] = new_style
	if(my_head)
		LAZYSETLEN(my_head.gradient_styles, GRADIENTS_LEN)
		LAZYSETLEN(my_head.gradient_colors, GRADIENTS_LEN)
		my_head.gradient_styles[GRADIENT_HAIR_KEY] = new_style

	if(update)
		update_body_parts()

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


	LAZYSETLEN(grad_style, GRADIENTS_LEN)
	LAZYSETLEN(grad_color, GRADIENTS_LEN)
	grad_color[GRADIENT_HAIR_KEY] = new_color
	if(my_head)
		LAZYSETLEN(my_head.gradient_styles, GRADIENTS_LEN)
		LAZYSETLEN(my_head.gradient_colors, GRADIENTS_LEN)
		my_head.gradient_colors[GRADIENT_HAIR_KEY] = new_color

	if(update)
		update_body_parts()

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
		update_body_parts()

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
		update_body_parts()

/**
 * Set the facial hair gradient style of a human.
 * Update calls update_body_parts().
 **/
/mob/living/proc/set_facial_hair_gradient_style(new_style, update = TRUE)
	return

/mob/living/carbon/human/set_facial_hair_gradient_style(new_style, update = TRUE)
	if(new_style == "None")
		new_style = null
	if(LAZYACCESS(grad_style, GRADIENT_FACIAL_HAIR_KEY) == new_style)
		return
	var/obj/item/bodypart/head/my_head = get_bodypart(BODY_ZONE_HEAD)

	LAZYSETLEN(grad_style, GRADIENTS_LEN)
	LAZYSETLEN(grad_color, GRADIENTS_LEN)
	grad_style[GRADIENT_FACIAL_HAIR_KEY] = new_style
	if(my_head)
		LAZYSETLEN(my_head.gradient_styles, GRADIENTS_LEN)
		LAZYSETLEN(my_head.gradient_colors, GRADIENTS_LEN)
		my_head.gradient_styles[GRADIENT_FACIAL_HAIR_KEY] = new_style

	if(update)
		update_body_parts()

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

	LAZYSETLEN(grad_style, GRADIENTS_LEN)
	LAZYSETLEN(grad_color, GRADIENTS_LEN)
	grad_color[GRADIENT_FACIAL_HAIR_KEY] = new_color
	if(my_head)
		LAZYSETLEN(my_head.gradient_styles, GRADIENTS_LEN)
		LAZYSETLEN(my_head.gradient_colors, GRADIENTS_LEN)
		my_head.gradient_colors[GRADIENT_FACIAL_HAIR_KEY] = new_color

	if(update)
		update_body_parts()
