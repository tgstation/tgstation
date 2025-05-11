// helmet

/obj/item/clothing/head/helmet/lizard
	name = "\improper Tizirian tan helmet"
	desc = "A distinctly Tizirian designed helmet, special made to fit and long enough to the front to protect \
		an array of snout sizes from the top down. This gives a secondary benefit of heavily angling the front \
		profile, increasing strength. This one is tan for the empire's obligate service members."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "halo_levy"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "halo_levy"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	supported_bodyshapes = null
	flags_cover = EARS_COVERED
	flags_inv = null
	hair_mask = /datum/hair_mask/standard_hat_middle

/obj/item/clothing/head/helmet/lizard/glass
	desc = "A distinctly Tizirian designed helmet, special made to fit and long enough to the front to protect \
		an array of snout sizes from the top down. This gives a secondary benefit of heavily angling the front \
		profile, increasing strength. This one has a protective eye shield made of reflective orange glass, \
		and is tan for the empire's obligate service members."
	icon_state = "halo_two_levy"
	worn_icon_state = "halo_two_levy"
	flags_cover = HEADCOVERSEYES|EARS_COVERED

/obj/item/clothing/head/helmet/lizard/white
	name = "\improper Tizirian white helmet"
	desc = "A distinctly Tizirian designed helmet, special made to fit and long enough to the front to protect \
		an array of snout sizes from the top down. This gives a secondary benefit of heavily angling the front \
		profile, increasing strength. This one is white for the empire's career service members."
	icon_state = "halo_reg"
	worn_icon_state = "halo_reg"

/obj/item/clothing/head/helmet/lizard/white/glass
	desc = "A distinctly Tizirian designed helmet, special made to fit and long enough to the front to protect \
		an array of snout sizes from the top down. This gives a secondary benefit of heavily angling the front \
		profile, increasing strength. This one has a protective eye shield made of reflective orange glass, \
		and is white for the empire's career service members."
	icon_state = "halo_two_reg"
	worn_icon_state = "halo_two_reg"
	flags_cover = HEADCOVERSEYES|EARS_COVERED

// armor vest

/obj/item/clothing/suit/armor/lizard
	name = "\improper Tizirian breastplate"
	desc = "An important aspect of Tizirian childhood, or rather, the end of it. A thick breastplate supported at \
		the shoulders and midsection by armored scales. Each citizen of the empire recieves one as part of their \
		coming of age ceremonies. The beginning of adulthood and a long life, and military service as well."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "armor"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "armor"
	supported_bodyshapes = null

// leg armor

/obj/item/clothing/shoes/lizard_shins
	name = "\improper Tizirian shin guards"
	desc = "Thick plated shin guards combined with a dyed wrap made for use by Tizirian soldiers. Especially \
		favored by close quarters specialists, and anyone who is currently being forced to carry heavy cargo."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "guards"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "guards"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = FEET|LEGS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/species_clothes/icons/tiziria/gear_worn_dig.dmi',
	)
	fastening_type = SHOES_STRAPS
	armor_type = /datum/armor/colonist_armor

// gloves

/obj/item/clothing/gloves/lizard_gloves
	name = "\improper Tizirian gauntlets"
	desc = "Gloves common in Tizirian service regardless of rank, with a thick decorated plate on the user's sword \
		arm. Mostly a customary holdover from times well past, but a Tizirian melee fighter would feel naked without one."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "gloves"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "gloves"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null
	body_parts_covered = HANDS|ARMS
	armor_type = /datum/armor/colonist_armor
