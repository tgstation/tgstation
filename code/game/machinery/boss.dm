//B.O.S.S.: Bluespace Object Support System

//contains:
//the main BOSS sender and variants
//the BOSS receiver

//TODO clean up lists when receivers are destroyed

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

	var/multiple_receivers = TRUE

	var/obj/machinery/boss_receiver/linked

/obj/machinery/boss_sender/sci
	desc = "The Bluespace Object Support System, or 'B.O.S.S.' is used to teleport equipment made in R&D to lavaland, to aid the miners. Interact with an open hand to send or remove items."
	checkTech = TRUE
	multiple_receivers = FALSE

/obj/machinery/boss_sender/sci/Initialize()
	..()
	for(var/obj/machinery/boss_receiver/B in GLOB.boss_receivers)
		if(B.is_mining_receiver)
			linked = B
			return

/obj/machinery/boss_sender/attack_hand(mob/user)
	switch(alert(user,,"[src.name] panel","Send items","Remove an item"))
		if("Send all items")
			if(multiple_receivers)
				var/input = input("Select a B.O.S.S. receiver unit.", "[src.name] panel", null, null) as null|anything in GLOB.boss_receivers
				if(input)
					var/obj/machinery/boss_receiver/B = input
					if(istype(B))
						linked = B

			if(linked)
				for(var/obj/item/I in src.contents)
					I.forceMove(linked)
				to_chat(user, "Items sent to receiver.")
		if("Remove an item")
			var/input = input("Select an item to remove.", "[src.name] panel", null, null) as null|anything in src.contents
			if(input)
				var/obj/item/I = input
				if(istype(I))
					I.forceMove(get_turf(src))

/obj/machinery/boss_sender/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()


	if(checkTech && !O.origin_tech)
		to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
		return

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
		return

	O.forceMove(src)
	return


//BOSS receiver//
/obj/machinery/boss_receiver
	name = "B.O.S.S. receiver"
	desc = "This machine receives items sent through bluespace from a B.O.S.S. sender unit."
	icon_state = "autolathe"
	var/is_mining_receiver = FALSE

/obj/machinery/boss_receiver/sci
	is_mining_receiver = TRUE

/obj/machinery/boss_receiver/sci/Initialize()
	..()
	GLOB.boss_receivers += src