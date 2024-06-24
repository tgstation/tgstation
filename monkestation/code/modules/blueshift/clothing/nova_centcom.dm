//This file is for any station-aligned or neutral factions, not JUST Nanotrasen.
//Try to keep them all a subtype of centcom/nova, for file sorting and balance - all faction representatives should have the same/similarly armored uniforms

/obj/item/clothing/under/rank/centcom
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/centcom_digi.dmi'

/obj/item/clothing/under/rank/centcom/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/centcom.dmi'

/*
*	NANOTRASEN
*/
//Check modular_nova\modules\nanotrasen_naval_command\code\clothing.dm for more of these! (Or, currently, ALL of these.)

/*
*	LOPLAND
*/
/obj/item/clothing/under/rank/centcom/nova/lopland
	name = "\improper Lopland corporate uniform"
	desc = "A sleek jumpsuit worn by Lopland corporate. Its surprisingly well padded."
	icon_state = "lopland_shirt"
	worn_icon_state = "lopland_shirt"

/obj/item/clothing/under/rank/centcom/nova/lopland/instructor
	name = "\improper Lopland instructor's uniform"
	desc = "A over-the-top, militaristic jumpsuit worn by Lopland-certified instructors, with a big Lopland logo slapped on the back. The amount of pockets could make a space marine cry."
	icon_state = "lopland_tac"
	worn_icon_state = "lopland_tac"


/*
*	MISC
*/
// pizza and other misc ERTs in this file too?
