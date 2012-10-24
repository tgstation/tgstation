//Look Sir, free crabs!
/mob/living/simple_animal/crab
	name = "crab"
	desc = "A hard-shelled crustacean. Seems quite content to lounge around all the time."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stomps the"
	stop_automated_movement = 1
	friendly = "pinches"
	var/obj/item/inventory_head
	var/obj/item/inventory_mask

/mob/living/simple_animal/crab/Life()
	..()
	//CRAB movement
	if(!ckey && !stat)
		if(isturf(src.loc) && !resting && !buckled)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(4,8)))
				turns_since_move = 0
	regenerate_icons()

//COFFEE! SQUEEEEEEEEE!
/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"

//LOOK AT THIS - ..()??
/*/mob/living/simple_animal/crab/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/wirecutters))
		if(prob(50))
			user << "\red \b This kills the crab."
			health -= 20
			Die()
		else
			GetMad()
			get
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					health = min(maxHealth, health + MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						del(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("\blue [user] applies the [MED] on [src]")
		else
			user << "\blue this [src] is dead, medical items won't bring it back to life."
	else
		if(O.force)
			health -= O.force
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with the [O]. ")

/mob/living/simple_animal/crab/Topic(href, href_list)
	if(usr.stat) return

	//Removing from inventory
	if(href_list["remove_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				if(inventory_head)
					name = real_name
					desc = initial(desc)
					speak_emote = list("clicks")
					emote_hear = list("clicks")
					emote_see = list("clacks")
					desc = "Free crabs!"
					src.sd_SetLuminosity(0)
					inventory_head.loc = src.loc
					inventory_head = null
				else
					usr << "\red There is nothing to remove from its [remove_from]."
					return
			if("mask")
				if(inventory_mask)
					inventory_mask.loc = src.loc
					inventory_mask = null
				else
					usr << "\red There is nothing to remove from its [remove_from]."
					return

		//show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.

	//Adding things to inventory
	else if(href_list["add_inv"])
		if(get_dist(src,usr) > 1 || !(ishuman(usr) || ismonkey(usr) || isrobot(usr) ||  isalienadult(usr)))
			return
		var/add_to = href_list["add_inv"]
		if(!usr.get_active_hand())
			usr << "\red You have nothing in your hand to put on its [add_to]."
			return
		switch(add_to)
			if("head")
				if(inventory_head)
					usr << "\red It's is already wearing something."
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
						/obj/item/clothing/head/that,
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
						/obj/item/clothing/head/chefhat,
						/obj/item/clothing/head/collectable/chef,
						/obj/item/clothing/head/collectable/police,
						/obj/item/clothing/head/wizard/fake,
						/obj/item/clothing/head/wizard,
						/obj/item/clothing/head/collectable/wizard,
						/obj/item/clothing/head/hardhat,
						/obj/item/clothing/head/collectable/hardhat,
						/obj/item/clothing/head/hardhat/white,
						/obj/item/weapon/bedsheet,
						/obj/item/clothing/head/soft
					)

					if( ! ( item_to_add.type in allowed_types ) )
						usr << "\red It doesn't seem too keen on wearing that item."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_head = item_to_add
					regenerate_icons()

					//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a HAT is removed.


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
							emote_see = list("twitches its nose", "hops around a bit")
							desc = "This is hoppy. It's a corgi-...urmm... bunny rabbit"
						if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
							name = "Yann"
							desc = "Mon dieu! C'est un chien!"
							speak = list("le woof!", "le bark!", "JAPPE!!")
							emote_see = list("cowers in fear", "surrenders", "plays dead","looks as  though there is a wall in front of /him")
						if(/obj/item/clothing/head/det_hat)
							name = "Detective [real_name]"
							desc = "[name] sees through your lies..."
							emote_see = list("investigates the area","sniffs around for clues","searches for scooby snacks")
						if(/obj/item/clothing/head/nursehat)
							name = "Nurse [real_name]"
							desc = "[name] needs 100cc of beef jerky...STAT!"
						if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate)
							name = "'[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]'"
							desc = "Yaarghh!! Thar' be a scurvy dog!"
							emote_see = list("hunts for treasure","stares coldly...","gnashes his tiny corgi teeth")
							emote_hear = list("growls ferociously", "snarls")
							speak = list("Arrrrgh!!","Grrrrrr!")
						if(/obj/item/clothing/head/collectable/police)
							name = "Officer [real_name]"
							emote_see = list("drools","looks for donuts")
							desc = "Stop right there criminal scum!"
						if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
							name = "Grandwizard [real_name]"
							speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")
						if(/obj/item/weapon/bedsheet)
							name = "\improper Ghost"
							speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
							emote_see = list("stumbles around", "shivers")
							emote_hear = list("howls","groans")
							desc = "Spooky!"
						if(/obj/item/clothing/head/soft)
							name = "Corgi Tech [real_name]"
							speak = list("Needs a stamp!", "Request DENIED!", "Fill these out in triplicate!")
							desc = "The reason your yellow gloves have chew-marks."

			if("mask")
				if(inventory_mask)
					usr << "\red It's already wearing something."
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
						usr << "\red This object won't fit."
						return

					usr.drop_item()
					item_to_add.loc = src
					src.inventory_mask = item_to_add
					regenerate_icons()

		//show_inv(usr) //Commented out because changing Ian's  name and then calling up his inventory opens a new inventory...which is annoying.
	else
		..()

/mob/living/simple_animal/crab/GetMad()
	name = "MEGAMADCRAB"
	real_name = "MEGAMADCRAB"
	desc = "OH NO YOU DUN IT NOW."
	icon = 'icons/mob/mob.dmi'
	icon_state = "madcrab"
	icon_living = "madcrab"
	icon_dead = "madcrab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks with fury", "clicks angrily")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 15//Gotta go fast
	maxHealth = 100//So they don't die as quickly
	health = 100
	melee_damage_lower = 3
	melee_damage_upper = 10//Kill them. Kill them all
	if(inventory_head)//Drops inventory so it doesn't have to be dealt with
		inventory_head.loc = src.loc
		inventory_head = null
	if(inventory_mask)
		inventory_mask.loc = src.loc
		inventory_mask = null*/