/datum/sprite_accessory/body_marking
	color_src = "#CCCCCC"
	name = SPRITE_ACCESSORY_NONE
	icon_state = SPRITE_ACCESSORY_NONE
	gender_specific = FALSE
	var/body_zones

/datum/sprite_accessory/body_marking/other
	icon = 'modular_doppler/modular_customization/markings/icons/markings/other_markings.dmi'

/datum/sprite_accessory/body_marking/other/pilot_jaw
	name = "Pilot Jaw"
	icon_state = "pilot_jaw"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/tonage
	name = "Body Tonage"
	icon_state = "tonage"
	gender_specific = FALSE
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/belly_slim_toned
	name = "Belly Slim (Alt) + Tonage"
	icon_state = "bellyslimtoned"
	gender_specific = FALSE
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/flushed_cheeks
	name = "Flushed Cheeks"
	icon_state = "flushed_cheeks"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/cyclops
	name = "Cyclopean Eye"
	icon_state = "cyclops"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/blank_face
	name = "Blank round face (use with monster mouth)"
	icon_state = "blankface"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/blank_face2
	name = "Blank Round Face, Alt"
	icon_state = "blankface2"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/monster_mouth
	name = "Monster Mouth"
	icon_state = "monster"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/monster_mouth2
	name = "Monster Mouth (White)"
	icon_state = "pilot_jaw"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/monster_mouth3
	name = "Monster Mouth (White, eye-compatible)"
	icon_state = "monster2"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/nose_blemish
	name = "Nose Blemish"
	icon_state = "nose_blemish"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/brows
	name = "Brows"
	icon_state = "brows"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/ears
	name = "Ears"
	icon_state = "ears"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/eyeliner
	name = "Eyeliner"
	icon_state = "eyeliner"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/topscars
	name = "Top Surgery Scars"
	icon_state = "topscars"
	body_zones = CHEST
	gender_specific = TRUE

/datum/sprite_accessory/body_marking/other/weight
	name = "Body Weight"
	icon_state = "weight"
	body_zones = CHEST
	gender_specific = TRUE

/datum/sprite_accessory/body_marking/other/weight2
	name = "Body Weight (Greyscale)"
	icon_state = "weight2"
	body_zones = CHEST
	gender_specific = TRUE

/datum/sprite_accessory/body_marking/other/pilot
	name = "Pilot"
	icon_state = "pilot"
	body_zones = HEAD | ARM_LEFT | ARM_RIGHT

/datum/sprite_accessory/body_marking/other/pilot_hand
	name = "Pilot Hand"
	icon_state = "pilot_hand"
	body_zones = HAND_LEFT | HAND_RIGHT

/datum/sprite_accessory/body_marking/other/big_ol_eyes
	name = "Large Eyes"
	icon_state = "bigoleyes"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/three_eyes
	name = "Three Eyes"
	icon_state = "3eyes"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/four_eyes
	name = "Four Eyes"
	icon_state = "4eyes"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/claws
	name = "Claw Tips"
	icon_state = "claws"
	gender_specific = FALSE
	body_zones = HAND_LEFT | HAND_RIGHT

/datum/sprite_accessory/body_marking/other/bands
	name = "Color Bands"
	icon_state = "bands"
	body_zones = CHEST | ARM_LEFT | ARM_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/bands_foot
	name = "Color Bands (Foot)"
	icon_state = "bands_foot"
	body_zones = LEG_RIGHT | LEG_LEFT


/datum/sprite_accessory/body_marking/other/bands_hand
	name = "Color Bands (Hand)"
	icon_state = "bands_hand"
	body_zones = HAND_RIGHT | HAND_LEFT

/datum/sprite_accessory/body_marking/other/anklet
	name = "Anklet"
	icon_state = "anklet"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/legband
	name = "Leg Band"
	icon_state = "legband"
	body_zones = LEG_RIGHT | LEG_LEFT
