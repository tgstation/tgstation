/datum/sprite_accessory/ears
	key = "ears"
	generic = "Ears"
	organ_type = /obj/item/organ/ears/mutant
	relevent_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/ears/is_hidden(mob/living/carbon/human/H, obj/item/bodypart/HD)
	if(H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !HD || HD.status == BODYPART_ROBOTIC)
		return TRUE
	return FALSE


/datum/sprite_accessory/ears/cat
	recommended_species = list("mammal", "human", "felinid", "humanoid")
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/ears/mutant
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/ears.dmi'
	organ_type = /obj/item/organ/ears/mutant
	color_src = USE_MATRIXED_COLORS
	recommended_species = list("mammal", "human", "felinid", "humanoid")

/datum/sprite_accessory/ears/mutant/none
	name = "None"
	icon_state = "none"
	color_src = null
	factual = FALSE

/datum/sprite_accessory/ears/mutant/vulpkanin
	recommended_species = list("mammal", "human", "felinid", "vulpkanin", "humanoid")

/datum/sprite_accessory/ears/mutant/tajaran
	recommended_species = list("mammal", "human", "felinid", "tajaran", "humanoid")

/datum/sprite_accessory/ears/mutant/akula
	recommended_species = list("mammal", "human", "felinid", "aquatic", "akula", "humanoid")

/datum/sprite_accessory/ears/mutant/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/bat
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/ears/mutant/bear
	name = "Bear"
	icon_state = "bear"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/bigwolf
	name = "Big Wolf"
	icon_state = "bigwolf"

/datum/sprite_accessory/ears/mutant/bigwolfinner
	name = "Big Wolf (ALT)"
	icon_state = "bigwolfinner"
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/mutant/bigwolfdark //alphabetical sort ignored here for ease-of-use
	name = "Dark Big Wolf"
	icon_state = "bigwolfdark"

/datum/sprite_accessory/ears/mutant/bigwolfinnerdark
	name = "Dark Big Wolf (ALT)"
	icon_state = "bigwolfinnerdark"
	extra = TRUE
	extra_color_src = NONE

/datum/sprite_accessory/ears/mutant/bunny
	name = "Bunny"
	icon_state = "bunny"

/datum/sprite_accessory/ears/mutant/tajaran/catbig
	name = "Cat, Big"
	icon_state = "catbig"

/datum/sprite_accessory/ears/mutant/tajaran/catnormal
	name = "Cat, normal"
	icon_state = "catnormal"

/datum/sprite_accessory/ears/mutant/cow
	name = "Cow"
	icon_state = "cow"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/curled
	name = "Curled Horn"
	icon_state = "horn1"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_TERTIARY

/datum/sprite_accessory/ears/mutant/deer
	name = "Deer"
	icon_state = "deer"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_TERTIARY

/datum/sprite_accessory/ears/mutant/eevee
	name = "Eevee"
	icon_state = "eevee"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/elf
	name = "Elf"
	icon_state = "elf"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_SKIN_OR_PRIMARY

/datum/sprite_accessory/ears/mutant/elephant
	name = "Elephant"
	icon_state = "elephant"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/fennec
	name = "Fennec"
	icon_state = "fennec"

/datum/sprite_accessory/ears/mutant/fish
	name = "Fish"
	icon_state = "fish"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/vulpkanin/fox
	name = "Fox"
	icon_state = "fox"

/datum/sprite_accessory/ears/mutant/husky
	name = "Husky"
	icon_state = "wolf"

/datum/sprite_accessory/ears/mutant/jellyfish
	name = "Jellyfish"
	icon_state = "jellyfish"
	color_src = HAIR

/datum/sprite_accessory/ears/mutant/kangaroo
	name = "Kangaroo"
	icon_state = "kangaroo"

/datum/sprite_accessory/ears/mutant/lab
	name = "Dog, Long"
	icon_state = "lab"
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/ears/mutant/murid
	name = "Murid"
	icon_state = "murid"

/datum/sprite_accessory/ears/mutant/vulpkanin/otie
	name = "Otusian"
	icon_state = "otie"

/datum/sprite_accessory/ears/mutant/rabbit
	name = "Rabbit"
	icon_state = "rabbit"

/datum/sprite_accessory/ears/mutant/pede
	name = "Scolipede"
	icon_state = "pede"

/datum/sprite_accessory/ears/mutant/akula/sergal
	name = "Sergal"
	icon_state = "sergal"

/datum/sprite_accessory/ears/mutant/skunk
	name = "skunk"
	icon_state = "skunk"

/datum/sprite_accessory/ears/mutant/squirrel
	name = "Squirrel"
	icon_state = "squirrel"

/datum/sprite_accessory/ears/mutant/vulpkanin/wolf
	name = "Wolf"
	icon_state = "wolf"

/datum/sprite_accessory/ears/mutant/vulpkanin/perky
	name = "Perky"
	icon_state = "perky"

/datum/sprite_accessory/ears/mutant/antenna_simple1
	name = "Insect antenna (coloring 2)"
	icon_state = "antenna_simple1"

/datum/sprite_accessory/ears/mutant/antenna_simple1_v2
	name = "Insect antenna (coloring 3)"
	icon_state = "antenna_simple1v2"

/datum/sprite_accessory/ears/mutant/antenna_simple2
	name = "Insect antenna 2 (coloring 2)"
	icon_state = "antenna_simple2"

/datum/sprite_accessory/ears/mutant/antenna_simple2_v2
	name = "Insect antenna 2 (coloring 3)"
	icon_state = "antenna_simple2v2"

/datum/sprite_accessory/ears/mutant/antenna_fuzzball
	name = "Fuzzball antenna (coloring 2+3)"
	icon_state = "antenna_fuzzball"

/datum/sprite_accessory/ears/mutant/antenna_fuzzball_v2
	name = "Fuzzball antenna (coloring 3+1)"
	icon_state = "antenna_fuzzballv2"

/datum/sprite_accessory/ears/mutant/cobrahood
	name = "Cobra Hood"
	icon_state = "cobrahood"

/datum/sprite_accessory/ears/mutant/cobrahoodears
	name = "Cobra Hood (Ears)"
	icon_state = "cobraears"
