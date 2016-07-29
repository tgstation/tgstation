<<<<<<< HEAD
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
	user << "<span class='notice'>Alt-click it to start a wash cycle.</span>"

/obj/machinery/washing_machine/AltClick(mob/user)
	if(!user.canUseTopic(src))
		return

	if(busy)
		return

	if(state_open)
		user << "<span class='notice'>Close the door first</span>"
		return

	if(bloody_mess)
		user << "<span class='warning'>[src] must be cleaned up first.</span>"
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
			color = CR.paint_color

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

/obj/machinery/washing_machine/container_resist(mob/user)
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

	else if(user.a_intent != "harm")

		if (!state_open)
			user << "<span class='warning'>Open the door first!</span>"
			return 1

		if(bloody_mess)
			user << "<span class='warning'>[src] must be cleaned up first.</span>"
			return 1

		if(contents.len >= max_wash_capacity)
			user << "<span class='warning'>The washing machine is full!</span>"
			return 1

		if(!user.unEquip(W))
			user << "<span class='warning'>\The [W] is stuck to your hand, you cannot put it in the washing machine!</span>"
			return 1

		if(istype(W,/obj/item/toy/crayon) || istype(W,/obj/item/weapon/stamp))
			color_source = W
		W.loc = src
		update_icon()

	else
		return ..()

/obj/machinery/washing_machine/attack_hand(mob/user)
	if(busy)
		user << "<span class='warning'>[src] is busy.</span>"
		return

	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
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


/obj/machinery/washing_machine/open_machine(drop = 1)
	..()
	density = 1 //because machinery/open_machine() sets it to 0
	color_source = null
	has_corgi = 0
=======
/obj/machinery/washing_machine
	name = "washing machine"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "wm_10"
	density = 1
	anchored = 1.0
	var/wash_state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon
	var/speed_coefficient = 1

	machine_flags = SCREWTOGGLE | WRENCHMOVE

/obj/machinery/washing_machine/New()
	..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/washing_machine,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator
	)
	RefreshParts()

/obj/machinery/washing_machine/RefreshParts()
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator)) manipcount += SP.rating
	speed_coefficient = 1/manipcount

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if( wash_state != 4 )
		to_chat(usr, "\The [src] cannot run in this state.")
		return

	if( locate(/mob,contents) )
		wash_state = 8
	else
		wash_state = 5
	update_icon()
	sleep(200*speed_coefficient)
	for(var/atom/A in contents)
		A.clean_blood()

	for(var/obj/item/I in contents)
		I.decontaminate()

	//Tanning!
	for(var/obj/item/stack/sheet/hairlesshide/HH in contents)
		var/obj/item/stack/sheet/wetleather/WL = new(src)
		WL.amount = HH.amount
		qdel(HH)
		HH = null


	if(crayon)
		var/color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			color = CR.colourName
		else if(istype(crayon,/obj/item/weapon/stamp))
			var/obj/item/weapon/stamp/ST = crayon
			color = ST._color

		if(color)
			var/new_jumpsuit_icon_state = ""
			var/new_jumpsuit_item_state = ""
			var/new_jumpsuit_name = ""
			var/new_glove_icon_state = ""
			var/new_glove_item_state = ""
			var/new_glove_name = ""
			var/new_shoe_icon_state = ""
			var/new_shoe_name = ""
			var/new_sheet_icon_state = ""
			var/new_sheet_name = ""
			var/new_softcap_icon_state = ""
			var/new_softcap_name = ""
			var/ccoil_test = null
			var/new_desc = "The colors are a bit dodgy."
			for(var/T in typesof(/obj/item/clothing/under))
				var/obj/item/clothing/under/J = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == J._color)
					new_jumpsuit_icon_state = J.icon_state
					new_jumpsuit_item_state = J.item_state
					new_jumpsuit_name = J.name
					qdel(J)
					J = null
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				qdel(J)
				J = null
			for(var/T in typesof(/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == G._color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					qdel(G)
					G = null
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				qdel(G)
				G = null
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == S._color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					qdel(S)
					S = null
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				qdel(S)
				S = null
			for(var/T in typesof(/obj/item/weapon/bedsheet))
				var/obj/item/weapon/bedsheet/B = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == B._color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					qdel(B)
					B = null
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				qdel(B)
				B = null
			for(var/T in typesof(/obj/item/clothing/head/soft))
				var/obj/item/clothing/head/soft/H = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == H._color)
					new_softcap_icon_state = H.icon_state
					new_softcap_name = H.name
					qdel(H)
					H = null
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				qdel(H)
				H = null

			for(var/T in typesof(/obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/test = new T
				if(test._color == color)
//					to_chat(world, "Found the right cable coil, _color: [test._color]")
					ccoil_test = 1
					qdel(test)
					test = null
					break
				qdel(test)
				test = null

			if(new_jumpsuit_icon_state && new_jumpsuit_item_state && new_jumpsuit_name)
				for(var/obj/item/clothing/under/J in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J._color = color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_icon_state && new_glove_item_state && new_glove_name)
				for(var/obj/item/clothing/gloves/G in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					G.item_state = new_glove_item_state
					G.icon_state = new_glove_icon_state
					G._color = color
					G.name = new_glove_name
					if(!istype(G, /obj/item/clothing/gloves/black/thief))
						G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					if (S.chained == 1)
						S.chained = 0
						S.slowdown = SHOES_SLOWDOWN
						new /obj/item/weapon/handcuffs( src )
					S.icon_state = new_shoe_icon_state
					S._color = color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/weapon/bedsheet/B in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					B.icon_state = new_sheet_icon_state
					B._color = color
					B.name = new_sheet_name
					B.desc = new_desc
			if(new_softcap_icon_state && new_softcap_name)
				for(var/obj/item/clothing/head/soft/H in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					H.icon_state = new_softcap_icon_state
					H._color = color
					H.name = new_softcap_name
					H.desc = new_desc

			if(ccoil_test)
				for(var/obj/item/stack/cable_coil/H in contents)
//					to_chat(world, "DEBUG: YUP! FOUND IT!")
					H._color = color
					H.icon_state = "coil_[color]"
		qdel(crayon)
		crayon = null


	if( locate(/mob,contents) )
		wash_state = 7
		gibs_ready = 1
	else
		wash_state = 4
	update_icon()

/obj/machinery/washing_machine/AltClick()
	if(!usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		start()
		return
	return ..()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(wash_state in list(1,3,6) )
		usr.loc = src.loc


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[wash_state][panel_open]"

/obj/machinery/washing_machine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(..())
		update_icon()
		return 1
	else if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/weapon/stamp))
		if( wash_state in list(	1, 3, 6 ) )
			if(!crayon)
				if(user.drop_item(W, src))
					crayon = W
	else if(istype(W,/obj/item/weapon/grab))
		if( (wash_state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.loc = src
				qdel(G)
				G = null
				wash_state = 3
	else if(istype(W,/obj/item/stack/sheet/hairlesshide) || \
		istype(W,/obj/item/clothing/under) || \
		istype(W,/obj/item/clothing/mask) || \
		istype(W,/obj/item/clothing/head) || \
		istype(W,/obj/item/clothing/gloves) || \
		istype(W,/obj/item/clothing/shoes) || \
		istype(W,/obj/item/clothing/suit) || \
		istype(W,/obj/item/stack/cable_coil) || \
		istype(W,/obj/item/weapon/bedsheet))

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item.
		if ( istype(W,/obj/item/clothing/suit/space ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/suit/powered ) )
//			to_chat(user, "This item does not fit.")
//			return
		if ( istype(W,/obj/item/clothing/suit/cyborg_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/bomb_suit ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/gas ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/mask/cigarette ) )
			to_chat(user, "This item does not fit.")
			return
		if ( istype(W,/obj/item/clothing/head/syndicatefake ) )
			to_chat(user, "This item does not fit.")
			return
//		if ( istype(W,/obj/item/clothing/head/powered ) )
//			to_chat(user, "This item does not fit.")
//			return
		if ( istype(W,/obj/item/clothing/head/helmet ) )
			to_chat(user, "This item does not fit.")
			return

		if(contents.len < 5)
			if ( wash_state in list(1, 3) )
				if(user.drop_item(W, src))
					wash_state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
	update_icon()

/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	if(..())
		return 1

	switch(wash_state)
		if(1)
			wash_state = 2
		if(2)
			wash_state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			wash_state = 4
		if(4)
			wash_state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			wash_state = 1
		if(5)
			to_chat(user, "<span class='warning'>\The [src] is busy.</span>")
		if(6)
			wash_state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			wash_state = 1


	update_icon()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
