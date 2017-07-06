//B.O.S.S.: Bluespace Object Support System




//BOSS machine//
/obj/machinery/boss
	name = "B.O.S.S."
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport items to far away places to aid explorers."
	icon_state = "autolathe"

	density = TRUE
	anchored = TRUE

	obj_integrity = 250
	max_integrity = 250

	var/list/stored_items

/obj/machinery/boss/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(O.origin_tech)
		O.forceMove(get_turf(src))


//BOSS beacon//


