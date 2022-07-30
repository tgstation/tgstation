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
	icon_state = "trek_command"
	inhand_icon_state = "y_suit"

/obj/item/clothing/under/trek/engsec
	name = "engsec uniform"
	desc = "An outdated uniform worn by engineering/security officers."
	icon_state = "trek_engsec"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/trek/medsci
	name = "medsci uniform"
	desc = "An outdated worn by medical/science officers."
	icon_state = "trek_medsci"
	inhand_icon_state = "b_suit"

/*
*	The Next Generation
*/
/obj/item/clothing/under/trek/command/next
	icon_state = "trek_next_command" //Technically TNG had Command wearing red, but just bc gold is fitting more to command roles for SS13 we're taking some liberties

/obj/item/clothing/under/trek/engsec/next
	icon_state = "trek_next_engsec"

/obj/item/clothing/under/trek/medsci/next
	icon_state = "trek_next_medsci"

/*
*	Voyager
*/
/obj/item/clothing/under/trek/command/voy
	icon_state = "trek_voy_command" //Same point applies as TNG

/obj/item/clothing/under/trek/engsec/voy
	icon_state = "trek_voy_engsec"

/obj/item/clothing/under/trek/medsci/voy
	icon_state = "trek_voy_medsci"

/*
*	Enterprise
*/
/obj/item/clothing/under/trek/command/ent
	icon_state = "trek_ent_command"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/engsec/ent
	icon_state = "trek_ent_engsec"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/trek/medsci/ent
	icon_state = "trek_ent_medsci"
	inhand_icon_state = "bl_suit"

//Q
/obj/item/clothing/under/trek/q
	name = "french marshall's uniform"
	desc = "Something about this uniform feels off..."
	icon_state = "trek_Q"
	inhand_icon_state = "r_suit"
