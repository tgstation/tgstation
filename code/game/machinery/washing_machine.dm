/obj/machinery/washing_machine
	name = "Washing Machine"
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
		to_chat(usr, "The washing machine cannot run in this state.")
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
		del(HH)


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
					del(J)
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				del(J)
			for(var/T in typesof(/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == G._color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					del(G)
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				del(G)
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == S._color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					del(S)
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				del(S)
			for(var/T in typesof(/obj/item/weapon/bedsheet))
				var/obj/item/weapon/bedsheet/B = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == B._color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					del(B)
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				del(B)
			for(var/T in typesof(/obj/item/clothing/head/soft))
				var/obj/item/clothing/head/soft/H = new T
//				to_chat(world, "DEBUG: [color] == [J._color]")
				if(color == H._color)
					new_softcap_icon_state = H.icon_state
					new_softcap_name = H.name
					del(H)
//					to_chat(world, "DEBUG: YUP! [new_icon_state] and [new_item_state]")
					break
				del(H)

			for(var/T in typesof(/obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/test = new T
				if(test._color == color)
//					to_chat(world, "Found the right cable coil, _color: [test._color]")
					ccoil_test = 1
					del(test)
					break
				del(test)

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
		del(crayon)
		crayon = null


	if( locate(/mob,contents) )
		wash_state = 7
		gibs_ready = 1
	else
		wash_state = 4
	update_icon()

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
				user.drop_item(W, src)
				crayon = W
	else if(istype(W,/obj/item/weapon/grab))
		if( (wash_state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.loc = src
				del(G)
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
				user.drop_item(W, src)
				wash_state = 3
			else
				to_chat(user, "<span class='notice'>You can't put the item in right now.</span>")
		else
			to_chat(user, "<span class='notice'>The washing machine is full.</span>")
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
			to_chat(user, "<span class='warning'>The [src] is busy.</span>")
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