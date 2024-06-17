/obj/item/clothing/under/rank/centcom
	icon = 'icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentCom commander's suit"
	desc = "It's a luxurious suit worn by CentCom's highest-tier Commanders, with features made of gold alloyed with plasteel."
	icon_state = "centcom"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/commander/skirt
	name = "\improper CentCom commander's suitskirt"
	desc = "It's a luxurious suit with an added skirt worn by CentCom's highest-tier Commanders, with features made of gold alloyed with plasteel."
	icon_state = "centcom_skirt"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/official
	name = "\improper CentCom official's suit"
	desc = "A fancy suit worn by CentCom's Officials, usually Inspectors. The belt buckle gleams in the light indicating stature."
	icon_state = "official"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/official/turtleneck
	name = "\improper CentCom official's turtleneck"
	desc = "A snazzy green turtleneck worn by CentCom Officials, atop of suit pants. It has a fragrance of aloe."
	icon_state = "official_turtleneck"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/officer/commander
	name = "\improper CentCom commander's tactical turtleneck"
	desc = "A snazzy green turtleneck worn by CentCom ERT Commanders, worn with combat trousers and a silver buckle and added silver markings. It has a fragrance of aloe."
	icon_state = "commander"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/officer/commander/skirt
	name = "\improper CentCom commander's tactical skirtleneck"
	desc = "A snazzy green skirtleneck worn by CentCom ERT Commanders, worn with combat trousers and a silver buckle and added silver markings. It has a fragrance of aloe."
	icon_state = "commander_skirt"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper CentCom tactical turtleneck"
	desc = "A snazzy green turtleneck worn by CentCom ERT Officers, worn with combat trousers and a silver buckle. It has a fragrance of aloe."
	icon_state = "officer"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/officer/skirt
	name = "\improper CentCom tactical skirtleneck"
	desc = "A snazzy green skirtleneck worn by CentCom ERT Officers, worn with combat trousers and a silver buckle. It has a fragrance of aloe."
	icon_state = "officer_skirt"
	inhand_icon_state = "dg_suit"
	alt_covers_chest = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/centcom/intern
	name = "\improper CentCom intern's uniform"
	desc = "A bland uniform worn by CentCom's interning personnel, a generic green polo shirt makes it easy to realize they aren't that special."
	icon_state = "intern"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/centcom/intern/head
	name = "\improper CentCom head intern's uniform"
	desc = "A bland uniform worn by CentCom's lead interning personnel, a generic green polo shirt with some added pants, surely an upgrade from shorts."
	icon_state = "head_intern"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/centcom/officer/replica
	name = "\improper CentCom turtleneck replica"
	desc = "A cheap copy of the CentCom turtleneck! A Donk Co. logo can be seen on the collar."
	icon_state = "fakecent"

/obj/item/clothing/under/rank/centcom/officer/skirt/replica
	name = "\improper CentCom skirtleneck replica"
	desc = "A cheap copy of the CentCom turtleneck skirt! A Donk Co. logo can be seen on the collar."
	icon_state = "fakecent_skirt"

/obj/item/clothing/under/rank/centcom/military
	name = "tactical combat uniform"
	desc = "A dark colored uniform worn by CentCom's conscripted military forces."
	icon_state = "military"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE
	armor_type = /datum/armor/clothing_under/centcom_military

/datum/armor/clothing_under/centcom_military
	melee = 10
	fire = 50
	acid = 40
	wound = 10

/obj/item/clothing/under/rank/centcom/military/eng
	name = "tactical engineering uniform"
	desc = "A dark colored uniform worn by CentCom's regular military engineers."
	icon_state = "military_eng"
