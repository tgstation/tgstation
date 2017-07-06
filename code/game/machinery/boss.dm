//B.O.S.S.: Bluespace Object Support System




//BOSS machine//
/obj/machinery/boss
	name = "B.O.S.S."
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport items to far away places to aid others."
	icon_state = "autolathe"

	density = TRUE
	anchored = TRUE

	obj_integrity = 250
	max_integrity = 250

	var/list/stored_items
	var/checkTech = FALSE

/obj/machinery/boss/sci
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport equipment made in R&D to lavaland, to aid the miners."
	checkTech = TRUE

/obj/machinery/boss/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(checkTech && O.origin_tech)
		O.forceMove(get_turf(src))


//BOSS beacon//


