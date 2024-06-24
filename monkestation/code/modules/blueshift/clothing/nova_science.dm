/obj/item/clothing/under/rank/rnd
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/rnd_digi.dmi'

/obj/item/clothing/under/rank/rnd/research_director/alt
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/buttondown_slacks/worn/digi

/obj/item/clothing/under/rank/rnd/scientist/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/rnd.dmi'
	icon_state = null //debug item

/obj/item/clothing/under/rank/rnd/roboticist/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/rnd.dmi'
	icon_state = null //debug item

/obj/item/clothing/under/rank/rnd/research_director/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/rnd.dmi'
	icon_state = null //debug item

/*
 *	GENETICIST (TO-DO)
 *  Add geneticist icons!!!
 */

/*
/obj/item/clothing/under/rank/rnd/geneticist/nova/utility
	name = "genetics utility uniform"
	desc = "A utility uniform worn by NT-certified Genetics staff."
	icon_state = "util_gene"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/geneticist/nova/utility/syndicate
	desc = "A utility uniform worn by Genetics staff."
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS
*/

/*
 *	SCIENTIST
 */
/obj/item/clothing/under/rank/rnd/scientist/nova/utility
	name = "science utility uniform"
	desc = "A utility uniform worn by NT-certified Science staff."
	icon_state = "util_sci"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/scientist/nova/utility/syndicate
	desc = "A utility uniform worn by Science staff."
	armor_type = /datum/armor/clothing_under/utility_syndicate
	has_sensor = NO_SENSORS

/obj/item/clothing/under/rank/rnd/scientist/nova/hlscience
	name = "science team uniform"
	desc = "A simple semi-formal uniform consisting of a grayish-blue shirt and off-white slacks, paired with a ridiculous, but mandatory, tie."
	icon_state = "hl_scientist"
	can_adjust = FALSE

/*
 *	RESEARCH DIRECTOR
 */
/obj/item/clothing/under/rank/rnd/research_director/nova/imperial //Rank pins of the Major General
	desc = "An off-white naval suit over black pants, with a rank badge denoting the Officer of the Internal Science Division. It's a peaceful life."
	name = "research director's naval jumpsuit"
	icon_state = "imprd"
