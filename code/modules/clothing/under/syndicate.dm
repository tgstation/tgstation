/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with baggy cargo pants."
	icon_state = "tac_turtleneck"
	inhand_icon_state = "bl_suit"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/under_syndicate
	alt_covers_chest = TRUE
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'

/datum/armor/under_syndicate
	melee = 10
	bio = 10
	fire = 50
	acid = 40

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
	has_sensor = HAS_SENSORS
	armor_type = /datum/armor/syndicate_tacticool

/datum/armor/syndicate_tacticool
	bio = 10
	fire = 50
	acid = 40

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirtleneck"
	icon_state = "tactifool_skirt"
	inhand_icon_state = "bl_suit"
	armor_type = /datum/armor/syndicate_tacticool
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	dying_key = DYE_REGISTRY_JUMPSKIRT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/*

	GORLEX SECURITY CONSULTING, LLC.
	TODO: NOTHING.

*/

/obj/item/clothing/under/syndicate/gorlex
	desc = "A non-descript and slightly suspicious looking turtleneck with baggy cargo pants. This one in particular makes you feel like a terrorist of some sort."
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
	desc = "A non-descript and slightly suspicious looking turtleneck with baggy cargo pants. Wearing this makes you feel like a true corpo."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/cybersun/combat
	name = "\improper Cybersun private military jumpsuit"
	desc = "A white jumpsuit woven with durable nano-kevlar fibres. The Cybersun logo are emblazed in white onto two mirrored black arm bands."
	icon_state = "cybersun_pmc"

/obj/item/clothing/under/syndicate/cybersun/corpo
	name = "\improper Cybersun executive suit"
	desc = "A true symbol of corporate seniority. Black and red is the colour of the game, just the feeling of wearing this alone makes you feel superior."
	icon_state = "cybersun_exec_m"

/obj/item/clothing/under/syndicate/cybersun/corpo/fem
	female_sprite_flags = FEMALE_UNIFORM_FULL

/*

	INTERDYNE PHARMACEUTICALS, INC.
	TODO: ADDITIONAL SPECIAL OUTFIT.

*/

/obj/item/clothing/under/syndicate/interdyne
	desc = "A non-descript and slightly suspicious looking turtleneck with baggy cargo pants. Wearing this makes you feel like a smart dude."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/interdyne/trauma_team
	name = "\improper Trauma Team scrubs"
	desc = "A baggy Interdyne-blue coloured tactical uniform. Sewed from special synthetic fabrics designed to both protect the wearer, and repel bodily fluids."
	icon_state = "interdyne_trauma_team"
	armor_type = /datum/armor/syndicate_scrubs

/datum/armor/syndicate_scrubs
	melee = 10
	bio = 50
	fire = 50
	acid = 40

/*

	TIGER COOPERATIVE

*/

/obj/item/clothing/under/syndicate/tiger
	desc = "A non-descript and slightly suspicious looking turtleneck with baggy cargo pants. You feel like some sort of cultist wearing this."
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/tiger/priest
	name = "\improper Tiger-Coop priest's uniform"
	desc = "A tight-fitting red and black priest uniform. Reserved for the upper echelon of Tiger-Coop; those with prestige, and those worshipped. A person wearing this is probably a Changeling. Or not, who knows."
	icon_state = "tiger_coop_priest"


/*

	MISC. / NOT-DIRECTLY SYNDICATE.

*/

/obj/item/clothing/under/syndicate/suit
	name = "tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "tactical_suit"
	inhand_icon_state = "bl_suit"
	can_adjust = FALSE
