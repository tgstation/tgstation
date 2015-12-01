
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind
//To clarify, these are special containers used to hold reagents specific to cooking, produced from the Kitchen CondiMaster
/obj/item/weapon/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food.dmi'
	icon_state = "emptycondiment"
	item_state = null
	flags = FPRINT  | OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W as obj, mob/user as mob)

	return

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user as mob)

	attack(user, user)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/living/M as mob, mob/user as mob, def_zone)

	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
		return 0

	if(M == user) //user drinking it

		to_chat(M, "<span class='notice'>You swallow some of the contents of \the [src].</span>")
		if(reagents.total_volume) //Deal with the reagents in the food
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, amount_per_transfer_from_this)

		playsound(M.loc,'sound/items/drink.ogg', rand(10, 50), 1)
		return 1

	else if(istype(M, /mob/living/carbon)) //user feeding M the condiment. M also being carbon

		M.visible_message("<span class='danger'>[user] attempts to feed [M] \the [src]</span>", \
		"<span class='danger'>[user] attempts to feed you \the [src]</span>")

		if(!do_mob(user, M))
			return

		M.visible_message("<span class='danger'>[user] feeds [M] \the [src]</span>", \
		"<span class='danger'>[user] feeds you \the [src]</span>")

		//Logging shit
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(reagents.total_volume) //Deal with the reagents in the food
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, amount_per_transfer_from_this)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/I as obj, mob/user as mob) //We already have an attackby for weapons, but sure, whatever

	return

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , flag)
	if(!flag || ismob(target)) return 0
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume) //Nothing in the dispenser
			to_chat(user, "<span class='warning'>\The [target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume) //Our condiment bottle is full
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You can't add anymore to \the [target].</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to \the [target].</span>")

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change() //Due to the way condiment bottles work, we define "special types" here

	if(reagents.reagent_list.len > 0)

		switch(reagents.get_master_reagent_id())

			if("ketchup")
				name = "ketchup"
				desc = "You feel more American already."
				icon_state = "ketchup"
				item_state = null
			if("capsaicin")
				name = "hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
				item_state = null
			if("enzyme")
				name = "universal enzyme"
				desc = "Used in cooking various dishes."
				icon_state = "enzyme"
				item_state = null
			if("flour")
				name = "flour sack"
				desc = "A big bag of flour. Good for baking!"
				icon_state = "flour"
				item_state = null
			if("milk")
				name = "space milk"
				desc = "It's milk. White and nutritious goodness!"
				icon_state = "milk"
				item_state = "carton"
			if("soymilk")
				name = "soy milk"
				desc = "It's soy milk. White and nutritious goodness!"
				icon_state = "soymilk"
				item_state = "carton"
			if("rice")
				name = "rice sack"
				desc = "A taste of Asia in the kitchen."
				icon_state = "rice"
				item_state = null
			if("soysauce")
				name = "soy sauce"
				desc = "A salty soy-based flavoring."
				icon_state = "soysauce"
				item_state = null
			if("frostoil")
				name = "coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
				item_state = null
			if("sodiumchloride")
				name = "salt shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshakersmall"
				item_state = null
			if("blackpepper")
				name = "pepper mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
				item_state = null
			if("cornoil")
				name = "corn oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = "cornoil"
				item_state = null
			if("sugar")
				name = "sugar"
				desc = "Tastey space sugar!"
				icon_state = "sugar"
				item_state = null
			if("chefspecial")
				name = "\improper Chef Excellence's Special Sauce"
				desc = "A potent sauce distilled from the toxin glands of 1000 Space Carp."
				icon_state = "emptycondiment"
				item_state = null
			if("vinegar")
				name = "malt vinegar bottle"
				desc = "Perfect for fish and chips!"
				icon_state = "vinegar_container"
				item_state = null
			if("honey")
				name = "honey pot"
				desc = "Sweet and healthy!"
				icon_state = "honey"
				item_state = null
			if("cinnamon")
				name = "cinnamon shaker"
				desc = "A spice, obtained from the bark of cinnamomum trees."
				icon_state = "cinnamon"
				item_state = null
			else
				name = "misc condiment bottle"
				desc = "Just your average condiment container."
				icon_state = "emptycondiment"
				item_state = null

				if(reagents.reagent_list.len == 1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
				icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."
		return

//Specific condiment bottle entities for mapping and potentially spawning (these are NOT used for any above procs)

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"

	New()
		..()
		reagents.add_reagent("enzyme", 50)

/obj/item/weapon/reagent_containers/food/condiment/sugar

	New()
		..()
		reagents.add_reagent("sugar", 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1, 50) //For clowns turning the lid off.
	amount_per_transfer_from_this = 1

	New()
		..()
		reagents.add_reagent("sodiumchloride", 50)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1, 50) //For clowns turning the lid off.
	amount_per_transfer_from_this = 1

	New()
		..()
		reagents.add_reagent("blackpepper", 50)

/obj/item/weapon/reagent_containers/food/condiment/syndisauce
	name = "Chef Excellence's Special Sauce"
	desc = "A potent sauce distilled from the toxin glands of 1000 Space Carp with an extra touch of LSD, because why not?"
	amount_per_transfer_from_this = 1

	New()
		..()
		reagents.add_reagent("chefspecial", 20)

/obj/item/weapon/reagent_containers/food/condiment/vinegar
	name = "malt vinegar bottle"
	desc = "Perfect for fish and chips."
	New()
		..()
		reagents.add_reagent("vinegar", 50)

/obj/item/weapon/reagent_containers/food/condiment/exotic
	name = "exotic bottle"
	desc = "If you can see this label, something is wrong."
	//~9% chance of anything but special sauce, which is .09 chance
	var/global/list/possible_exotic_condiments = list("enzyme"=10,"blackpepper"=10,"vinegar"=10,"sodiumchloride"=10,"cinnamon"=10,"chefspecial"=1,"frostoil"=10,"soysauce"=10,"capsaicin"=10,"honey"=10,"ketchup"=10,"coco"=10)
	New()
		..()
		reagents.add_reagent(pickweight(possible_exotic_condiments), 30)
