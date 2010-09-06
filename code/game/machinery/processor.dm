obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.contents.len > 0)
		user << "Something is already in the processing chamber."
		return 0
	else
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/chili) || istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/tomato) || istype(O, /obj/item/weapon/reagent_containers/food/drinks/milk))
			user.drop_item()
			O.loc = src
		else
			user << "That probably won't blend."
			return 0



/obj/machinery/processor/attack_hand(user as mob)
	for(var/obj/O in src.contents)
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/flour(src.loc)
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/chili))
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/hotsauce(src.loc)
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/tomato))
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/ketchup(src.loc)
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/milk))
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/cheesewheel(src.loc)
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans))
			sleep(40)
			playsound(src.loc, 'blender.ogg', 50, 1)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] turns on \a [src]."))
			del(O)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeymeat(src.loc)
			return
	user << "There doesn't appear to be anything in the processing chamber."



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