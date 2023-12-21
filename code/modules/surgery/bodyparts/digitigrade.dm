/obj/item/bodypart/leg/proc/set_digitigrade(is_digi)
	if(is_digi)
		if(!can_be_digitigrade)
			return FALSE

		bodytype |= BODYTYPE_DIGITIGRADE
		. = TRUE
	else
		if(!(bodytype & BODYTYPE_DIGITIGRADE))
			return FALSE

		bodytype &= ~BODYTYPE_DIGITIGRADE
		if(old_limb_id)
			limb_id = old_limb_id
		. = TRUE

	if(.)
		if(owner)
			synchronize_bodytypes(owner)
			owner.update_body_parts()
		else
			update_icon_dropped()


/obj/item/bodypart/leg/update_limb(dropping_limb, is_creating)
	. = ..()
	if(!ishuman(owner) || !(bodytype & BODYTYPE_DIGITIGRADE))
		return

	var/mob/living/carbon/human/human_owner = owner
	var/uniform_compatible = FALSE
	var/suit_compatible = FALSE
	if(!(human_owner.w_uniform) || (human_owner.w_uniform.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON))) //Checks uniform compatibility
		uniform_compatible = TRUE
	if((!human_owner.wear_suit) || (human_owner.wear_suit.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
		suit_compatible = TRUE

	if((uniform_compatible && suit_compatible) || (suit_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
		old_limb_id = limb_id
		limb_id = digitigrade_id
	else
		limb_id = old_limb_id
