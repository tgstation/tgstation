/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dying_key = DYE_REGISTRY_UNDER
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/color/jumpskirt
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize()
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - typesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/ancient - /obj/item/clothing/under/color/black/ghost - /obj/item/clothing/under/rank/prisoner)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING, initial=TRUE) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/jumpskirt/random
	icon_state = "random_jumpsuit" //Skirt variant needed

/obj/item/clothing/under/color/jumpskirt/random/Initialize()
	..()
	var/obj/item/clothing/under/color/jumpskirt/C = pick(subtypesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/jumpskirt/random - /obj/item/clothing/under/rank/prisoner/skirt)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING, initial=TRUE)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black //In-hand icon doesn't quite match the color of the worn icon in my opinion - Shroopy
	name = "black jumpsuit"
	icon_state = "black"
	inhand_icon_state = "bl_suit"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black //In-hand icon doesn't quite match the color of the worn icon in my opinion - Shroopy
	name = "black jumpskirt"
	icon_state = "black_skirt"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey //In-hand icon doesn't quite match the color of the worn icon in my opinion - Shroopy
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/color/jumpskirt/grey //In-hand icon doesn't quite match the color of the worn icon in my opinion - Shroopy
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	icon_state = "grey_skirt"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/color/grey/ancient
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "grey_ancient"
	can_adjust = FALSE

/obj/item/clothing/under/color/ //Uses the same in-hand icon as the teal suit, they should be differentiated
	name = "blue jumpsuit"
	icon_state = "blue"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/jumpskirt/blue //Uses the same in-hand icon as the teal suit, they should be differentiated
	name = "blue jumpskirt"
	icon_state = "blue_skirt"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/green //Uses the same in-hand icon as the dark-green suit, they should be differentiated
	name = "green jumpsuit"
	icon_state = "green"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/jumpskirt/green //Uses the same in-hand icon as the dark-green suit, they should be differentiated
	name = "green jumpskirt"
	icon_state = "green_skirt"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/orange //The in-hand icon shows a prisoner suit with the black bars, should have its own icon with this name
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orange"
	inhand_icon_state = "o_suit"

/obj/item/clothing/under/color/jumpskirt/orange //The in-hand icon shows a prisoner suit with the black bars, should have its own icon with this name
	name = "orange jumpskirt"
	icon_state = "orange_skirt"
	inhand_icon_state = "o_suit"

/obj/item/clothing/under/color/pink //Uses the same in-hand icon as the light purple suit, they should be differentiated
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/jumpskirt/pink //Uses the same in-hand icon as the light purple suit, they should be differentiated
	name = "pink jumpskirt"
	icon_state = "pink_skirt"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/red //Uses the same in-hand icon as the maroon suit, they should be differentiated
	name = "red jumpsuit"
	icon_state = "red"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/jumpskirt/red //Uses the same in-hand icon as the maroon suit, they should be differentiated
	name = "red jumpskirt"
	icon_state = "red_skirt"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	icon_state = "white_skirt"
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	inhand_icon_state = "y_suit"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	icon_state = "yellow_skirt"
	inhand_icon_state = "y_suit"

/obj/item/clothing/under/color/darkblue //Uses the same in-hand icon as the blue suit, they should be differentiated
	name = "dark blue jumpsuit"
	icon_state = "darkblue"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/jumpskirt/darkblue //Uses the same in-hand icon as the blue suit, they should be differentiated
	name = "dark blue jumpskirt"
	icon_state = "darkblue_skirt"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/teal //Uses the same in-hand icon as the blue suit, they should be differentiated
	name = "teal jumpsuit"
	icon_state = "teal"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/jumpskirt/teal //Uses the same in-hand icon as the blue suit, they should be differentiated
	name = "teal jumpskirt"
	icon_state = "teal_skirt"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/lightpurple //Uses the same in-hand icon as the pink suit, they should be differentiated
	name = "light purple jumpsuit"
	icon_state = "lightpurple"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/jumpskirt/lightpurple //Uses the same in-hand icon as the pink suit, they should be differentiated
	name = "light purple jumpskirt"
	icon_state = "lightpurple_skirt"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/darkgreen //Uses the same in-hand icon as the green suit, they should be differentiated
	name = "dark green jumpsuit"
	icon_state = "darkgreen"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/jumpskirt/darkgreen //Uses the same in-hand icon as the green suit, they should be differentiated
	name = "dark green jumpskirt"
	icon_state = "darkgreen_skirt"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/lightbrown //Uses the same in-hand icon as the brown suit, they should be differentiated
	name = "light brown jumpsuit"
	icon_state = "lightbrown"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/color/jumpskirt/lightbrown //Uses the same in-hand icon as the brown suit, they should be differentiated
	name = "light brown jumpskirt"
	icon_state = "lightbrown_skirt"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/color/brown //Uses the same in-hand icon as the light brown suit, they should be differentiated
	name = "brown jumpsuit"
	icon_state = "brown"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/color/jumpskirt/brown //Uses the same in-hand icon as the light brown suit, they should be differentiated
	name = "brown jumpskirt"
	icon_state = "brown_skirt"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/color/maroon //Uses the same in-hand icon as the red suit, they should be differentiated
	name = "maroon jumpsuit"
	icon_state = "maroon"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/jumpskirt/maroon //Uses the same in-hand icon as the red suit, they should be differentiated
	name = "maroon jumpskirt"
	icon_state = "maroon_skirt"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	inhand_icon_state = "rainbow"
	can_adjust = FALSE
	flags_1 = NONE

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "A multi-colored jumpskirt!"
	icon_state = "rainbow_skirt"
	inhand_icon_state = "rainbow"
	can_adjust = FALSE
	flags_1 = NONE
