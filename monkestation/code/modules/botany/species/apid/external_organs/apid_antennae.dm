/obj/item/organ/external/antennae_apid
	name = "apid antennae"
	desc = "A apids antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	preference = "feature_apid_antenna"

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae_apid

///Moth antennae datum, with full burning functionality
/datum/bodypart_overlay/mutant/antennae_apid
	layers = EXTERNAL_ADJACENT
	feature_key = "apid_antenna"

/datum/bodypart_overlay/mutant/antennae_apid/get_global_feature_list()
	return GLOB.apid_antenna_list

/datum/bodypart_overlay/mutant/antennae_apid/get_base_icon_state()
	return sprite_datum.icon_state

/datum/sprite_accessory/apid_antenna
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/apid_antenna/moth
	name = "Moth"
	icon_state = "moth"

/datum/sprite_accessory/apid_antenna/fluffy
	name = "Fluffy"
	icon_state = "fluffy"

/datum/sprite_accessory/apid_antenna/wavy
	name = "Wavy"
	icon_state = "wavy"

/datum/sprite_accessory/apid_antenna/slickback
	name = "Slickback"
	icon_state = "slickback"

/datum/sprite_accessory/apid_antenna/horns
	name = "Horns"
	icon_state = "horns"

/datum/sprite_accessory/apid_antenna/straight
	name = "Straight"
	icon_state = "straight"

/datum/sprite_accessory/apid_antenna/triangle
	name = "Triangle"
	icon_state = "triangle"

/datum/sprite_accessory/apid_antenna/electric
	name = "Electric"
	icon_state = "electric"

/datum/sprite_accessory/apid_antenna/wisp
	name = "Wisp"
	icon_state = "wisp"

/datum/sprite_accessory/apid_antenna/plug
	name = "Plug"
	icon_state = "plug"

/datum/sprite_accessory/apid_antenna/leafy
	name = "Leafy"
	icon_state = "leafy"

/datum/sprite_accessory/apid_antenna/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/apid_antenna/warrior
	name = "Warrior"
	icon_state = "warrior"

/datum/sprite_accessory/apid_antenna/sidelights
	name = "Sidelights"
	icon_state = "sidelights"

/datum/sprite_accessory/apid_antenna/sprouts
	name = "Sprouts"
	icon_state = "sprouts"

/datum/sprite_accessory/apid_antenna/nubs
	name = "Nubs"
	icon_state = "nubs"

/datum/sprite_accessory/apid_antenna/ant
	name = "Ants"
	icon_state = "ant"

/datum/sprite_accessory/apid_antenna/crooked
	name = "Crooked"
	icon_state = "crooked"

/datum/sprite_accessory/apid_antenna/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/apid_antenna/snapped
	name = "Snapped"
	icon_state = "snapped"

/datum/sprite_accessory/apid_antenna/budding
	name = "Budding"
	icon_state = "budding"

/datum/sprite_accessory/apid_antenna/bumpers
	name = "Bumpers"
	icon_state = "bumpers"

/datum/sprite_accessory/apid_antenna/split
	name = "Split"
	icon_state = "split"
