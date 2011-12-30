/obj/machinery/washing_machine
	name = "Washing Machine"
	icon = 'washing_machine.dmi'
	icon_state = "wm_10"
	density = 1
	anchored = 1.0
	var/state = 1
	//1 = empty, open door
	//2 = empty, closed door
	//3 = full, open door
	//4 = full, closed door
	//5 = running
	//6 = blood, open door
	//7 = blood, closed door
	//8 = blood, running
	var/panel = 0
	//0 = closed
	//1 = open
	var/hacked = 1 //Bleh, screw hacking, let's have it hacked by default.
	//0 = not hacked
	//1 = hacked
	var/gibs_ready = 0
	var/obj/crayon

/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if( state != 4 )
		usr << "The washing machine cannot run in this state."
		return

	if( locate(/mob,contents) )
		state = 8
	else
		state = 5
	update_icon()
	sleep(200)
	for(var/atom/A in contents)
		A.clean_blood()

	if(crayon)
		var/color
		if(istype(crayon,/obj/item/toy/crayon))
			var/obj/item/toy/crayon/CR = crayon
			color = CR.colourName
		else if(istype(crayon,/obj/item/weapon/stamp))
			var/obj/item/weapon/stamp/ST = crayon
			color = ST.color

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
			var/new_desc = "The colors are a bit dodgy."
			for(var/T in typesof(/obj/item/clothing/under))
				var/obj/item/clothing/under/J = new T
				//world << "DEBUG: [color] == [J.color]"
				if(color == J.color)
					new_jumpsuit_icon_state = J.icon_state
					new_jumpsuit_item_state = J.item_state
					new_jumpsuit_name = J.name
					del(J)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				del(J)
			for(var/T in typesof(/obj/item/clothing/gloves))
				var/obj/item/clothing/gloves/G = new T
				//world << "DEBUG: [color] == [J.color]"
				if(color == G.color)
					new_glove_icon_state = G.icon_state
					new_glove_item_state = G.item_state
					new_glove_name = G.name
					del(G)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				del(G)
			for(var/T in typesof(/obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = new T
				//world << "DEBUG: [color] == [J.color]"
				if(color == S.color)
					new_shoe_icon_state = S.icon_state
					new_shoe_name = S.name
					del(S)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				del(S)
			for(var/T in typesof(/obj/item/weapon/bedsheet))
				var/obj/item/weapon/bedsheet/B = new T
				//world << "DEBUG: [color] == [J.color]"
				if(color == B.color)
					new_sheet_icon_state = B.icon_state
					new_sheet_name = B.name
					del(B)
					//world << "DEBUG: YUP! [new_icon_state] and [new_item_state]"
					break
				del(B)
			if(new_jumpsuit_icon_state && new_jumpsuit_item_state && new_jumpsuit_name)
				for(var/obj/item/clothing/under/J in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					J.item_state = new_jumpsuit_item_state
					J.icon_state = new_jumpsuit_icon_state
					J.color = color
					J.name = new_jumpsuit_name
					J.desc = new_desc
			if(new_glove_icon_state && new_glove_item_state && new_glove_name)
				for(var/obj/item/clothing/gloves/G in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					G.item_state = new_glove_item_state
					G.icon_state = new_glove_icon_state
					G.color = color
					G.name = new_glove_name
					G.desc = new_desc
			if(new_shoe_icon_state && new_shoe_name)
				for(var/obj/item/clothing/shoes/S in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					S.icon_state = new_shoe_icon_state
					S.color = color
					S.name = new_shoe_name
					S.desc = new_desc
			if(new_sheet_icon_state && new_sheet_name)
				for(var/obj/item/weapon/bedsheet/B in contents)
					//world << "DEBUG: YUP! FOUND IT!"
					B.icon_state = new_sheet_icon_state
					B.color = color
					B.name = new_sheet_name
					B.desc = new_desc
		del(crayon)
		crayon = null


	if( locate(/mob,contents) )
		state = 7
		gibs_ready = 1
	else
		state = 4
	update_icon()

/obj/machinery/washing_machine/verb/climb_out()
	set name = "Climb out"
	set category = "Object"
	set src in usr.loc

	sleep(20)
	if(state in list(1,3,6) )
		usr.loc = src.loc


/obj/machinery/washing_machine/update_icon()
	icon_state = "wm_[state][panel]"

/obj/machinery/washing_machine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	/*if(istype(W,/obj/item/weapon/screwdriver))
		panel = !panel
		user << "\blue you [panel ? "open" : "close"] the [src]'s maintenance panel"*/
	if(istype(W,/obj/item/toy/crayon) ||istype(W,/obj/item/weapon/stamp))
		if( state in list(	1, 3, 6 ) )
			if(!crayon)
				user.drop_item()
				crayon = W
				crayon.loc = src
			else
				..()
		else
			..()
	else if(istype(W,/obj/item/weapon/grab))
		if( (state == 1) && hacked)
			var/obj/item/weapon/grab/G = W
			if(ishuman(G.assailant) && iscorgi(G.affecting))
				G.affecting.loc = src
				del(G)
				state = 3
		else
			..()
	else if(istype(W,/obj/item/clothing/under) || istype(W,/obj/item/clothing/mask) || istype(W,/obj/item/clothing/head) || istype(W,/obj/item/clothing/gloves) || istype(W,/obj/item/clothing/shoes) || istype(W,/obj/item/clothing/suit) || istype(W,/obj/item/weapon/bedsheet))

		//YES, it's hardcoded... saves a var/can_be_washed for every single clothing item.
		if ( istype(W,/obj/item/clothing/suit/space ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/suit/syndicatefake ) )
			user << "This item does not fit."
			return
//		if ( istype(W,/obj/item/clothing/suit/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/suit/cyborg_suit ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/suit/bomb_suit ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/suit/armor ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/mask/gas ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/mask/cigarette ) )
			user << "This item does not fit."
			return
		if ( istype(W,/obj/item/clothing/head/syndicatefake ) )
			user << "This item does not fit."
			return
//		if ( istype(W,/obj/item/clothing/head/powered ) )
//			user << "This item does not fit."
//			return
		if ( istype(W,/obj/item/clothing/head/helmet ) )
			user << "This item does not fit."
			return

		if(contents.len < 5)
			if ( state in list(1, 3) )
				user.drop_item()
				W.loc = src
				state = 3
			else
				user << "\blue You can't put the item in right now."
		else
			user << "\blue The washing machine is full."
	else
		..()
	update_icon()

/obj/machinery/washing_machine/attack_hand(mob/user as mob)
	switch(state)
		if(1)
			state = 2
		if(2)
			state = 1
			for(var/atom/movable/O in contents)
				O.loc = src.loc
		if(3)
			state = 4
		if(4)
			state = 3
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1
		if(5)
			user << "\red The [src] is busy."
		if(6)
			state = 7
		if(7)
			if(gibs_ready)
				gibs_ready = 0
				if(locate(/mob,contents))
					var/mob/M = locate(/mob,contents)
					M.gib()
			for(var/atom/movable/O in contents)
				O.loc = src.loc
			crayon = null
			state = 1


	update_icon()