/datum/sprite_accessory/taur
	icon = 'modular_skyrat/modules/customization/icons/mob/sprite_accessory/taur.dmi'
	key = "taur"
	generic = "Taur Type"
	color_src = USE_MATRIXED_COLORS
	dimension_x = 64
	center = TRUE
	relevent_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/taur_mode = NONE //Must be a single specific tauric suit variation bitflag. Don't do FLAG_1|FLAG_2
	var/alt_taur_mode = NONE //Same as above.
	var/hide_legs = TRUE
	var/hide_markings = FALSE //Any taur part that has "legs" should not hide markings

/datum/sprite_accessory/taur/is_hidden(mob/living/carbon/human/H, obj/item/bodypart/HD)
	if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	return FALSE

/datum/sprite_accessory/taur/none
	name = "None"
	dimension_x = 32
	center = FALSE
	hide_legs = FALSE
	factual = FALSE
	color_src = null

/datum/sprite_accessory/taur/cow
	name = "Cow"
	icon_state = "cow"
	taur_mode = STYLE_TAUR_HOOF
	alt_taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR

/datum/sprite_accessory/taur/cow/spotted
	name = "Cow (Spotted)"
	icon_state = "cow_spotted"
	color_src = USE_MATRIXED_COLORS

/datum/sprite_accessory/taur/deer
	name = "Deer"
	icon_state = "deer"
	taur_mode = STYLE_TAUR_HOOF
	alt_taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2

/datum/sprite_accessory/taur/drake
	name = "Drake"
	icon_state = "drake"
	taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2

/datum/sprite_accessory/taur/drake/old
	name = "Drake (Old)"
	icon_state = "drake_old"
	color_src = USE_MATRIXED_COLORS
	extra = FALSE

/datum/sprite_accessory/taur/drider
	name = "Drider"
	icon_state = "drider"
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2

/datum/sprite_accessory/taur/eevee
	name = "Eevee"
	icon_state = "eevee"
	taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2

/datum/sprite_accessory/taur/horse
	name = "Horse"
	icon_state = "horse"
	taur_mode = STYLE_TAUR_HOOF
	alt_taur_mode = STYLE_TAUR_PAW

/datum/sprite_accessory/taur/naga
	name = "Naga"
	icon_state = "naga"
	taur_mode = STYLE_TAUR_SNAKE
	hide_legs = TRUE

/datum/sprite_accessory/taur/otie
	name = "Otie"
	icon_state = "otie"
	taur_mode = STYLE_TAUR_PAW

/datum/sprite_accessory/taur/pede
	name = "Scolipede"
	icon_state = "pede"
	taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra2 = TRUE
	extra_color_src = MUTCOLORS2
	extra2_color_src = MUTCOLORS3

/datum/sprite_accessory/taur/tentacle
	name = "Tentacle"
	icon_state = "tentacle"
	taur_mode = STYLE_TAUR_SNAKE
	color_src = USE_ONE_COLOR
	hide_legs = TRUE

/datum/sprite_accessory/taur/canine
	name = "Canine"
	icon_state = "canine"
	taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2

/datum/sprite_accessory/taur/feline
	name = "Feline"
	icon_state = "feline"
	taur_mode = STYLE_TAUR_PAW
	color_src = USE_ONE_COLOR
	extra = TRUE
	extra_color_src = MUTCOLORS2
