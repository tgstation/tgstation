/datum/recipe
	var/egg_amount = 0
	var/flour_amount = 0
	var/water_amount = 0
	var/cheese_amount = 0
	var/monkeymeat_amount = 0
	var/xenomeat_amount = 0
	var/humanmeat_amount = 0
	var/carpmeat_amount = 0
	var/donkpocket_amount = 0
	var/milk_amount = 0
	var/hotsauce_amount = 0
	var/coldsauce_amount = 0
	var/soysauce_amount = 0
	var/ketchup_amount = 0
	var/tofu_amount = 0
	var/berryjuice_amount = 0
	var/obj/extra_item = null // This is if an extra item is needed, eg a butte for an assburger
	var/creates = "" // The item that is spawned when the recipe is made

/datum/recipe/jellydonut
	egg_amount = 1
	flour_amount = 1
	berryjuice_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/jellydonut"

/datum/recipe/donut
	egg_amount = 1
	flour_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donut"

/datum/recipe/monkeyburger
	egg_amount = 0
	flour_amount = 1
	monkeymeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/monkeyburger"

/datum/recipe/humanburger
	flour_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/humanburger"

/datum/recipe/brainburger
	flour_amount = 1
	extra_item = /obj/item/brain
	creates = "/obj/item/weapon/reagent_containers/food/snacks/brainburger"

/datum/recipe/roburger/
	flour_amount = 1
	extra_item = /obj/item/robot_parts/head
	creates = "/obj/item/weapon/reagent_containers/food/snacks/roburger"

/datum/recipe/waffles
	egg_amount = 2
	flour_amount = 2
	creates = "/obj/item/weapon/reagent_containers/food/snacks/waffles"

/datum/recipe/faggot
	monkeymeat_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/faggot"

/datum/recipe/pie
	flour_amount = 2
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/banana
	creates = "/obj/item/weapon/reagent_containers/food/snacks/pie"

/datum/recipe/donkpocket
	flour_amount = 1
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/faggot
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donkpocket"

/datum/recipe/donkpocket_warm
	donkpocket_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donkpocket"

/datum/recipe/xenoburger
	egg_amount = 0
	flour_amount = 1
	xenomeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/xenoburger"

/datum/recipe/meatbread
	flour_amount = 3
	monkeymeat_amount = 3
	cheese_amount = 3
	creates = "/obj/item/weapon/reagent_containers/food/snacks/meatbread"

/datum/recipe/meatbreadhuman
	flour_amount = 3
	humanmeat_amount = 3
	cheese_amount = 3
	creates = "/obj/item/weapon/reagent_containers/food/snacks/meatbread"

/datum/recipe/xenomeatbread
	flour_amount = 3
	xenomeat_amount = 3
	cheese_amount = 3
	creates = "/obj/item/weapon/reagent_containers/food/snacks/xenomeatbread"

/datum/recipe/omelette
	egg_amount = 2
	cheese_amount = 2
	creates = "/obj/item/weapon/reagent_containers/food/snacks/omelette"

/datum/recipe/muffin
	egg_amount = 2
	flour_amount = 1
	milk_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/muffin"

/datum/recipe/eggplantparm
	cheese_amount = 2
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	creates = "/obj/item/weapon/reagent_containers/food/snacks/eggplantparm"

/datum/recipe/soylenviridians
	flour_amount = 3
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	creates = "/obj/item/weapon/reagent_containers/food/snacks/soylenviridians"

/datum/recipe/soylentgreen
	flour_amount = 3
	humanmeat_amount = 2
	creates = "/obj/item/weapon/reagent_containers/food/snacks/soylentgreen"

/datum/recipe/carrotcake
	flour_amount = 3
	egg_amount = 3
	milk_amount = 1
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	creates = "/obj/item/weapon/reagent_containers/food/snacks/carrotcake"

/datum/recipe/cheesecake
	flour_amount = 3
	egg_amount = 3
	cheese_amount = 2
	milk_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/cheesecake"

/datum/recipe/plaincake
	flour_amount = 3
	egg_amount = 3
	milk_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/plaincake"

/datum/recipe/humeatpie
	flour_amount = 2
	humanmeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/humeatpie"

/datum/recipe/momeatpie
	flour_amount = 2
	monkeymeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/momeatpie"

/datum/recipe/xemeatpie
	flour_amount = 2
	xenomeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/xemeatpie"

/datum/recipe/wingfangchu
	soysauce_amount = 1
	xenomeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/wingfangchu"

/datum/recipe/chaosdonut
	egg_amount = 1
	flour_amount = 1
	coldsauce_amount = 1
	hotsauce_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/chaosdonut"

/datum/recipe/humankabob
	humanmeat_amount = 2
	extra_item = /obj/item/stack/rods
	creates = "/obj/item/weapon/reagent_containers/food/snacks/humankabob"

/datum/recipe/monkeykabob
	monkeymeat_amount = 2
	extra_item = /obj/item/stack/rods
	creates = "/obj/item/weapon/reagent_containers/food/snacks/monkeykabob"

/datum/recipe/tofubread
	tofu_amount = 3
	cheese_amount = 3
	flour_amount = 3
	creates = "/obj/item/weapon/reagent_containers/food/snacks/tofubread"

/datum/recipe/loadedbakedpotato
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	cheese_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato"

/datum/recipe/cheesyfries
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/fries
	cheese_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/cheesyfries"

/datum/recipe/clownburger
	extra_item = /obj/item/clothing/mask/gas/clown_hat
	flour_amount = 1
	creates = "obj/item/weapon/reagent_containers/food/snacks/clownburger"

/datum/recipe/mimeburger
	extra_item = /obj/item/clothing/head/beret
	flour_amount = 1
	creates = "obj/item/weapon/reagent_containers/food/snacks/mimeburger"

/datum/recipe/cubancarp
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/grown/chili
	flour_amount = 1
	carpmeat_amount = 1
	creates = "obj/item/weapon/reagent_containers/food/snacks/cubancarp"



// *** After making the recipe above, add it in here! ***
// Special Note: When adding recipes to the list, make sure to list recipes with extra_item before similar recipes without
//					one. The reason being that sometimes the FOR loop that searchs through the recipes will just stop
//					at the wrong recipe. It's a hack job but it works until I clean up the microwave code.
/obj/machinery/microwave/New()
	..()
	src.available_recipes += new /datum/recipe/clownburger(src)
	src.available_recipes += new /datum/recipe/mimeburger(src)
	src.available_recipes += new /datum/recipe/cubancarp(src)
	src.available_recipes += new /datum/recipe/humankabob(src)
	src.available_recipes += new /datum/recipe/monkeykabob(src)
	src.available_recipes += new /datum/recipe/jellydonut(src)
	src.available_recipes += new /datum/recipe/donut(src)
	src.available_recipes += new /datum/recipe/monkeyburger(src)
	src.available_recipes += new /datum/recipe/humanburger(src)
	src.available_recipes += new /datum/recipe/waffles(src)
	src.available_recipes += new /datum/recipe/brainburger(src)
	src.available_recipes += new /datum/recipe/faggot(src)
	src.available_recipes += new /datum/recipe/roburger(src)
	src.available_recipes += new /datum/recipe/donkpocket(src)
	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/pie(src)
	src.available_recipes += new /datum/recipe/xenoburger(src)
	src.available_recipes += new /datum/recipe/meatbread(src)
	src.available_recipes += new /datum/recipe/meatbreadhuman(src)
	src.available_recipes += new /datum/recipe/omelette (src)
	src.available_recipes += new /datum/recipe/muffin (src)
	src.available_recipes += new /datum/recipe/eggplantparm(src)
	src.available_recipes += new /datum/recipe/soylenviridians(src)
	src.available_recipes += new /datum/recipe/soylentgreen(src)
	src.available_recipes += new /datum/recipe/carrotcake(src)
	src.available_recipes += new /datum/recipe/cheesecake(src)
	src.available_recipes += new /datum/recipe/plaincake(src)
	src.available_recipes += new /datum/recipe/humeatpie(src)
	src.available_recipes += new /datum/recipe/momeatpie(src)
	src.available_recipes += new /datum/recipe/xemeatpie(src)
	src.available_recipes += new /datum/recipe/wingfangchu(src)
	src.available_recipes += new /datum/recipe/chaosdonut(src)
	src.available_recipes += new /datum/recipe/tofubread(src)
	src.available_recipes += new /datum/recipe/loadedbakedpotato(src)
	src.available_recipes += new /datum/recipe/cheesyfries(src)
	src.available_recipes += new /datum/recipe/xenomeatbread(src)



/*******************
*   Item Adding
********************/

obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes part of the microwave."))
			src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes the microwave!"))
			src.icon_state = "mw"
			src.broken = 0 // Fix it!
			src.flags = OPENCONTAINER
		else
			user << "It's broken!"
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/cleaner)) // If they're trying to clean it then let them
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to clean the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] has cleaned the microwave!"))
			src.dirty = 0 // It's cleaned!
			src.icon_state = "mw"
			src.flags = OPENCONTAINER
		else //Otherwise bad luck!!
			return

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/egg)) // If an egg is used, add it
		if(src.egg_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds an egg to the microwave."))
			src.egg_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/tofu)) // If tofu is used, add it
		if(src.tofu_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds tofu to the microwave."))
			src.tofu_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/flour)) // If flour is used, add it
		if(src.flour_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some flour to the microwave."))
			src.flour_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge)) // If cheese is used, add it
		if(src.cheese_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some cheese to the microwave."))
			src.cheese_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeymeat))
		if(src.monkeymeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.monkeymeat_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/xenomeat))
		if(src.xenomeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.xenomeat_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/humanmeat))
		if(src.humanmeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.humanmeat_name = O:subjectname
			src.humanmeat_job = O:subjectjob
			src.humanmeat_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/carpmeat))
		if(src.carpmeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.carpmeat_amount++
			del(O)

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
		if(src.donkpocket_amount < 2)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds a donk-pocket to the microwave."))
			src.donkpocket_amount++
			del(O)

	else if(O.is_open_container())
		return

	else
		if(!istype(extra_item, /obj/item)) //Allow one non food item to be added!
			user.u_equip(O)
			extra_item = O
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds [O] to the microwave."))
		else
			user << "There already seems to be an unusual item inside, so you don't add this one too." //Let them know it failed for a reason though

obj/machinery/microwave/attack_paw(user as mob)
	return src.attack_hand(user)


/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/attack_hand(user as mob) // The microwave Menu
	var/dat
	var/xenodisplay
	var/sauces
	while(src.reagents.total_volume)		//A series of while loops to count up how much of the relevant reagents there are.
		while(src.reagents.get_reagent_amount("capsaicin") > 4)	//	And convert them into other variables. Ugly but it works for now.
			src.reagents.remove_reagent("capsaicin", 5)
			src.hotsauce_amount++
		while(src.reagents.get_reagent_amount("frostoil") > 4)
			src.reagents.remove_reagent("frostoil", 5)
			src.coldsauce_amount++
		while(src.reagents.get_reagent_amount("soysauce") > 4)
			src.reagents.remove_reagent("soysauce", 5)
			src.soysauce_amount++
		while(src.reagents.get_reagent_amount("milk") > 4)
			src.reagents.remove_reagent("milk", 5)
			src.milk_amount++
		while(src.reagents.get_reagent_amount("soymilk") > 4)
			src.reagents.remove_reagent("soymilk", 5)
			src.milk_amount++
		while(src.reagents.get_reagent_amount("ketchup") > 4)
			src.reagents.remove_reagent("ketchup", 5)
			src.ketchup_amount++
		while(src.reagents.get_reagent_amount("berryjuice") > 4)
			src.reagents.remove_reagent("berryjuice", 5)
			src.berryjuice_amount++
		src.reagents.clear_reagents()
	if(src.hotsauce_amount) sauces = sauces + "<B>Hotsauce:</B>[src.hotsauce_amount] units.<BR>"
	if(src.coldsauce_amount) sauces = sauces + "<B>Coldsauce:</B>[src.coldsauce_amount] units.<BR>"
	if(src.soysauce_amount) sauces = sauces + "<B>Soysauce:</B>[src.soysauce_amount] units.<BR>"
	if(src.berryjuice_amount) sauces = sauces + "<B>Berry Juice:</B>[src.berryjuice_amount] units.<BR>"
	if(src.ketchup_amount) sauces = sauces + "<B>Ketchup:</B>[src.ketchup_amount] units.<BR>"
	if(src.xenomeat_amount) xenodisplay = "<B>Alien Meat: </B>[src.xenomeat_amount]<BR>"
	if(src.broken > 0)
		dat = {"
<TT>Bzzzzttttt</TT>
		"}
	else if(src.operating)
		dat = {"
<TT>Microwaving in progress!<BR>
Please wait...!</TT><BR>
<BR>
"}
	else if(src.dirty)
		dat = {"
<TT>This microwave is dirty!<BR>
Please clean it before use!</TT><BR>
<BR>
"}
	else
		dat = {"
<B>Eggs:</B>[src.egg_amount] eggs<BR>
<B>Flour:</B>[src.flour_amount] cups of flour<BR>
<B>Cheese:</B>[src.cheese_amount] cheese wedges<BR>
<B>Tofu:</B>[src.tofu_amount] tofu chunks<BR>
<B>Monkey Meat:</B>[src.monkeymeat_amount] slabs of meat<BR>
<B>Turnovers:</B>[src.donkpocket_amount] turnovers<BR>
<B>Milk:</B>[src.milk_amount] cups of milk.<BR>
[sauces]
<B>Human Meat:</B>[src.humanmeat_amount] slabs of meat<BR>
<B>Carp Meat:</B>[src.carpmeat_amount] fillets of meat<BR>
[xenodisplay]
<HR>
<BR>
<A href='?src=\ref[src];cook=1'>Turn on!<BR>
<A href='?src=\ref[src];cook=2'>Dispose contents!<BR>
"}

	user << browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)

	if(href_list["cook"])
		if(!src.operating)
			var/operation = text2num(href_list["cook"])

			var/cook_time = 200 // The time to wait before spawning the item
			var/cooked_item = null

			if(operation == 1) // If cook was pressed
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The microwave turns on."))
				for(var/datum/recipe/R in src.available_recipes) //Look through the recipe list we made above
					if(src.carpmeat_amount == R.carpmeat_amount && src.berryjuice_amount >= R.berryjuice_amount && src.cheese_amount == R.cheese_amount && src.tofu_amount == R.tofu_amount && src.egg_amount == R.egg_amount && src.flour_amount == R.flour_amount && src.monkeymeat_amount == R.monkeymeat_amount && src.humanmeat_amount == R.humanmeat_amount && src.donkpocket_amount == R.donkpocket_amount && src.xenomeat_amount == R.xenomeat_amount && src.hotsauce_amount >= R.hotsauce_amount && src.coldsauce_amount >= R.coldsauce_amount && src.soysauce_amount >= R.soysauce_amount && src.ketchup_amount >= R.ketchup_amount && src.milk_amount >= R.milk_amount) // Check if it's an accepted recipe
						var/thing
						if(src.extra_item)
							if (src.extra_item.type == R.extra_item) thing = 1
						if(R.extra_item == null || thing) // Just in case the recipe doesn't have an extra item in it
							src.clear()
							src.extra_item = null // And the extra item
							cooked_item = R.creates // Store the item that will be created

				if(cooked_item == null) //Oops that wasn't a recipe dummy!!!
					if(src.carpmeat_amount > 0 || src.egg_amount > 0 || src.tofu_amount > 0 || src.flour_amount > 0 || src.water_amount > 0 || src.monkeymeat_amount > 0 || src.humanmeat_amount > 0 || src.donkpocket_amount > 0 || src.hotsauce_amount > 0 ||src.coldsauce_amount > 0 || src.soysauce_amount > 0 || src.ketchup_amount > 0 || src.milk_amount > 0 && src.extra_item == null) //Make sure there's something inside though to dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						src.clear()
						sleep(40) // Half way through
						playsound(src.loc, 'splat.ogg', 50, 1) // Play a splat sound
						icon_state = "mwbloody1" // Make it look dirty!!
						sleep(40) // Then at the end let it finish normally
						playsound(src.loc, 'ding.ogg', 50, 1)
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The microwave gets covered in muck!"))
						src.dirty = 1 // Make it dirty so it can't be used util cleaned
						src.flags = null //So you can't add condiments
						src.icon_state = "mwbloody" // Make it look dirty too
						src.operating = 0 // Turn it off again aferwards
						// Don't clear the extra item though so important stuff can't be deleted this way and
						// it prolly wouldn't make a mess anyway

					else if(src.extra_item != null) // However if there's a weird item inside we want to break it, not dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						src.clear()
						sleep(60) // Wait a while
						var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
						s.set_up(2, 1, src)
						s.start()
						icon_state = "mwb" // Make it look all busted up and shit
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The microwave breaks!")) //Let them know they're stupid
						src.broken = 2 // Make it broken so it can't be used util fixed
						src.operating = 0 // Turn it off again aferwards
						src.flags = null //So you can't add condiments
						src.extra_item.loc = get_turf(src) // Eject the extra item so important shit like the disk can't be destroyed in there
						src.extra_item = null

					else //Otherwise it was empty, so just turn it on then off again with nothing happening
						src.operating = 1
						src.icon_state = "mw1"
						src.updateUsrDialog()
						sleep(80)
						src.icon_state = "mw"
						playsound(src.loc, 'ding.ogg', 50, 1)
						src.operating = 0

			if(operation == 2) // If dispose was pressed, empty the microwave
				src.clear()
				src.reagents.clear_reagents()
				if(src.extra_item != null)
					src.extra_item.loc = get_turf(src) // Eject the extra item so important shit like the disk can't be destroyed in there
					src.extra_item = null
				usr << "You dispose of the microwave contents."

			var/cooking = cooked_item // Get the item that needs to be spawned
			if(!isnull(cooking))
				src.operating = 1 // Turn it on so it can't be used again while it's cooking
				src.icon_state = "mw1" //Make it look on too
				src.updateUsrDialog()
				src.being_cooked = new cooking(src)
				use_power(500*(cook_time/50)/2)
				spawn(cook_time) //After the cooking time
					use_power(500*(cook_time/50)/2)
					if(!isnull(src.being_cooked))
						playsound(src.loc, 'ding.ogg', 50, 1)
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/humanburger))
							src.being_cooked.name = humanmeat_name + src.being_cooked.name
							src.being_cooked:job = humanmeat_job
						else if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/humeatpie))
							src.being_cooked.name = humanmeat_name + src.being_cooked.name
							src.being_cooked:job = humanmeat_job
						else if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/humankabob))
							src.being_cooked.name = humanmeat_name + src.being_cooked.name
							src.being_cooked:job = humanmeat_job
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
							src.being_cooked:warm = 1
							src.being_cooked:reagents.add_reagent("tricordrazine", 5)
							src.being_cooked:bitesize = 6
							src.being_cooked.name = "Warm " + src.being_cooked.name
							src.being_cooked:cooltime()
						src.being_cooked.loc = get_turf(src) // Create the new item
						src.being_cooked = null // We're done!

					src.operating = 0 // Turn the microwave back off
					src.icon_state = "mw"
			else
				return

/obj/machinery/microwave/proc/clear()
	src.egg_amount = 0
	src.flour_amount = 0
	src.xenomeat_amount = 0
	src.cheese_amount = 0
	src.water_amount = 0
	src.humanmeat_amount = 0
	src.monkeymeat_amount = 0
	src.donkpocket_amount = 0
	src.milk_amount = 0
	src.hotsauce_amount = 0
	src.coldsauce_amount = 0
	src.soysauce_amount = 0
	src.tofu_amount = 0
	src.ketchup_amount = 0
	src.berryjuice_amount = 0
	src.carpmeat_amount = 0
	src.updateUsrDialog()
	//src.temp.reagents.clear_reagents()
	return