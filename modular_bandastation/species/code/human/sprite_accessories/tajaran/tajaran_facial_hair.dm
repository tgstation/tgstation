/datum/sprite_accessory/tajaran_facial_hair
	icon = 'icons/bandastation/mob/species/tajaran/sprite_accessories/facial_hair.dmi'
	color_src = TRUE

/datum/sprite_accessory/tajaran_facial_hair/goatee
	name = "Goatee"
	icon_state = "goatee"

/datum/sprite_accessory/tajaran_facial_hair/goatee_faded
	name = "Faded goatee"
	icon_state = "goatee_faded"

/datum/sprite_accessory/tajaran_facial_hair/moustache
	name = "Moustache"
	icon_state = "moustache"

/datum/sprite_accessory/tajaran_facial_hair/faccial_mutton
	name = "Facial_mutton"
	icon_state = "facial_mutton"

/datum/sprite_accessory/tajaran_facial_hair/pencilstache
	name = "Pencilstache"
	icon_state = "pencilstache"

/datum/sprite_accessory/tajaran_facial_hair/sideburns
	name = "Sideburns"
	icon_state = "sideburns"

/datum/sprite_accessory/tajaran_facial_hair/smallstache
	name = "Smallstache"
	icon_state = "smallstache"

/// MARK: Bodypart overlay
/datum/bodypart_overlay/simple/body_marking/tajaran_facial_hair
	dna_feature_key = FEATURE_TAJARAN_FACIAL_HAIR
	dna_color_feature_key = FEATURE_TAJARAN_FACIAL_HAIR_COLOR
	applies_to = list(
		/obj/item/bodypart/head,
	)
