#define SET_OVERLAY_VALUE(X,Y,Z) if(X) X.Y = Z

///Part of `update_limb()`, this proc does what the name implies.
/obj/item/bodypart/head/proc/update_hair_and_lips()
	var/mob/living/carbon/human/human_head_owner = owner
	var/datum/species/owner_species = human_head_owner.dna.species

	if(human_head_owner.lip_style && (LIPS in owner_species.species_traits))
		lip_style = human_head_owner.lip_style
		lip_color = human_head_owner.lip_color
	else
		lip_style = null
		lip_color = "white"

	///FACIAL HAIR CHECKS START
	//we check if our hat or helmet hides our facial hair.
	facial_hair_hidden = FALSE
	if(human_head_owner.head)
		var/obj/item/hat = human_head_owner.head
		if(hat.flags_inv & HIDEFACIALHAIR)
			facial_hair_hidden = TRUE

	if(human_head_owner.wear_mask)
		var/obj/item/mask = human_head_owner.wear_mask
		if(mask.flags_inv & HIDEFACIALHAIR)
			facial_hair_hidden = TRUE
	///FACIAL HAIR CHECKS END

	///HAIR CHECKS START
	hair_hidden = FALSE
	if(human_head_owner.head)
		var/obj/item/hat = human_head_owner.head
		if(hat.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(human_head_owner.w_uniform)
		var/obj/item/item_uniform = human_head_owner.w_uniform
		if(item_uniform.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(human_head_owner.wear_mask)
		var/obj/item/mask = human_head_owner.wear_mask
		if(mask.flags_inv & HIDEHAIR)
			hair_hidden = TRUE
	///HAIR CHECKS END
	//invisibility stuff
	if(HAS_TRAIT(human_head_owner, TRAIT_INVISIBLE_MAN))
		hair_hidden = TRUE
		facial_hair_hidden = TRUE

	if(!hair_hidden && !owner.getorganslot(ORGAN_SLOT_BRAIN) && !HAS_TRAIT(owner, TRAIT_NOBLOOD))
		show_debrained = TRUE
	else
		show_debrained = FALSE

	var/datum/sprite_accessory/sprite_accessory

	facial_overlay = null
	facial_gradient_overlay = null
	hair_overlay = null
	hair_gradient_overlay = null

	hair_alpha = owner_species.hair_alpha
	hair_color = human_head_owner.hair_color
	facial_hair_color = human_head_owner.facial_hair_color
	fixed_hair_color = owner_species.fixed_mut_color //Can be null
	hair_style = human_head_owner.hairstyle
	facial_hairstyle = human_head_owner.facial_hairstyle

	var/atom/location = loc || owner || src

	if(facial_hairstyle && !facial_hair_hidden && (FACEHAIR in species_flags_list))
		sprite_accessory = GLOB.facial_hairstyles_list[facial_hairstyle]
		if(sprite_accessory)
			//Create the overlay
			facial_overlay = mutable_appearance(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER)
			facial_overlay.overlays += emissive_blocker(facial_overlay.icon, facial_overlay.icon_state, location, alpha = hair_alpha)
			//Gradients
			facial_hair_gradient_style = LAZYACCESS(human_head_owner.grad_style, GRADIENT_FACIAL_HAIR_KEY)
			if(facial_hair_gradient_style)
				facial_hair_gradient_color = LAZYACCESS(human_head_owner.grad_color, GRADIENT_FACIAL_HAIR_KEY)
				facial_gradient_overlay = make_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, HAIR_LAYER, GLOB.facial_hair_gradients_list[facial_hair_gradient_style], facial_hair_gradient_color)

			facial_overlay.overlays += emissive_blocker(sprite_accessory.icon, sprite_accessory.icon_state, location, alpha = hair_alpha)

	if(!hair_hidden && !show_debrained && (HAIR in species_flags_list))
		sprite_accessory = GLOB.hairstyles_list[hair_style]
		if(sprite_accessory)
			hair_overlay = mutable_appearance(sprite_accessory.icon, sprite_accessory.icon_state, -HAIR_LAYER)
			hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, location, alpha = hair_alpha)
			hair_gradient_style = LAZYACCESS(human_head_owner.grad_style, GRADIENT_HAIR_KEY)
			if(hair_gradient_style)
				hair_gradient_color = LAZYACCESS(human_head_owner.grad_color, GRADIENT_HAIR_KEY)
				hair_gradient_overlay = make_gradient_overlay(sprite_accessory.icon, sprite_accessory.icon_state, HAIR_LAYER, GLOB.hair_gradients_list[hair_gradient_style], hair_gradient_color)

	//CREATION-ONLY END
	//HAIR COLOR START
	if(!override_hair_color)
		if(hair_color_source)
			if(hair_color_source == "fixedmutcolor")
				SET_OVERLAY_VALUE(facial_overlay, color, fixed_hair_color)
				SET_OVERLAY_VALUE(hair_overlay, color, fixed_hair_color)
			else if(hair_color_source == "mutcolor")
				SET_OVERLAY_VALUE(facial_overlay, color, facial_hair_color)
				SET_OVERLAY_VALUE(hair_overlay, color, hair_color)
			else
				SET_OVERLAY_VALUE(facial_overlay, color, hair_color_source)
				SET_OVERLAY_VALUE(hair_overlay, color, hair_color_source)
		else
			SET_OVERLAY_VALUE(facial_overlay, color, facial_hair_color)
			SET_OVERLAY_VALUE(hair_overlay, color, hair_color)
	else
		SET_OVERLAY_VALUE(facial_overlay, color, override_hair_color)
		SET_OVERLAY_VALUE(hair_overlay, color, override_hair_color)
	//HAIR COLOR END

#undef SET_OVERLAY_VALUE
