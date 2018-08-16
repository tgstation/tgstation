/*
 *	Turtlenecks in general go here!
 */

//CMO's Turtleneck, because they don't have any unique clothes!

/obj/item/clothing/under/rank/chief_medical_officer/turtleneck
	desc = "It's a turtleneck worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection, for an officer with a superior sense of style and practicality."
	name = "chief medical officer's turtleneck"
	alternate_worn_icon = 'modular_citadel/icons/mob/clothing/turtlenecks.dmi'
	icon = 'modular_citadel/icons/obj/clothing/turtlenecks.dmi'
	icon_state = "cmoturtle"
	item_state = "w_suit"
	item_color = "cmoturtle"
	permeability_coefficient = 0.5
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0, fire = 0, acid = 0)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/structure/closet/secure_closet/CMO/PopulateContents()	//This is placed here because it's a very specific addition for a very specific niche
	..()
	new /obj/item/clothing/under/rank/chief_medical_officer/turtleneck(src)
	
/obj/item/clothing/under/syndicate/cosmetic
	name = "tactitool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	item_color = "tactifool"
	has_sensor = TRUE
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	
/obj/item/clothing/under/syndicate/tacticool
	has_sensor = TRUE
	
// Sweaters are good enough for this category too.

/obj/item/clothing/under/bb_sweater
	name = "cream sweater"
	desc = "Why trade style for comfort? Now you can go commando down south and still be cozy up north."
	icon_state = "bb_turtle"
	item_state = "w_suit"
	item_color = "bb_turtle"
	body_parts_covered = CHEST|ARMS
	can_adjust = 1
	icon = 'modular_citadel/icons/obj/clothing/turtlenecks.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/uniforms.dmi'

/obj/item/clothing/under/bb_sweater/black
	name = "black sweater"
	icon_state = "bb_turtleblk"
	item_state = "bl_suit"
	item_color = "bb_turtleblk"

/obj/item/clothing/under/bb_sweater/purple
	name = "purple sweater"
	icon_state = "bb_turtlepur"
	item_state = "p_suit"
	item_color = "bb_turtlepur"

/obj/item/clothing/under/bb_sweater/green
	name = "green sweater"
	icon_state = "bb_turtlegrn"
	item_state = "g_suit"
	item_color = "bb_turtlegrn"

/obj/item/clothing/under/bb_sweater/red
	name = "red sweater"
	icon_state = "bb_turtlered"
	item_state = "r_suit"
	item_color = "bb_turtlered"

/obj/item/clothing/under/bb_sweater/blue
	name = "blue sweater"
	icon_state = "bb_turtleblu"
	item_state = "b_suit"
	item_color = "bb_turtleblu"
