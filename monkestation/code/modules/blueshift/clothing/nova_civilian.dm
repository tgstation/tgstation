/obj/item/clothing/under/rank/civilian
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/civilian_digi.dmi'

/obj/item/clothing/under/rank/civilian/lawyer // Lawyers' suits are in TG's suits.dmi
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/suits_digi.dmi'

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit // EXCEPT THIS ONE.
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/buttondown_slacks/worn/digi

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/civilian.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/civilian.dmi'
	can_adjust = FALSE //Just gonna set it to default for ease

//TG's files separate this into Civilian, Clown/Mime, and Curator. We wont have as many, so all Service goes into this file.
//DO NOT ADD A /obj/item/clothing/under/rank/civilian/lawyer/nova. USE /obj/item/clothing/under/suit/nova FOR MODULAR SUITS (civilian/suits.dm).

/*
*	HEAD OF PERSONNEL
*/

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/imperial //Rank pins of the Grand Moff
	name = "head of personnel's naval jumpsuit"
	desc = "A pale green naval suit and a rank badge denoting the Personnel Officer. Target, maximum firepower."
	icon_state = "imphop"
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade
	name = "head of personnel's male formal uniform"
	desc = "A luxurious uniform for the head of personnel, woven in a deep blue. On the lapel is a small pin in the shape of a corgi's head."
	icon_state = "hop_parade_male"

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade/female
	name = "head of personnel's female formal uniform"
	icon_state = "hop_parade_female"

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck
	name = "head of personnel's turtleneck"
	desc = "A soft blue turtleneck and black khakis worn by Executives who prefer a bit more comfort over style."
	icon_state = "hopturtle"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck/skirt
	name = "head of personnel's turtleneck skirt"
	desc = "A soft blue turtleneck and black skirt worn by Executives who prefer a bit more comfort over style."
	icon_state = "hopturtle_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY


/obj/item/clothing/under/suit
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/suits_digi.dmi'

/obj/item/clothing/under/suit/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/suits.dmi'

//DO NOT ADD A /obj/item/clothing/under/rank/civilian/lawyer/nova. USE /obj/item/clothing/under/suit/nova FOR MODULAR SUITS

/*
*	RECOLORABLE
*/
/obj/item/clothing/under/suit/nova/recolorable
	name = "recolorable suit"
	desc = "A semi-formal suit, clean-cut with a matching vest and slacks."
	icon_state = "recolorable_suit"
	can_adjust = FALSE
	greyscale_config = /datum/greyscale_config/recolorable_suit
	greyscale_config_worn = /datum/greyscale_config/recolorable_suit/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/recolorable_suit/worn/digi
	greyscale_colors = "#a99780#ffffff#6e2727#ffc500"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/suit/nova/recolorable/skirt
	name = "recolorable suitskirt"
	desc = "A semi-formal suitskirt, clean-cut with a matching vest and skirt."
	icon_state = "recolorable_suitskirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

	body_parts_covered = CHEST|GROIN|LEGS
	greyscale_config = /datum/greyscale_config/recolorable_suitskirt
	greyscale_config_worn = /datum/greyscale_config/recolorable_suitskirt/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/recolorable_suitskirt/worn/digi

/obj/item/clothing/under/suit/nova/recolorable/casual
	name = "office casual suit"
	desc = "A semi-formal suit, clean-cut with a matching vest and slacks."
	icon_state = "fancysuit_casual"
	greyscale_config = /datum/greyscale_config/fancysuit_casual
	greyscale_config_worn = /datum/greyscale_config/fancysuit_casual/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/fancysuit_casual/worn/digi
	greyscale_colors = "#37373e#ffffff"

/obj/item/clothing/under/suit/nova/recolorable/executive
	name = "executive casual suit"
	desc = "A formal suit, clean-cut with a matching vest, undershirt, tie and slacks."
	icon_state = "fancysuit_executive"
	greyscale_config = /datum/greyscale_config/fancysuit_executive
	greyscale_config_worn = /datum/greyscale_config/fancysuit_executive/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/fancysuit_executive/worn/digi
	greyscale_colors = "#37373e#37373e#ffffff#ac3232"

/obj/item/clothing/under/suit/nova/pencil
	name = "pencilskirt and shirt"
	desc = "A clean shirt with a tight-fitting pencilskirt."
	icon_state = "pencilskirt_shirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

	greyscale_colors = "#37373e#ffffff"
	greyscale_config = /datum/greyscale_config/pencilskirt_withshirt
	greyscale_config_worn = /datum/greyscale_config/pencilskirt_withshirt/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/pencilskirt_withshirt/worn/digi
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/suit/nova/pencil/noshirt
	name = "pencilskirt"
	desc = "A tight-fitting pencilskirt, perfect to augment an undershirt."
	icon_state = "pencilskirt"
	greyscale_colors = "#37373e"
	greyscale_config = /datum/greyscale_config/pencilskirt
	greyscale_config_worn = /datum/greyscale_config/pencilskirt/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/pencilskirt/worn/digi
	body_parts_covered = GROIN|LEGS

/obj/item/clothing/under/suit/nova/pencil/charcoal
	name = "charcoal pencilskirt"
	desc = "A clean white shirt with a tight-fitting charcoal pencilskirt."
	greyscale_colors = "#303030#ffffff"

/obj/item/clothing/under/suit/nova/pencil/navy
	name = "navy pencilskirt"
	desc = "A clean white shirt with a tight-fitting navy-blue pencilskirt."
	greyscale_colors = "#112334#ffffff"

/obj/item/clothing/under/suit/nova/pencil/burgandy
	name = "burgandy pencilskirt"
	desc = "A clean white shirt with a tight-fitting burgandy-red pencilskirt."
	greyscale_colors = "#3e1111#ffffff"

/obj/item/clothing/under/suit/nova/pencil/tan
	name = "tan pencilskirt"
	desc = "A clean white shirt with a tight-fitting tan pencilskirt."
	greyscale_colors = "#8b7458#ffffff"

/obj/item/clothing/under/suit/nova/pencil/green
	name = "green pencilskirt"
	desc = "A clean white shirt with a tight-fitting green pencilskirt."
	greyscale_colors = "#113e20#ffffff"

/obj/item/clothing/under/suit/nova/pencil/black_really
	name = "executive pencilskirt"
	desc = "A sleek suit with a tight-fitting pencilskirt."
	icon_state = "pencilskirt_suit"
	greyscale_colors = "#37373e#37373e#ffffff#ac3232"
	greyscale_config = /datum/greyscale_config/pencilskirt_withsuit
	greyscale_config_worn = /datum/greyscale_config/pencilskirt_withsuit/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/pencilskirt_withsuit/worn/digi

/obj/item/clothing/under/suit/nova/pencil/checkered
	name = "checkered pencilskirt and shirt"
	desc = "A clean shirt with a tight-fitting checkered pencilskirt."
	icon_state = "pencilskirt_checkers_shirt"
	greyscale_colors = "#37373e#232323#ffffff"
	greyscale_config = /datum/greyscale_config/pencilskirt_checkers_withshirt
	greyscale_config_worn = /datum/greyscale_config/pencilskirt_checkers_withshirt/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/pencilskirt_checkers_withshirt/worn/digi

/obj/item/clothing/under/suit/nova/pencil/checkered/noshirt
	name = "checkered pencilskirt"
	desc = "A tight-fitting checkered pencilskirt."
	icon_state = "pencilskirt_checkers"
	greyscale_colors = "#37373e#232323"
	greyscale_config = /datum/greyscale_config/pencilskirt_checkers
	greyscale_config_worn = /datum/greyscale_config/pencilskirt_checkers/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/pencilskirt_checkers/worn/digi
	body_parts_covered = GROIN|LEGS

/*
*	STATIC SUITS (NO GAGS)
*/
/obj/item/clothing/under/suit/nova/scarface
	name = "cuban suit"
	desc = "A yayo coloured silk suit with a crimson shirt. You just know how to hide, how to lie. Me, I don't have that problem. Me, I always tell the truth. Even when I lie."
	icon_state = "scarface"

/obj/item/clothing/under/suit/nova/black_really_collared
	name = "wide-collared executive suit"
	desc = "A formal black suit with the collar worn wide, intended for the station's finest."
	icon_state = "really_black_suit_collar"

/obj/item/clothing/under/suit/nova/black_really_collared/skirt
	name = "wide-collared executive suitskirt"
	desc = "A formal black suit with the collar worn wide, intended for the station's finest."
	icon_state = "really_black_suit_skirt_collar"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY|FEMALE_UNIFORM_NO_BREASTS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/under/suit/nova/inferno
	name = "inferno suit"
	desc = "Stylish enough to impress the devil."
	icon_state = "lucifer"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Pride" = "lucifer",
		"Wrath" = "justice",
		"Gluttony" = "malina",
		"Envy" = "zdara",
		"Vanity" = "cereberus",
	)

/obj/item/clothing/under/suit/nova/inferno/skirt
	name = "inferno suitskirt"
	icon_state = "modeus"
	obj_flags = UNIQUE_RENAME
	unique_reskin = list(
		"Lust" = "modeus",
		"Sloth" = "pande",
	)

/obj/item/clothing/under/suit/nova/inferno/beeze
	name = "designer inferno suit"
	desc = "A fancy tail-coated suit with a fluffy bow emblazoned on the chest, complete with an NT pin."
	icon_state = "beeze"
	obj_flags = null
	unique_reskin = null

/obj/item/clothing/under/suit/nova/helltaker
	name = "red shirt with white pants"
	desc = "No time. Busy gathering girls."
	icon_state = "helltaker"

/obj/item/clothing/under/suit/nova/helltaker/skirt
	name = "red shirt with white skirt"
	desc = "No time. Busy gathering boys."
	icon_state = "helltakerskirt"
