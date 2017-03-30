/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_1_0"
	density = 1
	anchored = 1
	state_open = 1
	var/busy = 0
	var/bloody_mess = 0
	var/has_corgi = 0
	var/obj/item/color_source
	var/max_wash_capacity = 5

/obj/machinery/washing_machine/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click it to start a wash cycle.</span>")

/obj/machinery/washing_machine/AltClick(mob/user)
	if(!user.canUseTopic(src))
		return

	if(busy)
		return

	if(state_open)
		to_chat(user, "<span class='notice'>Close the door first</span>")
		return

	if(bloody_mess)
		to_chat(user, "<span class='warning'>[src] must be cleaned up first.</span>")
		return

	if(has_corgi)
		bloody_mess = 1

	busy = 1
	update_icon()
	sleep(200)
	wash_cycle()

/obj/machinery/washing_machine/clean_blood()
	..()
	if(!busy)
		bloody_mess = 0
		update_icon()


/obj/machinery/washing_machine/proc/wash_cycle()
	for(var/X in contents)
		var/atom/movable/AM = X
		AM.clean_blood()
		AM.machine_wash(src)

	busy = 0
	if(color_source)
		qdel(color_source)
		color_source = null
	update_icon()


//what happens to this object when washed inside a washing machine
/atom/movable/proc/machine_wash(obj/machinery/washing_machine/WM)
	return

/obj/item/stack/sheet/hairlesshide/machine_wash(obj/machinery/washing_machine/WM)
	var/obj/item/stack/sheet/wetleather/WL = new(loc)
	WL.amount = amount
	qdel(src)

/obj/item/clothing/suit/hooded/ian_costume/machine_wash(obj/machinery/washing_machine/WM)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/corgi(loc)
	qdel(src)

/obj/item/weapon/paper/machine_wash(obj/machinery/washing_machine/WM)
	if(WM.color_source)
		if(istype(WM.color_source,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = WM.color_source
			add_atom_colour(CR.paint_color, WASHABLE_COLOUR_PRIORITY)

/mob/living/simple_animal/pet/dog/corgi/machine_wash(obj/machinery/washing_machine/WM)
	gib()

/obj/item/clothing/under/color/machine_wash(obj/machinery/washing_machine/WM)
	jumpsuit_wash(WM)

/obj/item/clothing/under/rank/machine_wash(obj/machinery/washing_machine/WM)
	jumpsuit_wash(WM)

/obj/item/clothing/under/proc/jumpsuit_wash(obj/machinery/washing_machine/WM)
	if(WM.color_source)
		var/wash_color = WM.color_source.item_color
		var/obj/item/clothing/under/U
		for(var/T in typesof(/obj/item/clothing/under/color))
			var/obj/item/clothing/under/color/J = T
			if(wash_color == initial(J.item_color))
				U = J
				break
		if(!U)
			for(var/T in typesof(/obj/item/clothing/under/rank))
				var/obj/item/clothing/under/rank/R = T
				if(wash_color == initial(R.item_color))
					U = R
					break
		if(U)
			item_state = initial(U.item_state)
			icon_state = initial(U.icon_state)
			item_color = wash_color
			name = initial(U.name)
			desc = "The colors are a bit dodgy."
			can_adjust = initial(U.can_adjust)
			if(!can_adjust && adjusted) //we deadjust the uniform if it's now unadjustable
				toggle_jumpsuit_adjust()

/obj/item/clothing/gloves/color/machine_wash(obj/machinery/washing_machine/WM)
	if(WM.color_source)
		var/wash_color = WM.color_source.item_color
		for(var/T in typesof(/obj/item/clothing/gloves/color))
			var/obj/item/clothing/gloves/color/G = T
			if(wash_color == initial(G.item_color))
				item_state = initial(G.item_state)
				icon_state = initial(G.icon_state)
				item_color = wash_color
				name = initial(G.name)
				desc = "The colors are a bit dodgy."
				break

/obj/item/clothing/shoes/sneakers/machine_wash(obj/machinery/washing_machine/WM)
	if(chained)
		chained = 0
		slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/restraints/handcuffs(loc)
	if(WM.color_source)
		var/wash_color = WM.color_source.item_color
		for(var/T in typesof(/obj/item/clothing/shoes/sneakers))
			var/obj/item/clothing/shoes/sneakers/S = T
			if(wash_color == initial(S.item_color))
				icon_state = initial(S.icon_state)
				item_color = wash_color
				name = initial(S.name)
				desc = "The colors are a bit dodgy."
				break

/obj/item/weapon/bedsheet/machine_wash(obj/machinery/washing_machine/WM)
	if(WM.color_source)
		var/wash_color = WM.color_source.item_color
		for(var/T in typesof(/obj/item/weapon/bedsheet))
			var/obj/item/weapon/bedsheet/B = T
			if(wash_color == initial(B.item_color))
				icon_state = initial(B.icon_state)
				item_color = wash_color
				name = initial(B.name)
				desc = "The colors are a bit dodgy."
				break

/obj/item/clothing/head/soft/machine_wash(obj/machinery/washing_machine/WM)
	if(WM.color_source)
		var/wash_color = WM.color_source.item_color
		for(var/T in typesof(/obj/item/clothing/head/soft))
			var/obj/item/clothing/head/soft/H = T
			if(wash_color == initial(H.item_color))
				icon_state = initial(H.icon_state)
				item_color = wash_color
				name = initial(H.name)
				desc = "The colors are a bit dodgy."
				break


/obj/machinery/washing_machine/relaymove(mob/user)
	container_resist(user)

/obj/machinery/washing_machine/container_resist(mob/living/user)
	if(!busy)
		add_fingerprint(user)
		open_machine()



/obj/machinery/washing_machine/update_icon()
	cut_overlays()
	if(busy)
		icon_state = "wm_running_[bloody_mess]"
	else if(bloody_mess)
		icon_state = "wm_[state_open]_blood"
	else
		var/full = contents.len ? 1 : 0
		icon_state = "wm_[state_open]_[full]"
	if(panel_open)
		add_overlay(image(icon, icon_state = "wm_panel"))

/obj/machinery/washing_machine/attackby(obj/item/weapon/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, null, null, W))
		update_icon()
		return

	else if(user.a_intent != INTENT_HARM)

		if (!state_open)
			to_chat(user, "<span class='warning'>Open the door first!</span>")
			return 1

		if(bloody_mess)
			to_chat(user, "<span class='warning'>[src] must be cleaned up first.</span>")
			return 1

		if(contents.len >= max_wash_capacity)
			to_chat(user, "<span class='warning'>The washing machine is full!</span>")
			return 1

		if(!user.transferItemToLoc(W, src))
			to_chat(user, "<span class='warning'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>")
			return 1

		if(istype(W,/obj/item/toy/crayon) || istype(W,/obj/item/weapon/stamp))
			color_source = W
		update_icon()

	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy.</span>")
		return

	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.has_buckled_mobs())
			return
		if(state_open)
			if(iscorgi(L))
				has_corgi = 1
				L.forceMove(src)
				update_icon()
		return

	if(!state_open)
		open_machine()
	else
		state_open = 0 //close the door
		update_icon()

/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/machinery/washing_machine/open_machine(drop = 1)
	..()
	density = 1 //because machinery/open_machine() sets it to 0
	color_source = null
	has_corgi = 0
