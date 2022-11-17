/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	has_sensor = NO_SENSORS
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 40)
	alt_covers_chest = TRUE
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'

/obj/item/clothing/under/syndicate/skirt
	name = "tactical skirtleneck"
	desc = "A non-descript and slightly suspicious looking skirtleneck."
	icon_state = "syndicate_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	inhand_icon_state = "bl_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, FIRE = 50, ACID = 40)
	has_sensor = HAS_SENSORS

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirtleneck"
	icon_state = "tactifool_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/*

	GORLEX SECURITY CONSULTING, LLC.
	TODO: NOTHING.

*/

/obj/item/clothing/under/syndicate/gorlex
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. This one in particular makes you feel like a terrorist of some sort."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/gorlex/combat
	name = "gorlex combat under"
	desc = "A black undersuit, designed to be protect form the sharp inner-workings of spacesuits. Adorned on the right-shoulder is a Gorlex patch."
	icon_state = "gorlex_combat"

/obj/item/clothing/under/syndicate/gorlex/enlisted
	name = "enlisted service uniform"
	desc = "A high-collar service uniform for enlisted marauders. This one has a black collar."
	icon_state = "gorlex_enlisted"

/obj/item/clothing/under/syndicate/gorlex/enlisted/snr_officer
	name = "senior officer service uniform"
	desc = "A high-collar service uniform for senior officers. This one has a red collar, and a ruby medal attached to the chest."
	icon_state = "gorlex_snr_officer"

/*

	SABIASUN INDUSTRIES, INC.
	TODO: SPRITES.

*/

/obj/item/clothing/under/syndicate/cybersun
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. This one in particular makes you feel like a terrorist of some sort."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/cybersun/combat
	name = "gorlex combat under"

/obj/item/clothing/under/syndicate/cybersun/enlisted
	name = "enlisted service uniform"

/*

	INTERDYNE PHARMACEUTICALS, INC.
	TODO: ADDITIONAL SPECIAL OUTFIT.

*/

/obj/item/clothing/under/syndicate/interdyne
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants. This one in particular makes you feel like a terrorist of some sort."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/interdyne/tt
	name = "\improper Trauma Team scrubs"
	desc = "A baggy Interdyne-blue coloured tactical uniform. Sewed from special synthetic fabrics designed to both protect the wearer, and repel bodily fluids."
	icon_state = "interdyne_tt"

/obj/item/clothing/under/syndicate/interdyne/add
	name = "enlisted service uniform"
