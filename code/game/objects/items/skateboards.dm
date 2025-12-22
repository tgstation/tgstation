
/obj/item/melee/skateboard
	name = "skateboard"
	desc = "A skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "skateboard_held"
	inhand_icon_state = "skateboard"
	force = 12
	throwforce = 4
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("smacks", "whacks", "slams", "smashes")
	attack_verb_simple = list("smack", "whack", "slam", "smash")
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 10)
	///The vehicle counterpart for the board
	var/board_item_type = /obj/vehicle/ridden/scooter/skateboard

/obj/item/melee/skateboard/attack_self(mob/user)
	var/obj/vehicle/ridden/scooter/skateboard/S = new board_item_type(get_turf(user))//this probably has fucky interactions with telekinesis but for the record it wasn't my fault
	S.buckle_mob(user)
	qdel(src)

/obj/item/melee/skateboard/improvised
	name = "improvised skateboard"
	desc = "A jury-rigged skateboard. It can be placed on its wheels and ridden, or used as a radical weapon."
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/improvised

/obj/item/melee/skateboard/pro
	name = "skateboard"
	desc = "An EightO brand professional skateboard. It looks sturdy and well made."
	icon_state = "skateboard2_held"
	inhand_icon_state = "skateboard2"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/pro
	custom_premium_price = PAYCHECK_COMMAND * 5

/obj/item/melee/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	icon_state = "hoverboard_red_held"
	inhand_icon_state = "hoverboard_red"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard
	custom_premium_price = PAYCHECK_COMMAND * 5.4 //If I can't make it a meme I'll make it RAD

/obj/item/melee/skateboard/hoverboard/admin
	name = "Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	icon_state = "hoverboard_nt_held"
	inhand_icon_state = "hoverboard_nt"
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard/admin

/obj/item/melee/skateboard/holyboard
	name = "holy skateboard"
	desc = "A board blessed by the gods with the power to grind for our sins. Has the initials 'J.C.' on the underside."
	icon_state = "hoverboard_holy_held"
	inhand_icon_state = "hoverboard_holy"
	force = 18
	throwforce = 6
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "crashes", "grinds", "skates")
	attack_verb_simple = list("bash", "crash", "grind", "skate")
	board_item_type = /obj/vehicle/ridden/scooter/skateboard/hoverboard/holyboarded

/obj/item/melee/skateboard/holyboard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/nullrod_core)
