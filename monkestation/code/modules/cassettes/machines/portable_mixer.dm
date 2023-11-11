/obj/item/device/cassette_deck
	name = "Dual Cassette Deck"
	desc = "A Dual Cassette Deck, popular for its ability to copy songs from a cassette. A relic of the old times"
	icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	icon_state = "walkman"
	w_class = WEIGHT_CLASS_SMALL
	///The cassette that is being copied from
	var/obj/item/device/cassette_tape/send
	///List of songs the sender has
	var/list/sender_list
	///List of names the Sender has
	var/list/sender_names
	///The cassette you are copying to
	var/obj/item/device/cassette_tape/recieve
	///List of songs the Reciever has
	var/list/reciever_list
	///List of song names the Reciever has
	var/list/reciever_names
	///Changes between removal and addition mode
	var/removal = FALSE
	///Did we add a non approved song to an approved tape if so remove the cassette's approved status
	var/broke_approval = FALSE

/obj/item/device/cassette_deck/AltClick(mob/user)
	if(recieve || send)
		eject_tape(user)
		return
	return ..()

/obj/item/device/cassette_deck/CtrlClick(mob/user)
	to_chat(user,"You click a button and change the Cassette Deck to [removal ? "splicing" : "removal"] mode")
	removal = !removal

/obj/item/device/cassette_deck/attackby(obj/item/cassette, mob/user)
	if(!istype(cassette, /obj/item/device/cassette_tape))
		return
	if(!send || !recieve)
		insert_tape(cassette)
		playsound(src,'sound/weapons/handcuffs.ogg',20,1)
		to_chat(user,("You insert \the [cassette] into \the [src]"))
	else
		to_chat(user,("Remove a tape first!"))

/obj/item/device/cassette_deck/attack_self(mob/user)
	. = ..()
	if(!recieve)
		to_chat(user,("No Cassette to edit please insert a cassette to edit!"))
		return

	if(!removal)
		if(reciever_list.len >= 7)
			to_chat(user,"The Cassette is full please flip cassette or insert a new one")
			return
		if(!sender_names.len)
			to_chat(user,"No songs to splice please change cassette")
			return
		///tgui choice to add to the reciever cassette from the sender cassette
		var/choice = tgui_input_list(usr, "Select a track to add.", "Dual Cassette Deck", sender_names)
		if(isnull(choice))
			return
		var/num = sender_names.Find(choice)
		reciever_list.Add(sender_list[num])
		reciever_names.Add(sender_names[num])
		if(broke_approval)
			recieve.approved_tape = FALSE

	else
		if(!reciever_names.len)
			to_chat(user,"No songs to remove please change cassette")
			return
		///tgui choice to remove from the list of songs on the cassettes
		var/choice = tgui_input_list(usr, "Select a track to remove.", "Dual Cassette Deck", reciever_names)
		if(isnull(choice))
			return
		var/num = reciever_names.Find(choice)
		reciever_list.Remove(reciever_list[num])
		reciever_names.Remove(reciever_names[num])

/obj/item/device/cassette_deck/proc/insert_tape(obj/item/device/cassette_tape/CTape)
	if(send && recieve || !istype(CTape))
		return

	if(!send)
		send = CTape
		if(!send.approved_tape)
			broke_approval = TRUE
		CTape.forceMove(src)
		if(send.songs["side1"] && send.songs["side2"])
			sender_list = send.songs["[send.flipped ? "side2" : "side1"]"]
			sender_names = send.song_names["[send.flipped ? "side2" : "side1"]"]
	else
		recieve = CTape
		CTape.forceMove(src)
		if(recieve.songs["side1"] && recieve.songs["side2"])
			reciever_list = recieve.songs["[send.flipped ? "side2" : "side1"]"]
			reciever_names = recieve.song_names["[recieve.flipped ? "side2" : "side1"]"]

/obj/item/device/cassette_deck/proc/eject_tape(mob/user)
	if(!recieve && !send)
		return
	if(recieve)
		if(recieve.flipped == FALSE)
			recieve.songs["side1"] = reciever_list
			recieve.song_names["side1"] = reciever_names
		else
			recieve.songs["side2"] = reciever_list
			recieve.song_names["side1"] = reciever_names
		user.put_in_hands(recieve)
		recieve = null
		playsound(src,'sound/weapons/handcuffs.ogg',20,1)
	else
		user.put_in_hands(send)
		send = null
		broke_approval = FALSE
		playsound(src,'sound/weapons/handcuffs.ogg',20,1)
