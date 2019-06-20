/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize()
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost - /obj/item/clothing/under/color/black/skirt - /obj/item/clothing/under/color/grey/skirt - /obj/item/clothing/under/color/blue/skirt - /obj/item/clothing/under/color/green/skirt - /obj/item/clothing/under/color/orange/skirt - /obj/item/clothing/under/color/pink/skirt - /obj/item/clothing/under/color/red/skirt - /obj/item/clothing/under/color/white/skirt - /obj/item/clothing/under/color/yellow/skirt - /obj/item/clothing/under/color/darkblue/skirt - /obj/item/clothing/under/color/teal/skirt - /obj/item/clothing/under/color/lightpurple/skirt - /obj/item/clothing/under/color/darkgreen/skirt - /obj/item/clothing/under/color/lightbrown/skirt - /obj/item/clothing/under/color/brown/skirt - /obj/item/clothing/under/color/maroon/skirt)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), SLOT_W_UNIFORM) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	resistance_flags = NONE

/obj/item/clothing/under/color/black/skirt
	name = "black jumpskirt"
	icon_state = "black_skirt"
	item_state = "bl_suit"
	item_color = "black_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/obj/item/clothing/under/color/grey/skirt
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	icon_state = "grey_skirt"
	item_state = "gy_suit"
	item_color = "grey_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.forcesay(GLOB.hit_appends)
	return 0

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	item_color = "blue"

/obj/item/clothing/under/color/blue/skirt
	name = "blue jumpskirt"
	icon_state = "blue_skirt"
	item_state = "b_suit"
	item_color = "blue_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	item_color = "green"

/obj/item/clothing/under/color/green/skirt
	name = "green jumpskirt"
	icon_state = "green_skirt"
	item_state = "g_suit"
	item_color = "green_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orange"
	item_state = "o_suit"
	item_color = "orange"

/obj/item/clothing/under/color/orange/skirt
	name = "orange jumpskirt"
	icon_state = "orange_skirt"
	item_state = "o_suit"
	item_color = "orange_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	item_state = "p_suit"
	item_color = "pink"

/obj/item/clothing/under/color/pink/skirt
	name = "pink jumpskirt"
	icon_state = "pink_skirt"
	item_state = "p_suit"
	item_color = "pink_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	item_color = "red"

/obj/item/clothing/under/color/red/skirt
	name = "red jumpskirt"
	icon_state = "red_skirt"
	item_state = "r_suit"
	item_color = "red_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	item_color = "white"

/obj/item/clothing/under/color/white/skirt
	name = "white jumpskirt"
	icon_state = "white_skirt"
	item_state = "w_suit"
	item_color = "white_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	item_color = "yellow"

/obj/item/clothing/under/color/yellow/skirt
	name = "yellow jumpskirt"
	icon_state = "yellow_skirt"
	item_state = "y_suit"
	item_color = "yellow_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/darkblue
	name = "darkblue jumpsuit"
	icon_state = "darkblue"
	item_state = "b_suit"
	item_color = "darkblue"

/obj/item/clothing/under/color/darkblue/skirt
	name = "darkblue jumpskirt"
	icon_state = "darkblue_skirt"
	item_state = "b_suit"
	item_color = "darkblue_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	icon_state = "teal"
	item_state = "b_suit"
	item_color = "teal"

/obj/item/clothing/under/color/teal/skirt
	name = "teal jumpskirt"
	icon_state = "teal_skirt"
	item_state = "b_suit"
	item_color = "teal_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP


/obj/item/clothing/under/color/lightpurple
	name = "purple jumpsuit"
	icon_state = "lightpurple"
	item_state = "p_suit"
	item_color = "lightpurple"

/obj/item/clothing/under/color/lightpurple/skirt
	name = "lightpurple jumpskirt"
	icon_state = "lightpurple_skirt"
	item_state = "p_suit"
	item_color = "lightpurple_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/darkgreen
	name = "darkgreen jumpsuit"
	icon_state = "darkgreen"
	item_state = "g_suit"
	item_color = "darkgreen"

/obj/item/clothing/under/color/darkgreen/skirt
	name = "darkgreen jumpskirt"
	icon_state = "darkgreen_skirt"
	item_state = "g_suit"
	item_color = "darkgreen_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/lightbrown
	name = "lightbrown jumpsuit"
	icon_state = "lightbrown"
	item_state = "lb_suit"
	item_color = "lightbrown"

/obj/item/clothing/under/color/lightbrown/skirt
	name = "lightbrown jumpskirt"
	icon_state = "lightbrown_skirt"
	item_state = "lb_suit"
	item_color = "lightbrown_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	item_state = "lb_suit"
	item_color = "brown"

/obj/item/clothing/under/color/brown/skirt
	name = "brown jumpskirt"
	icon_state = "brown_skirt"
	item_state = "lb_suit"
	item_color = "brown_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	icon_state = "maroon"
	item_state = "r_suit"
	item_color = "maroon"

/obj/item/clothing/under/color/maroon/skirt
	name = "maroon jumpskirt"
	icon_state = "maroon_skirt"
	item_state = "r_suit"
	item_color = "maroon_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"
	can_adjust = FALSE