obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.contents.len > 0)
		user << "Something is already in the processing chamber."
		return 0
	else
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/chili) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/tomato) || istype(O, /obj/item/weapon/reagent_containers/food/drinks/milk))
			user.drop_item()
			O.loc = src
		else if(istype(O,/obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = O
			if(istype(G.affecting, /mob/living/carbon/alien/larva/metroid))
				G.affecting.loc = src
				user.drop_item()
		else
			user << "That probably won't blend."
			return 0



/obj/machinery/processor/attack_hand(user as mob)
	if(src.processing)
		user << "The processor is in the process of processing."
		return
	for(var/obj/O in src.contents)
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
			src.processing = 1
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/flour(src.loc)
			src.processing = 0
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/milk))
			src.processing = 1
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/cheesewheel(src.loc)
			src.processing = 0
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/chili))
			src.processing = 1
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/hotsauce(src.loc)
			src.processing = 0
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/tomato))
			src.processing = 1
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/ketchup(src.loc)
			src.processing = 0
			return
	for(var/mob/O in src.contents)
		if(istype(O, /mob/living/carbon/alien/larva/metroid))
			src.processing = 1
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			var/mob/dead/observer/newmob
			if (O.client)
				newmob = new/mob/dead/observer(O)
				O:client:mob = newmob
				newmob:client:eye = newmob
			del(O)
			new /obj/item/weapon/reagent_containers/food/drinks/jar(src.loc)
			src.processing = 0
			return
	user << "There doesn't appear to be anything in the processing chamber."
/*
/obj/machinery/processor/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(istype(G.affecting, /mob/living/carbon/alien/larva/metroid))
		sleep(40)
		playsound(src.loc, 'blender.ogg', 50, 1)
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] turns on \a [src]."))
		var/mob/dead/observer/newmob
		if (G.affecting.client)
			newmob = new/mob/dead/observer(G.affecting)
			G.affecting:client:mob = newmob
			newmob:client:eye = newmob
		del(G.affecting)
		del(G)
		new /obj/item/weapon/reagent_containers/food/drinks/jar(src.loc)
*/
/*
/obj/item/weapon/reagent_containers/food/snacks/grown/berries

/obj/item/weapon/reagent_containers/food/snacks/grown/chili

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
*/


/obj/item/weapon/reagent_containers/food/snacks/ketchup
	name = "ketchup"
	desc = "You feel more American already."
	icon_state = "ketchup"
	amount = 1

/obj/item/weapon/reagent_containers/food/snacks/hotsauce
	name = "hotsauce"
	desc = "You can almost TASTE the stomach ulcers now!"
	icon_state = "hotsauce"
	amount = 1