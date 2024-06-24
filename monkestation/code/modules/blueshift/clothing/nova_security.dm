/obj/item/clothing/under/rank/security
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security_digi.dmi'

/obj/item/clothing/under/rank/security/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'

/obj/item/clothing/under/rank/security/head_of_security/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'

//DEBATE MOVING *ALL* SECURITY STUFF HERE? Even overrides, at least as a like, sub-file?

/*
*	SECURITY OFFICER
*/

/obj/item/clothing/under/rank/security/nova/utility
	name = "security utility uniform"
	desc = "A utility uniform worn by Lopland-certified Security officers."
	icon_state = "util_sec"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/nova/utility/redsec
	desc = "A utility uniform worn by trained Security officers."
	icon_state = "util_sec_old"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/nova/utility/redsec/syndicate
	armor_type = /datum/armor/clothing_under/redsec_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/security/peacekeeper/dress
	name = "security battle dress"
	desc = "An asymmetrical, unisex uniform with the legs replaced by a utility skirt."
	worn_icon_state = "security_skirt"
	icon_state = "security_skirt"
	uses_advanced_reskins = FALSE
	unique_reskin = null
	alt_covers_chest = FALSE

/obj/item/clothing/under/rank/security/peacekeeper/trousers
	name = "security trousers"
	desc = "Some Peacekeeper-blue combat trousers. Probably should pair it with a vest for safety."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	icon_state = "workpants_blue"
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Blue Variant" = list(
			RESKIN_ICON_STATE = "workpants_blue",
			RESKIN_WORN_ICON_STATE = "workpants_blue"
		),
		"White Variant" = list(
			RESKIN_ICON_STATE = "workpants_white",
			RESKIN_WORN_ICON_STATE = "workpants_white"
		),
	)

/obj/item/clothing/under/rank/security/peacekeeper/trousers/shorts
	name = "security shorts"
	desc = "Some Peacekeeper-blue combat shorts. Definitely should pair it with a vest for safety."
	icon_state = "workshorts_blue"
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Blue Variant, Short" = list(
			RESKIN_ICON_STATE = "workshorts_blue",
			RESKIN_WORN_ICON_STATE = "workshorts_blue"
		),
		"Blue Variant, Short Short" = list(
			RESKIN_ICON_STATE = "workshorts_blue_short",
			RESKIN_WORN_ICON_STATE = "workshorts_blue_short"
		),
		"White Variant, Short" = list(
			RESKIN_ICON_STATE = "workshorts_white",
			RESKIN_WORN_ICON_STATE = "workshorts_white"
		),
		"White Variant, Short Short" = list(
			RESKIN_ICON_STATE = "workshorts_white_short",
			RESKIN_WORN_ICON_STATE = "workshorts_white_short"
		),
	)

/obj/item/clothing/under/rank/security/peacekeeper/jumpsuit
	name = "security jumpsuit"
	desc = "Turtleneck sweater commonly worn by Peacekeepers, attached with pants."
	icon_state = "jumpsuit_blue"
	can_adjust = TRUE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/rank/security/peacekeeper/plain_skirt
	name = "security plain skirt"
	desc = "Plain-shirted uniform commonly worn by Peacekeepers, attached with a skirt."
	icon_state = "plain_skirt_blue"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Blue Variant" = list(
			RESKIN_ICON_STATE = "plain_skirt_blue",
			RESKIN_WORN_ICON_STATE = "plain_skirt_blue"
	    ),
		"Black Variant" = list(
			RESKIN_ICON_STATE = "plain_skirt_black",
			RESKIN_WORN_ICON_STATE = "plain_skirt_black"
	    ),
	)

/obj/item/clothing/under/rank/security/peacekeeper/miniskirt
	name = "security miniskirt"
	desc = "This miniskirt was originally featured in a gag calendar, but entered official use once they realized its potential for arid climates."
	icon_state = "miniskirt_blue"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Blue Variant" = list(
			RESKIN_ICON_STATE = "miniskirt_blue",
			RESKIN_WORN_ICON_STATE = "miniskirt_blue"
	    ),
		"Black Variant" = list(
			RESKIN_ICON_STATE = "miniskirt_black",
			RESKIN_WORN_ICON_STATE = "miniskirt_black"
	    ),
	)

/*
*	HEAD OF SECURITY
*/

/datum/armor/clothing_under/redsec_syndicate
	melee = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/rank/security/head_of_security/nova/imperial //Rank pins of the Grand General
	desc = "A tar black naval suit and a rank badge denoting the Officer of The Internal Security Division. Be careful your underlings don't bump their head on a door."
	name = "head of security's naval jumpsuit"
	icon_state = "imphos"

/obj/item/clothing/head/beret/sec/peacekeeper
	name = "peacekeeper beret"
	desc = "A robust beret with the peacekeeper insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	icon_state = "beret_badge"
	greyscale_colors = "#3F3C40#375989"
	armor_type = /datum/armor/head_helmet

/obj/item/clothing/head/beret/sec/peacekeeper/white
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	icon_state = "beret"
	greyscale_colors = "#EAEAEA"

/obj/item/clothing/head/hats/hos/beret/peacekeeper
	name = "head of security's peacekeeper beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	armor_type = /datum/armor/hats_hos

/obj/item/clothing/head/beret/sec/navywarden/peacekeeper
	name = "warden's peacekeeper beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	greyscale_config = /datum/greyscale_config/beret_badge_fancy
	greyscale_config_worn = /datum/greyscale_config/beret_badge_fancy/worn
	greyscale_colors = "#3f6e9e#FF0000#00AEEF"
	icon_state = "beret_badge_fancy_twist"
	armor_type = /datum/armor/hats_warden

/obj/item/clothing/head/helmet/sec/sol
	name = "sol police helmet"
	desc = "A helmet to protect any officer from bludgeoning attacks, or the occasional bullet."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/helmet.dmi'
	icon_state = "security_helmet_novisor"
	base_icon_state = "security_helmet_novisor"
	actions_types = NONE
	armor_type = /datum/armor/head_helmet

/obj/item/clothing/head/hats/warden/police/patrol
	name = "police patrol cap"
	desc = "A dark colored hat with a silver badge, for the officer interested in style."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "policeofficerpatrolcap"
	armor_type = /datum/armor/head_helmet
	unique_reskin = list(
		"Blue" = "policeofficercap",
		"Sillitoe" = "policetrafficcap",
		"Black" = "policeofficerpatrolcap",
		"Cadet" = "policecadetcap",
	)

/obj/item/clothing/glasses/hud/security/sunglasses/peacekeeper
	name = "peacekeeper hud glasses"
	icon_state = "peacekeeperglasses"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/eyes.dmi'
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/glasses.dmi'

//PEACEKEEPER UNIFORM
/obj/item/clothing/under/rank/security/peacekeeper
	name = "peacekeeper uniform"
	desc = "A sleek peacekeeper uniform, made to a price."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	icon_state = "peacekeeper"
	can_adjust = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/warden/peacekeeper
	name = "peacekeeper wardens suit"
	desc = "A formal security suit for officers complete with Armadyne belt buckle."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	icon_state = "peacekeeper_warden"

/obj/item/clothing/under/rank/security/warden
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'

/obj/item/clothing/under/rank/security/head_of_security/peacekeeper
	name = "head of security's peacekeeper jumpsuit"
	desc = "A security jumpsuit decorated for those few with the dedication to achieve the position of Head of Security."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	icon_state = "peacekeeper_hos"

//PEACEKEEPER ARMOR
/obj/item/clothing/suit/armor/vest/peacekeeper
	name = "peacekeeper armor vest"
	desc = "A standard issue peacekeeper armor vest, versatile, lightweight, and most importantly, cheap."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi'
	icon_state = "peacekeeper_white"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/vest/peacekeeper/black
	icon_state = "peacekeeper_black"

/obj/item/clothing/suit/armor/vest/peacekeeper/brit
	name = "high vis armored vest"
	desc = "Oi bruv, you got a loicence for that?"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "hazardbg"
	worn_icon_state = "hazardbg"

/obj/item/clothing/suit/armor/vest/peacekeeper/brit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")

/obj/item/clothing/suit/armor/vest/peacekeeper/spacecoat
	name = "peacekeeper sleek coat"
	desc = "An incredibly stylish and heavy black coat made of synthetic kangaroo leather, padded with durathread and lined with kevlar."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "peacekeeper_spacecoat"
	worn_icon_state = "peacekeeper_spacecoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/armor/vest/peacekeeper/jacket
	name = "peacekeeper jacket"
	desc = "A slightly vintage canvas and aramid jacket; hi-vis checkers included. Armored and stylish? Implausible."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi'
	icon_state = "peacekeeper_jacket"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS

/obj/item/clothing/suit/armor/vest/peacekeeper/jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")

/obj/item/clothing/suit/armor/vest/peacekeeper/jacket/badge
	name = "badged peacekeeper jacket"
	desc = "A slightly vintage canvas and aramid jacket; hi-vis checkers and chevron badge included. Armored and stylish? Implausible."
	icon_state = "peacekeeper_jacket_badge"

//PEACEKEEPER GLOVES
/obj/item/clothing/gloves/combat/peacekeeper
	name = "peacekeeper gloves"
	desc = "These tactical gloves are fireproof."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "peacekeeper_gloves"
	worn_icon_state = "peacekeeper"
	siemens_coefficient = 0.5
	strip_delay = 20
	cold_protection = 0
	min_cold_protection_temperature = null
	heat_protection = 0
	max_heat_protection_temperature = null
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	cut_type = null

/obj/item/clothing/gloves/tackler/peacekeeper
	name = "peacekeeper gripper gloves"
	desc = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "peacekeeper_gripper_gloves"

/obj/item/clothing/gloves/krav_maga/sec/peacekeeper
	name = "peacekeeper krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/hands.dmi'
	icon_state = "peacekeeper_gripper_gloves"

//PEACEKEEPER WEBBING
/obj/item/storage/belt/security/webbing/peacekeeper
	name = "peacekeeper webbing"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'
	icon_state = "peacekeeper_webbing"
	worn_icon_state = "peacekeeper_webbing"

//BOOTS
/obj/item/clothing/shoes/jackboots/peacekeeper
	name = "peacekeeper boots"
	desc = "High speed, low drag combat boots."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "peacekeeper"

// DETECTIVE
/obj/item/clothing/under/rank/security/detective/cowboy
	name = "blonde cowboy uniform"
	desc = "A blue shirt and dark jeans, with a pair of spurred cowboy boots to boot."
	icon = 'monkestation/code/modules/blueshift/icons/donator/obj/clothing/uniform.dmi'	//Donator item-ish? See the /armorless one below it
	worn_icon = 'monkestation/code/modules/blueshift/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "cowboy_uniform"
	supports_variations_flags = NONE
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/detective/cowboy/armorless //Donator variant, just uses the sprite.
	armor_type = /datum/armor/none

/obj/item/clothing/suit/cowboyvest
	name = "blonde cowboy vest"
	desc = "A white cream vest lined with... fur, of all things, for desert weather. There's a small deer head logo sewn into the vest."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "cowboy_vest"
	body_parts_covered = CHEST|ARMS
	cold_protection = CHEST|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	heat_protection = CHEST|ARMS

/obj/item/clothing/suit/jacket/det_suit/cowboyvest
	name = "blonde cowboy vest"
	desc = "A white cream vest lined with... fur, of all things, for desert weather. There's a small deer head logo sewn into the vest."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	icon_state = "cowboy_vest"
	body_parts_covered = CHEST|ARMS
	cold_protection = CHEST|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	heat_protection = CHEST|ARMS

/obj/item/clothing/under/rank/security/detective/runner
	name = "runner sweater"
	desc = "<i>\"You look lonely.\"</i>"
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/security.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/security.dmi'
	icon_state = "runner"
	supports_variations_flags = NONE
	can_adjust = FALSE

/// PRISONER
/obj/item/clothing/under/rank/prisoner/protcust
	name = "protective custody prisoner jumpsuit"
	desc = "A mustard coloured prison jumpsuit, often worn by former Security members, informants and former CentCom employees. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#FFB600"

/obj/item/clothing/under/rank/prisoner/skirt/protcust
	name = "protective custody prisoner jumpskirt"
	desc = "A mustard coloured prison jumpskirt, often worn by former Security members, informants and former CentCom employees. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#FFB600"
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/prisoner/lowsec
	name = "low security prisoner jumpsuit"
	desc = "A pale, almost creamy prison jumpsuit, this one denotes a low security prisoner, things like fraud and anything white collar. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#AB9278"

/obj/item/clothing/under/rank/prisoner/skirt/lowsec
	name = "low security prisoner jumpskirt"
	desc = "A pale, almost creamy prison jumpskirt, this one denotes a low security prisoner, things like fraud and anything white collar. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#AB9278"
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/prisoner/highsec
	name = "high risk prisoner jumpsuit"
	desc = "A bright red prison jumpsuit, depending on who sees it, either a badge of honour or a sign to avoid. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#FF3400"

/obj/item/clothing/under/rank/prisoner/skirt/highsec
	name = "high risk prisoner jumpskirt"
	desc = "A bright red prison jumpskirt, depending on who sees it, either a badge of honour or a sign to avoid. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#FF3400"
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/prisoner/supermax
	name = "supermax prisoner jumpsuit"
	desc = "A dark crimson red prison jumpsuit, for the worst of the worst, or the Clown. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#992300"

/obj/item/clothing/under/rank/prisoner/skirt/supermax
	name = "supermax prisoner jumpskirt"
	desc = "A dark crimson red prison jumpskirt, for the worst of the worst, or the Clown. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#992300"
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/prisoner/classic
	name = "classic prisoner jumpsuit"
	desc = "A black and white striped jumpsuit, like something out of a movie."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/costume.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/costume.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/costume_digi.dmi'
	icon_state = "prisonerclassic"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	supports_variations_flags = NONE

/obj/item/clothing/under/rank/prisoner/syndicate
	name = "syndicate prisoner jumpsuit"
	desc = "A crimson red jumpsuit worn by syndicate captives. Its sensors have been shorted out."
	greyscale_colors = "#992300"
	has_sensor = FALSE

/obj/item/clothing/under/rank/prisoner/skirt/syndicate
	name = "syndicate prisoner jumpskirt"
	desc = "A crimson red jumpskirt worn by syndicate captives. Its sensors have been shorted out."
	greyscale_colors = "#992300"
	has_sensor = FALSE
	supports_variations_flags = NONE
