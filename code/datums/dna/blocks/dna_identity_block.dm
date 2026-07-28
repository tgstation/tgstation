/datum/dna_block/identity/gender

/datum/dna_block/identity/gender/create_unique_block(mob/living/carbon/human/target)
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

/datum/dna_block/identity/gender/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	//Always plural gender if agender
	if(HAS_TRAIT(target, TRAIT_AGENDER))
		target.gender = PLURAL
		return
	switch(deconstruct_block(get_block(dna_hash), GENDERS))
		if(G_MALE)
			target.gender = MALE
		if(G_FEMALE)
			target.gender = FEMALE
		if(G_NEUTER)
			target.gender = NEUTER
		else
			target.gender = PLURAL

/datum/dna_block/identity/skin_tone

/datum/dna_block/identity/skin_tone/create_unique_block(mob/living/carbon/human/target)
	return construct_block(GLOB.skin_tones.Find(target.skin_tone), GLOB.skin_tones.len)

/datum/dna_block/identity/skin_tone/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.skin_tone = GLOB.skin_tones[deconstruct_block(get_block(dna_hash), GLOB.skin_tones.len)]

/// Holds both the left and right eye color at once
/datum/dna_block/identity/eye_colors
	block_length = DNA_BLOCK_SIZE_COLOR * 2 // Left eye color, then right eye color

/datum/dna_block/identity/eye_colors/create_unique_block(mob/living/carbon/human/target)
	var/left = sanitize_hexcolor(target.eye_color_left, include_crunch = FALSE)
	var/right = sanitize_hexcolor(target.eye_color_right, include_crunch = FALSE)
	return left + right

/datum/dna_block/identity/eye_colors/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/colors = get_block(dna_hash)
	var/right_color_begin = DNA_BLOCK_SIZE_COLOR + 1
	target.set_eye_color(sanitize_hexcolor(copytext(colors, 1, right_color_begin)), sanitize_hexcolor(copytext(colors, right_color_begin, length(colors) + 1)))

/datum/dna_block/identity/hair_style

/datum/dna_block/identity/hair_style/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.hairstyles_list.Find(target.hairstyle), length(SSaccessories.hairstyles_list))

/datum/dna_block/identity/hair_style/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	if(HAS_TRAIT(target, TRAIT_BALD))
		target.set_hairstyle("Bald", update = FALSE)
		return
	var/style = SSaccessories.hairstyles_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.hairstyles_list))]
	target.set_hairstyle(style, update = FALSE)

/datum/dna_block/identity/hair_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.hair_color, include_crunch = FALSE)

/datum/dna_block/identity/hair_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_haircolor(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/facial_style

/datum/dna_block/identity/facial_style/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.facial_hairstyles_list.Find(target.facial_hairstyle), length(SSaccessories.facial_hairstyles_list))

/datum/dna_block/identity/facial_style/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	if(HAS_TRAIT(target, TRAIT_SHAVED))
		target.set_facial_hairstyle("Shaved", update = FALSE)
		return
	var/style = SSaccessories.facial_hairstyles_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.facial_hairstyles_list))]
	target.set_facial_hairstyle(style, update = FALSE)

/datum/dna_block/identity/facial_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.facial_hair_color, include_crunch = FALSE)

/datum/dna_block/identity/facial_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_facial_haircolor(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/hair_gradient

/datum/dna_block/identity/hair_gradient/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.hair_gradients_list.Find(target.get_hair_gradient_style(GRADIENT_HAIR_KEY)), length(SSaccessories.hair_gradients_list))

/datum/dna_block/identity/hair_gradient/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/gradient_style = SSaccessories.hair_gradients_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.hair_gradients_list))]
	target.set_hair_gradient_style(gradient_style, update = FALSE)

/datum/dna_block/identity/hair_gradient_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/hair_gradient_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.get_hair_gradient_color(GRADIENT_HAIR_KEY), include_crunch = FALSE)

/datum/dna_block/identity/hair_gradient_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_hair_gradient_color(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/facial_gradient

/datum/dna_block/identity/facial_gradient/create_unique_block(mob/living/carbon/human/target)
	return construct_block(SSaccessories.facial_hair_gradients_list.Find(target.get_hair_gradient_style(GRADIENT_FACIAL_HAIR_KEY)), length(SSaccessories.facial_hair_gradients_list))

/datum/dna_block/identity/facial_gradient/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/gradient_style = SSaccessories.facial_hair_gradients_list[deconstruct_block(get_block(dna_hash), length(SSaccessories.facial_hair_gradients_list))]
	target.set_facial_hair_gradient_style(gradient_style, update = FALSE)

/datum/dna_block/identity/facial_gradient_color
	block_length = DNA_BLOCK_SIZE_COLOR

/datum/dna_block/identity/facial_gradient_color/create_unique_block(mob/living/carbon/human/target)
	return sanitize_hexcolor(target.get_hair_gradient_color(GRADIENT_FACIAL_HAIR_KEY), include_crunch = FALSE)

/datum/dna_block/identity/facial_gradient_color/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	target.set_facial_hair_gradient_color(sanitize_hexcolor(get_block(dna_hash)), update = FALSE)

/datum/dna_block/identity/height
	/// List of all heights you can have stored in your DNA
	/// Heights above the highest and below the lowest are locked to traits/mutations/species
	/// Actual DNA Height is stored as "index in dna_heights list"
	var/list/dna_heights = list(
		HUMAN_HEIGHT_SHORTEST,
		HUMAN_HEIGHT_SHORT,
		HUMAN_HEIGHT_MEDIUM,
		HUMAN_HEIGHT_TALL,
		HUMAN_HEIGHT_TALLER,
	)

/datum/dna_block/identity/height/create_unique_block(mob/living/carbon/human/target)
	var/max_height_index = length(dna_heights)
	var/mob_height_index = dna_heights.Find(target.get_base_mob_height()) || dna_heights.Find(HUMAN_HEIGHT_MEDIUM)
	return construct_block(mob_height_index, max_height_index, block_length)

/datum/dna_block/identity/height/apply_to_mob(mob/living/carbon/human/target, dna_hash)
	var/max_height_index = length(dna_heights)
	var/mob_height_index = deconstruct_block(get_block(dna_hash), max_height_index, block_length)
	target.set_mob_height(text2num(dna_heights[mob_height_index]) || HUMAN_HEIGHT_MEDIUM, update_dna = FALSE)
