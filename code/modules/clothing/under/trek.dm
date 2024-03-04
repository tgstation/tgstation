//Just some alt-uniforms themed around Star Trek - Pls don't sue, Mr Roddenberry ;_;

/obj/item/clothing/under/trek
	can_adjust = FALSE
	icon = 'icons/obj/clothing/under/trek.dmi'
	worn_icon = 'icons/mob/clothing/under/trek.dmi'

/*
*	The Original Series (Technically not THE original because these have a black undershirt while the very-original didn't but IDC)
*/
/obj/item/clothing/under/trek/command
	name = "command uniform"
	desc = "An outdated uniform worn by command officers."
	icon_state = "trek_tos_com" //Shirt has gold wrist-bands
	inhand_icon_state = "y_suit"
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#fab342"

/obj/item/clothing/under/trek/engsec
	name = "engsec uniform"
	desc = "An outdated uniform worn by engineering/security officers."
	icon_state = "trek_tos_sec" //Tucked-in shirt
	inhand_icon_state = "r_suit"
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#B72B2F"

/obj/item/clothing/under/trek/medsci
	name = "medsci uniform"
	desc = "An outdated worn by medical/science officers."
	icon_state = "trek_tos"
	inhand_icon_state = "b_suit"
	greyscale_config = /datum/greyscale_config/trek
	greyscale_config_worn = /datum/greyscale_config/trek/worn
	greyscale_colors = "#5FA4CC"

/*
*	The Next Generation
*/
/obj/item/clothing/under/trek/command/next
	icon_state = "trek_next" //Technically TNG had Command wearing red, but bc gold is closer to command roles for SS13 we're taking some liberties

/obj/item/clothing/under/trek/engsec/next
	icon_state = "trek_next"

/obj/item/clothing/under/trek/medsci/next
	icon_state = "trek_next"

/*
*	Voyager
*/
/obj/item/clothing/under/trek/command/voy
	icon_state = "trek_voy" //Same point applies as TNG

/obj/item/clothing/under/trek/engsec/voy
	icon_state = "trek_voy"

/obj/item/clothing/under/trek/medsci/voy
	icon_state = "trek_voy"

/*
*	Enterprise
*/
/obj/item/clothing/under/trek/command/ent
	icon_state = "trek_ent"
	//Greyscale sprite note, the base of it can't be greyscaled lest I make a whole new .json, but the color bands are greyscale at least.
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/engsec/ent
	icon_state = "trek_ent"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/medsci/ent
	icon_state = "trek_ent"
	inhand_icon_state = "bl_suit"

//Q
/obj/item/clothing/under/trek/q
	name = "french marshall's uniform"
	desc = "Something about this uniform feels off..."
	icon_state = "trek_Q"
	inhand_icon_state = "r_suit"
