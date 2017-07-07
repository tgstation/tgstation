//B.O.S.S.: Bluespace Object Support System

//contains:
//the main BOSS sender and variants
//the BOSS receiver

//BOSS sender//
/obj/machinery/boss_sender
	name = "B.O.S.S."
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport items to far away places to aid others."
	icon_state = "autolathe"

	density = TRUE
	anchored = TRUE

	obj_integrity = 250
	max_integrity = 250

	var/checkTech = FALSE

/obj/machinery/boss_sender/sci
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport equipment made in R&D to lavaland, to aid the miners."
	checkTech = TRUE

/obj/machinery/boss_sender/attack_hand(mob/user)
	switch(alert(user,,"[src.name] panel","Send items","Remove an item"))
		if("Send items")
			return //todo
		if("Remove an item")
			var/input = input("Select an item to remove.", "[src.name] panel", null, null) as null|anything in src.contents
			if(input)
				var/obj/item/I = input
				if(istype(I))
					I.forceMove(get_turf(src))

/obj/machinery/boss_sender/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	var/accept_item = TRUE

	if(checkTech)
		if(!O.origin_tech)
			accept_item = FALSE

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
		return

	if(accept_item)
		O.forceMove(src)
		return


//BOSS receiver//
/obj/machinery/boss_receiver
	name = "B.O.S.S. receiver"
	desc = "This machine receives items sent through bluespace from a B.O.S.S. sender unit."
	icon_state = "autolathe"


