//B.O.S.S.: Bluespace Object Support System

//contains:
//the main BOSS sender and variants
//the BOSS receiver

//TODO
//clean up lists when receivers are destroyed?
//make them require power
//make them drop held items when destroyed

//BOSS sender//
/obj/machinery/boss_sender
	name = "\improper B.O.S.S. sender"
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
	..()
	if(powered())
		switch(alert(user,"Select an option.","[src.name] panel","Send all items","Manage inventory"))
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
						linked.announce_item(I)
					to_chat(user, "Item[contents.len > 1 ? "s" : ""] sent to receiver.")

			if("Manage inventory")
				var/input = input("Select an item to remove.", "[src.name] panel", null, null) as null|anything in src.contents
				if(input)
					var/obj/item/I = input
					if(istype(I))
						user.put_in_active_hand(I)

/obj/machinery/boss_sender/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()


	if(checkTech && !O.origin_tech)
		to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
		return

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
		return

	if(powered())
		O.forceMove(src)
	return


//BOSS receiver//
/obj/machinery/boss_receiver
	name = "\improper B.O.S.S. receiver"
	desc = "This machine receives items sent through bluespace from a B.O.S.S. sender unit."
	icon_state = "autolathe"
	var/is_mining_receiver = FALSE

	density = TRUE
	anchored = TRUE

	obj_integrity = 250
	max_integrity = 250

	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"

/obj/machinery/boss_receiver/sci
	is_mining_receiver = TRUE

/obj/machinery/boss_receiver/sci/Initialize()
	..()
	GLOB.boss_receivers += src

/obj/machinery/boss_receiver/examine(mob/user)
	..()
	if(contents.len > 0)
		to_chat(user,"<span class='notice'>A light indicates the [src.name] is storing items.</span>")

/obj/machinery/boss_receiver/attack_hand(mob/user)
	..()
	if(powered())
		switch(alert(user, "Select an option", "[src.name] panel", "Manage inventory", "Cancel"))
			if("Cancel")
				return
			if("Manage inventory")
				var/input = input("Select an item to remove.", "[src.name] panel", null, null) as null|anything in src.contents
				if(input)
					var/obj/item/I = input
					if(istype(I))
						user.put_in_active_hand(I)

/obj/machinery/boss_receiver/proc/announce_item(var/obj/item/I)
	if(powered())
		say("Item received: [I.name]")