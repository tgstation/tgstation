//Corgi
/mob/living/simple_animal/corgi
	name = "corgi"
	real_name = "corgi"
	desc = "Puppy!!"
	icon = 'mob.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants")
	emote_see = list("shakes it's head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/corgi
	meat_amount = 3
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/obj/item/inventory_mouth

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
					name = real_name
					desc = initial(desc)
					speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
					speak_emote = list("barks", "woofs")
					emote_hear = list("barks", "woofs", "yaps","pants")
					emote_see = list("shakes it's head", "shivers")
					desc = "It's a corgi."
					src.sd_SetLuminosity(0)
					inventory_head.loc = src.loc
					inventory_head = null
				else
					usr << "\red There is nothing on its [remove_from]."
					return
			if("back")
				if(inventory_back)
					inventory_back.loc = src.loc
					inventory_back = null
				else
					usr << "\red There is nothing on its [remove_from]."
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
					//Many  hats added, Some will probably be removed, just want to see which ones are popular.

					var/list/allowed_types = list(
						/obj/item/clothing/head/helmet,
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/clothing/head/caphat,
						/obj/item/clothing/head/collectable/captain,
						/obj/item/clothing/head/that,
						/obj/item/clothing/head/helmet/that,
						/obj/item/clothing/head/kitty,
						/obj/item/clothing/head/collectable/kitty,
						/obj/item/clothing/head/rabbitears,
						/obj/item/clothing/head/collectable/rabbitears,
						/obj/item/clothing/head/beret,
						/obj/item/clothing/head/collectable/beret,
						/obj/item/clothing/head/det_hat,
						/obj/item/clothing/head/nursehat,
						/obj/item/clothing/head/pirate,
						/obj/item/clothing/head/collectable/pirate,
						/obj/item/clothing/head/ushanka,
						/obj/item/clothing/head/chefhat,
						/obj/item/clothing/head/collectable/chef,
						/obj/item/clothing/head/collectable/police,
						/obj/item/clothing/head/wizard/fake,
						/obj/item/clothing/head/wizard,
						/obj/item/clothing/head/collectable/wizard,
						/obj/item/clothing/head/helmet/hardhat,
						/obj/item/clothing/head/collectable/hardhat,
						/obj/item/clothing/head/helmet/hardhat/white,
						/obj/item/weapon/bedsheet,
						/obj/item/clothing/head/helmet/space/santahat,
						/obj/item/clothing/head/collectable/paper
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The corgi doesn't seem too keen on wearing that item."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_head = item_to_add
					update_clothing()

					//Various hats and items (worn on his head) change Ian's behaviour. His attributesare reset when a HAT is removed.


					switch(inventory_head && inventory_head.type)
						if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain)
							name = "Captain [real_name]"
							desc = "Probably better than the last captain."
						if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/collectable/kitty)
							name = "Runtime"
							emote_see = list("coughs up a furball", "stretches")
							emote_hear = list("purrs")
							speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
							desc = "It's a cute little kitty-cat! ... wait ... what the hell?"
						if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
							name = "Hoppy"
							emote_see = list("twitches his nose", "hops around a bit")
							desc = "This is hoppy. It's a corgi-...urmm... bunny rabbit"
						if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
							name = "Yann"
							desc = "mon dieu! C'est un chien!"
							speak = list("le woof!", "le bark!", "JAPPE!!")
							emote_see = list("cowers in fear", "surrenders", "plays dead")
						if(/obj/item/clothing/head/det_hat)
							name = "Detective [real_name]"
							desc = "[name] sees through your lies..."
							emote_see = list("investigates the area","sniffs around for clues","searches for scooby snacks")
						if(/obj/item/clothing/head/nursehat)
							name = "Nurse [real_name]"
							desc = "[name] needs 100cc of beef jerky...STAT!"
						if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
							name = "'[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibbles","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]'"
							desc = "Yaarghh!! Thar' be a scurvy dog!"
							emote_see = list("hunts for treasure","stares coldly...","gnashes his tiny corgi teeth")
							emote_hear = list("growls ferociously", "snarls")
							speak = list("Arrrrgh!!","Grrrrrr!")
						if(/obj/item/clothing/head/ushanka)
							name = "[pick("Comrade","Commissar")] [real_name]"
							desc = "A follower of Karl Barx."
							emote_see = list("contemplates the failings of the capitalist economic model", "ponders the pros and cons of vangaurdism")
						if(/obj/item/clothing/head/collectable/police)
							name = "Officer [real_name]"
							emote_see = list("drools","looks for donuts")
							desc = "Stop right there criminal scum!"
						if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
							name = "Grandwizard [real_name]"
							speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
						if(/obj/item/weapon/bedsheet)
							name = "The ghost"
							speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
							emote_see = list("stumbles around", "shivers")
							emote_hear = list("howls","groans")
							desc = "Spooky!"
						if(/obj/item/clothing/head/helmet/space/santahat)
							name = "Rudolph the Red-Nosed Corgi"
							emote_hear = list("barks christmas songs", "yaps")
							desc = "He has a very shiny nose."
							src.sd_SetLuminosity(6)

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
						/obj/item/clothing/suit/armor/vest,
						/obj/item/device/radio
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red The object cannot fit on this animal."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_back = item_to_add
					update_clothing()

		//show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.
	else
		..()

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	desc = "It's a corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"

/mob/living/simple_animal/corgi/Ian/Life()
	..()

	//Feeding, chasing food, FOOOOODDDD
	if(alive && !resting && !buckled)
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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/corgi/Ian/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return
//PC stuff-Sieve

/mob/living/simple_animal/corgi/proc/mind_initialize(mob/G)
	mind = new
	mind.current = src
	mind.assigned_role = "Corgi"
	mind.key = G.key

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."