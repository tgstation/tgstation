/datum/sprite_accessory/body_marking
	color_src = "#CCCCCC"
	name = SPRITE_ACCESSORY_NONE
	icon_state = SPRITE_ACCESSORY_NONE
	gender_specific = TRUE
	var/body_zones

/datum/sprite_accessory/body_marking/other
	icon = 'modular_doppler/modular_customization/markings/icons/markings/other_markings.dmi'

/datum/sprite_accessory/body_marking/other/drake_bone
	name = "Drake Bone"
	icon_state = "drakebone"
	body_zones = CHEST | HAND_LEFT | HAND_RIGHT
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/tonage
	name = "Body Tonage"
	icon_state = "tonage"
	color_src = "#555555"
	body_zones = CHEST
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/belly_slim_toned
	name = "Belly Slim (Alt) + Tonage"
	icon_state = "bellyslimtoned"
	color_src = "#555555"
	body_zones = CHEST
	gender_specific = FALSE

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
	icon_state = "monster2"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/monster_mouth3
	name = "Monster Mouth (White, eye-compatible)"
	icon_state = "monster3"
	body_zones = HEAD
//you're welcome -- iska

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

/datum/sprite_accessory/body_marking/other/insect_antennae
	name = "Insect Antennae"
	icon_state = "insect_antennae"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/eyeliner
	name = "Eyeliner"
	icon_state = "eyeliner"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/topscars
	name = "Top Surgery Scars"
	icon_state = "topscars"
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/weight
	name = "Body Weight"
	icon_state = "weight"
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/weight2
	name = "Body Weight (Greyscale)"
	icon_state = "weight2"
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/pilot
	name = "Pilot"
	icon_state = "pilot"
	body_zones = HEAD | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT

/datum/sprite_accessory/body_marking/other/pilot_jaw
	name = "Pilot Jaw"
	icon_state = "pilot_jaw"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/drake_eyes
	name = "Drake Eyes"
	icon_state = "drakeeyes"
	color_src = "#FF0000"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/big_ol_eyes
	name = "Large Eyes"
	icon_state = "bigoleyes"
	color_src = "#FF0000"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/three_eyes
	name = "Three Eyes"
	icon_state = "3eyes"
	color_src = "#FF0000"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/four_eyes
	name = "Four Eyes"
	icon_state = "4eyes"
	color_src = "#FF0000"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/claws
	name = "Claw Tips"
	icon_state = "claws"
	body_zones = HAND_LEFT | HAND_RIGHT
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/splotches
	name = "Splotches"
	icon_state = "splotches"
	body_zones = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/splotcheswap
	name = "Splotches Swapped"
	icon_state = "splotcheswap"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/bands
	name = "Color Bands"
	icon_state = "bands"
	body_zones = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/chitin
	name = "Chitin"
	icon_state = "chitin"
	body_zones = CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/bands_foot
	name = "Color Bands (Foot)"
	icon_state = "bands_foot"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/anklet
	name = "Anklet"
	icon_state = "anklet"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/legband
	name = "Leg Band"
	icon_state = "legband"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/protogenlegs
	name = "Protogen Leg - Digitigrade"
	icon_state = "protogen"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/protogenarms
	name = "Protogen Arm"
	icon_state = "protogen"
	body_zones = ARM_RIGHT | ARM_LEFT

/datum/sprite_accessory/body_marking/other/protogenchest
	name = "Protogen Chest"
	icon_state = "protogen"
	body_zones = CHEST

/datum/sprite_accessory/body_marking/other/jackal_fur
	name = "Jackal Back Fur"
	icon_state = "jackalfur"
	body_zones = CHEST | ARM_RIGHT | ARM_LEFT
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/jackal_back
	name = "Jackal Back Fur Accents"
	icon_state = "jackalback"
	body_zones = CHEST | ARM_RIGHT | ARM_LEFT
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/sixnips
	name = "Six Nips"
	icon_state = "nips"
	body_zones = CHEST
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/outer_eye
	name = "Outer Eye"
	icon_state = "outereye"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/undereye
	name = "Undereye"
	icon_state = "undereye"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/shard_thigh
	name = "Shard Alpha Thigh Plate"
	icon_state = "shard_thigh"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/shard_calf
	name = "Shard Alpha Calf Plate"
	icon_state = "shard_calves"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/shard_claw
	name = "Shard Alpha Claws"
	icon_state = "shard_claw"
	body_zones = LEG_RIGHT | LEG_LEFT

/datum/sprite_accessory/body_marking/other/polytronic
	name = "Polytronic Modular Doll limbs"
	icon_state = "polytronic"
	body_zones = HEAD | CHEST | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_RIGHT | LEG_LEFT
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/polytronic_hair
	name = "Polytronic Hair Helmet"
	icon_state = "polytronic_hair"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/polytronic_headwear
	name = "Polytronic Headwear"
	icon_state = "polytronic_headwear"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/chelsea_smile
	name = "Chelsea Smile"
	icon_state = "chelsea_smile"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/eye_scar_l
	name = "Eye Scar (L)"
	icon_state = "eye_scar_left"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/eye_scar_r
	name = "Eye Scar (R)"
	icon_state = "eye_scar_right"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/nose_scar
	name = "Nose Scar"
	icon_state = "nose_scar"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/battleslayer_l
	name = "Battleslayer Scar (L)"
	icon_state = "battleslayer_left"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/battleslayer_r
	name = "Battleslayer Scar (R)"
	icon_state = "battleslayer_right"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/scarified
	name = "Scarified"
	icon_state = "scarified"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/messed_up
	name = "Messed Up Scars"
	icon_state = "messed_up"
	body_zones = HEAD

/datum/sprite_accessory/body_marking/other/the_stampede
	name = "The Stampede Scars"
	icon_state = "the_stampede"
	body_zones = CHEST
	gender_specific = FALSE

/datum/sprite_accessory/body_marking/other/chestplate
	name = "Chest Plate"
	icon_state = "chestplate"
	body_zones = CHEST
	gender_specific = FALSE
