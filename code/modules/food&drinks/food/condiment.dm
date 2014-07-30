
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
	flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list("ketchup" = list("ketchup", "Ketchup", "You feel more American already."), "capsaicin" = list("hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"), "enzyme" = list("enzyme", "Universal Enzyme", "Used in cooking various dishes"), "soysauce" = list("soysauce", "Soy Sauce", "A salty soy-based flavoring"), "frostoil" = list("coldsauce", "Coldsauce", "Leaves the tongue numb in it's passage"), "sodiumchloride" = list("saltshaker", "Salt Shaker", "Salt. From space oceans, presumably"), "blackpepper" = list("pepermillsmall", "Pepper Mill", "Often used to flavor food or make people sneeze"), "cornoil" = list("oliveoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"), "sugar" = list("emptycondiment", "Sugar", "Tasty spacey sugar!"))

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		user << "<span class='warning'>None of [src] left, oh no!</span>"
		return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		M << "<span class='notice'>You swallow some of contents of the [src].</span>"
		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, 10)
		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1

	else if( istype(M, /mob/living/carbon/human) )
		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] attempts to feed [M] [src].</span>", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] feeds [M] [src].</span>", 1)

		add_logs(user, M, "fed", object="[reagentlist(src)]")

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
			user << "<span class='warning'>[target] is empty.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='warning'>[src] is full.</span>"
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		user << "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>"

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "<span class='warning'>[src] is empty.</span>"
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='warning'>you can't add anymore to [target].</span>"
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		user << "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>"

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change()
	if(icon_state == "saltshakersmall" || icon_state == "peppermillsmall")
		return
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "misc Condiment Bottle"
			main_reagent = reagents.get_master_reagent_name()
			if (reagents.reagent_list.len==1)
				desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			else
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment Bottle"
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
	desc = "A small plastic pack with condiments to put on your food"
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	possible_states = list("ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."), "capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"), "soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"), "frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"), "sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"), "blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"), "cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"), "sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!"))
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/weapon/reagent_containers/food/condiment/pack/New()
	..()
	pixel_x = rand(-7, 7)
	pixel_y = rand(-7, 7)

/obj/item/weapon/reagent_containers/food/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/weapon/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "<span class='warning'>You tear open [src], but there's nothing in it.</span>"
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>" //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return
		else
			user << "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>"
			src.reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)

/obj/item/weapon/reagent_containers/food/condiment/pack/on_reagent_change()
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = "A small condiment pack. The label says it contains [originalname]"
	else
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."

//Ketchup
/obj/item/weapon/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"

/obj/item/weapon/reagent_containers/food/condiment/pack/ketchup/New()
		..()
		reagents.add_reagent("ketchup", 10)

//Hot sauce
/obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"

/obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce/New()
		..()
		reagents.add_reagent("capsaicin", 10)
