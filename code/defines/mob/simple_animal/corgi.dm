//Corgi
/mob/living/simple_animal/corgi
	name = "corgi"
	real_name = "corgi"
	desc = "Puppy!!"
	icon = 'mob.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP","Woof!","Bark!","AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks","woofs","yaps")
	emote_see = list("shakes it's head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	meat_amount = 3
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	var/obj/item/inventory_head
	var/obj/item/inventory_back

/mob/living/simple_animal/corgi/update_clothing()
	overlays = list()

	if(inventory_head)
		var/head_icon_state = inventory_head.icon_state
		if(health <= 0)
			head_icon_state += "2"

		var/icon/head_icon = icon('corgi_head.dmi',head_icon_state)
		if(head_icon)
			overlays += head_icon

	if(inventory_back)
		var/back_icon_state = inventory_back.icon_state
		if(health <= 0)
			back_icon_state += "2"

		var/icon/back_icon = icon('corgi_back.dmi',back_icon_state)
		if(back_icon)
			overlays += back_icon
	return

/mob/living/simple_animal/corgi/Life()
	..()
	update_clothing()

/mob/living/simple_animal/corgi/show_inv(mob/user as mob)
	/*
	user.machine = src

	var/dat = 	"<div align='center'><b>Inventory of [src]</b></div><p>"
	if(inventory_head)
		dat +=	"<br><b>Head:</b> [inventory_head] (<a href='?src=\ref[src];remove_inv=head'>Remove</a>)"
	else
		dat +=	"<br><b>Head:</b> <a href='?src=\ref[src];add_inv=head'>Nothing</a>"
	if(inventory_back)
		dat +=	"<br><b>Back:</b> [inventory_back] (<a href='?src=\ref[src];remove_inv=back'>Remove</a>)"
	else
		dat +=	"<br><b>Back:</b> <a href='?src=\ref[src];add_inv=back'>Nothing</a>"

	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	*/
	return

/mob/living/simple_animal/corgi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(inventory_head && inventory_back)
		//helmet and armor = 100% protection
		if( istype(inventory_head,/obj/item/clothing/head/helmet) && istype(inventory_back,/obj/item/clothing/suit/armor) )
			if( O.force )
				usr << "\red This animal is wearing too much armor. You can't cause it any damage."
				for (var/mob/M in viewers(src, null))
					M.show_message("\red \b [user] hits [src] with the [O], however [src] is too armored.")
			else
				usr << "\red This animal is wearing too much armor. You can't reach it's skin."
				for (var/mob/M in viewers(src, null))
					M.show_message("\red [user] gently taps [src] with the [O]. ")
			if(prob(15))
				emote("looks at [user] with [pick("an amused","an annoyed","a confused","a resentful", "a happy", "an excited")] expression on it's face")
			return
	..()

/mob/living/simple_animal/corgi/Topic(href, href_list)
	//Removing from inventory
	if(href_list["remove_inv"])
		if(get_dist(src,usr) > 1)
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)

					if(inventory_head.type == /obj/item/clothing/head/caphat)
						name = real_name

					inventory_head.loc = src.loc
					inventory_head = null
				else
					usr << "\red There is nothing on this slot."
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
				else
					usr << "\red There is nothing on this slot."
					return

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(get_dist(src,usr) > 1)
			return
		if(!usr.get_active_hand())
			usr << "\red You have nothing in your active hand to put in the slot."
			return
		var/add_to = href_list["add_inv"]
		switch(add_to)
			if("head")
				if(inventory_head)
					usr << "\red The [inventory_head] is already in this slot."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/head/helmet,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/clothing/head/caphat,
						/obj/item/clothing/head/that
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The object cannot fit on this animal."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_head = item_to_add
					update_clothing()

			if("back")
				if(inventory_back)
					usr << "\red The [inventory_back] is already in this slot."
					return
				else
					var/obj/item/item_to_add = usr.get_active_hand()
					if(!item_to_add)
						return

					//Corgis are supposed to be simpler, so only a select few objects can actually be put
					//to be compatible with them. The objects are below.

					var/list/allowed_types = list(
						/obj/item/clothing/suit/armor/vest
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The object cannot fit on this animal."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					update_clothing()

		show_inv(usr)
	else
		..()

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	desc = "It's Ian, what else do you need to know?"
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(alive && !restrained() )
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)
				sleep(3)
				step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					if (movement_target.loc.x < src.x)
						dir = WEST
					else if (movement_target.loc.x > src.x)
						dir = EAST
					else if (movement_target.loc.y < src.y)
						dir = SOUTH
					else if (movement_target.loc.y > src.y)
						dir = NORTH
					else
						dir = SOUTH

				if(isturf(movement_target.loc) )
					movement_target.attack_animal(src)
				else if(ishuman(movement_target.loc) )
					if(prob(20))
						emote("stares at the [movement_target] that [movement_target.loc] has with a sad puppy-face")

		if(prob(1))
			emote("dances around")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					dir = i
					sleep(1)

/mob/living/simple_animal/corgi/Ian/restrained()
	if(resting || buckled)
		return 1
	return 0

/mob/living/simple_animal/corgi/Ian/verb/stoppull()
	set name = "Stop pulling"
	set category = "IC"

	pulling = null

/mob/living/simple_animal/corgi/Ian/Move()
	if(restrained())
		pulling = null
		return

	var/turf/old_loc
	var/turf/new_loc

	if(isturf(loc))
		old_loc = src.loc
	else
		return //in a container, cannot move

	..()

	if(isturf(loc))
		new_loc = src.loc
	else
		return //in a container, cannot move

	if(old_loc == new_loc)
		return //has not moved

	if(pulling)

		if(isturf(old_loc) && isturf(pulling.loc))
			if(get_dist(src.loc,old_loc) > 1)
				world << "get_dist(src.loc,pulling.loc)"
				pulling = null
				return
		else
			pulling = null
			return

		if(istype(pulling,/obj/item))
			var/obj/item/I = pulling
			if(I.w_class > 4)
				pulling = null
				return
			if(I.anchored)
				pulling = null
				return

			I.loc = old_loc
			return

		if(ismob(pulling))
			var/mob/M = pulling
			if(!M.stat)
				pulling = null
				return //cannot drag live people
			if(M.anchored)
				pulling = null
				return
			if(M.restrained())
				pulling = null
				return

			M.loc = old_loc
			return

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."