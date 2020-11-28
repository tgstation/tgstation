/datum/sprite_accessory/wings
	icon = 'icons/mob/clothing/wings.dmi'
	generic = "Wings"
	key = "wings"
	color_src = USE_ONE_COLOR
	recommended_species = list("human", "felinid", "lizard", "mammal")
	organ_type = /obj/item/organ/wings
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER, BODY_ADJ_LAYER)

/datum/sprite_accessory/wings/none
	name = "None"
	icon_state = "none"
	factual = FALSE

/datum/sprite_accessory/wings/angel
	color_src = USE_ONE_COLOR
	default_color = "FFF"

/datum/sprite_accessory/wings/megamoth
	color_src = USE_ONE_COLOR
	default_color = "FFF"

/datum/sprite_accessory/wings/dragon
	color_src = USE_ONE_COLOR

//TODO: seperate moth wings from moth fluff
/datum/sprite_accessory/wings/moth
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/moth_wings.dmi' //Needs new icon to suit new naming convention
	default_color = "FFF"
	recommended_species = list("moth", "mammal", "insect") //Mammals too, I guess. They wont get flight though, see the wing organs for that logic
	organ_type = /obj/item/organ/wings/moth
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/moth/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/wings/moth/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/wings/moth/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/wings/moth/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/wings/moth/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/wings/moth/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/wings/moth/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/wings/moth/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/wings/moth/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/wings/moth/punished
	name = "Burnt Off"
	icon_state = "punished"
	locked = TRUE

/datum/sprite_accessory/wings/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/wings/moth/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/wings/moth/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/wings/moth/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/wings/moth/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/wings/moth/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/wings/moth/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/sprite_accessory/wings/moth/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/sprite_accessory/wings/moth/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/wings/mammal
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/wings.dmi'
	default_color = DEFAULT_PRIMARY
	recommended_species = list("mammal", "lizard")
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/wings/mammal/bat //TODO: port my sprite from hyper for this one
	name = "Bat"
	icon_state = "bat"

/datum/sprite_accessory/wings/mammal/fairy
	name = "Fairy"
	icon_state = "fairy"

/datum/sprite_accessory/wings/mammal/feathery
	name = "Feathery"
	icon_state = "feathery"

/datum/sprite_accessory/wings/mammal/bee
	name = "Bee"
	icon_state = "bee"
