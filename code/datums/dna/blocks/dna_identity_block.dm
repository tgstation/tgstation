/datum/dna_block/identity/gender
	block_id = DNA_UI_GENDER

/datum/dna_block/identity/gender/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	//ignores TRAIT_AGENDER so that a "real" gender can be stored in the DNA if later use is needed
	switch(target.gender)
		if(MALE)
			. = construct_block(G_MALE, GENDERS)
		if(FEMALE)
			. = construct_block(G_FEMALE, GENDERS)
		if(NEUTER)
			. = construct_block(G_NEUTER, GENDERS)
		else
			. = construct_block(G_PLURAL, GENDERS)
	return .

/datum/dna_block/identity/skin_tone
	block_id = DNA_UI_SKIN_TONE

/datum/dna_block/identity/skin_tone/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(GLOB.skin_tones.Find(target.skin_tone), GLOB.skin_tones.len)

// These might be mergeable into one, larger DNA block
// That's out of scope for me just moving the system over to datums though
// Okay I might have to do it anyhow
/datum/dna_block/identity/eye_color_left
	block_id = DNA_UI_EYE_COLOR_LEFT
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/eye_color_left/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.eye_color_left, include_crunch = FALSE)

/datum/dna_block/identity/eye_color_right
	block_id = DNA_UI_EYE_COLOR_RIGHT
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/eye_color_right/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.eye_color_right, include_crunch = FALSE)

/datum/dna_block/identity/hair_style
	block_id = DNA_UI_HAIR

/datum/dna_block/identity/hair_style/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.hairstyles_list.Find(target.hairstyle), length(SSaccessories.hairstyles_list))

/datum/dna_block/identity/hair_color
	block_id = DNA_UI_HAIR_COLOR
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_color/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.hair_color, include_crunch = FALSE)

/datum/dna_block/identity/facial_style
	block_id = DNA_UI_FACIALSTYLE

/datum/dna_block/identity/facial_style/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.facial_hairstyles_list.Find(target.facial_hairstyle), length(SSaccessories.facial_hairstyles_list))

/datum/dna_block/identity/facial_color
	block_id = DNA_UI_FACIAL_COLOR
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_color/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.facial_hair_color, include_crunch = FALSE)

/datum/dna_block/identity/hair_gradient
	block_id = DNA_UI_HAIR_GRADIENT

/datum/dna_block/identity/hair_gradient/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.hair_gradients_list.Find(target.grad_style[GRADIENT_HAIR_KEY]), length(SSaccessories.hair_gradients_list))

/datum/dna_block/identity/hair_gradient_color
	block_id = DNA_UI_HAIR_GRADIENT_COLOR
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_gradient_color/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.grad_color[GRADIENT_HAIR_KEY], include_crunch = FALSE)

/datum/dna_block/identity/facial_gradient
	block_id = DNA_UI_FACIAL_GRADIENT

/datum/dna_block/identity/facial_gradient/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return construct_block(SSaccessories.facial_hair_gradients_list.Find(target.grad_style[GRADIENT_FACIAL_HAIR_KEY]), length(SSaccessories.facial_hair_gradients_list))

/datum/dna_block/identity/facial_gradient_color
	block_id = DNA_UI_FACIAL_GRADIENT_COLOR
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_gradient_color/get_unique_block(mob/living/carbon/human/target)
	. = ..()
	return sanitize_hexcolor(target.grad_color[GRADIENT_FACIAL_HAIR_KEY], include_crunch = FALSE)
