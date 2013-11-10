
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/weapon/reagent_containers/food/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food.dmi'
	icon_state = "emptycondiment"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50
	//Possible_icon_states has the reagents as key and a list of, in order, the icon_state, the name and the desc as values.
	var/list/possible_icon_states = list("ketchup" = list("ketchup", "Ketchup", "You feel more American already."), "capsaicin" = list("hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"), "enzyme" = list("enzyme", "Universal Enzyme", "Used in cooking various dishes"), "soysauce" = list("soysauce", "Soy Sauce", "A salty soy-based flavoring"), "frostoil" = list("coldsauce", "Coldsauce", "Leaves the tongue numb in it's passage"), "sodiumchloride" = list("saltshaker", "Salt Shaker", "Salt. From space oceans, presumably"), "blackpepper" = list("pepermillsmall", "Pepper Mill", "Often used to flavor food or make people sneeze"), "cornoil" = list("oliveoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"), "sugar" = list("emptycondiment", "Sugar", "Tasty spacey sugar!"))

/obj/item/weapon/reagent_containers/food/condiment/New()
	..()
	

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		user << "\red None of [src] left, oh no!"
		return 0

	if(M == user)
		M << "\blue You swallow some of contents of the [src]."
		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	else if( istype(M, /mob/living/carbon/human) )

		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] attempts to feed [M] [src].", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] feeds [M] [src].", 1)

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")


		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/I as obj, mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			user << "\red [target] is empty."
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "\red [src] is full."
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		user << "\blue You fill [src] with [trans] units of the contents of [target]."

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "\red [src] is empty."
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "\red you can't add anymore to [target]."
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		user << "\blue You transfer [trans] units of the condiment to [target]."

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change()
	if(icon_state == "saltshakersmall" || icon_state == "peppermillsmall")
		return
	if(reagents.reagent_list.len > 0)
		if(reagents.get_master_reagent_id() in possible_icon_states)
			if("ketchup")
				name = "Ketchup"
				desc = "You feel more American already."
				icon_state = "ketchup"
			if("capsaicin")
				name = "Hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
			if("enzyme")
				name = "Universal Enzyme"
				desc = "Used in cooking various dishes."
				icon_state = "enzyme"
			if("soysauce")
				name = "Soy Sauce"
				desc = "A salty soy-based flavoring."
				icon_state = "soysauce"
			if("frostoil")
				name = "Coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
			if("sodiumchloride")
				name = "Salt Shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshaker"
			if("blackpepper")
				name = "Pepper Mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
			if("cornoil")
				name = "Corn Oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = "oliveoil"
			if("sugar")
				name = "Sugar"
				desc = "Tastey space sugar!"
			else
				name = "Misc Condiment Bottle"
				if (reagents.reagent_list.len==1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
				icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "Condiment Bottle"
		desc = "An empty condiment bottle."
		return

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"

	New()
		..()
		reagents.add_reagent("enzyme", 50)

/obj/item/weapon/reagent_containers/food/condiment/sugar

	New()
		..()
		reagents.add_reagent("sugar", 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "Salt Shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20

	New()
		..()
		reagents.add_reagent("sodiumchloride", 20)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "Pepper Mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20

	New()
		..()
		reagents.add_reagent("blackpepper", 20)

//Food packs. To easily apply deadly toxi... delicious sauces to your food!
/obj/item/weapon/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic bag to put on your food"
	icon_state = "blankbag"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = 10
	flags = FPRINT | TABLEPASS

/obj/item/weapon/reagent_containers/food/condiment/pack/attack(mob/M as mob, mob/user as mob, def_zone) //Can't feed these to people directly.
	return

/obj/item/weapon/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return

	//You can tear the bag open above food to put the condiments on it.
	else if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "<span class='warning'>You tear open the [src], but there's nothing in it.</span>"
			Del()
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>"
			return
		user << "<span class='notice'>You tear open the [src] above [target] and the condiments drip onto it.</span>"
		src.reagents.trans_to(target, amount_per_transfer_from_this)