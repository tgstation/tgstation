
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	container_type = OPENCONTAINER_1
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	 "ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
	 "capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
	 "enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes"),
	 "soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring"),
	 "frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in it's passage"),
	 "sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably"),
	 "blackpepper" = list("peppermillsmall", "pepper mill", "Often used to flavor food or make people sneeze"),
	 "cornoil" = list("oliveoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn"),
	 "sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!"),
	 "mayonnaise" = list("mayonnaise", "mayonnaise jar", "An oily condiment made from egg yolks."))
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		to_chat(M, "<span class='notice'>You swallow some of contents of \the [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] attempts to feed [M] from [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		user.visible_message("<span class='warning'>[user] feeds [M] from [src].</span>")
		add_logs(user, M, "fed", reagentlist(src))

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, 10)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	return 1

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/food/condiment/on_reagent_change()
	if(!possible_states.len)
		return
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "[originalname] bottle"
			main_reagent = reagents.get_master_reagent_name()
			if (reagents.reagent_list.len==1)
				desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			else
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."
		return

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar bottle"
	desc = "Tasty spacey sugar!"
	list_reagents = list("sugar" = 50)

/obj/item/reagent_containers/food/condiment/saltshaker		//Separate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/saltshaker/on_reagent_change()
	if(reagents.reagent_list.len == 0)
		icon_state = "emptyshaker"
	else
		icon_state = "saltshakersmall"

/obj/item/reagent_containers/food/condiment/saltshaker/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return (TOXLOSS)

/obj/item/reagent_containers/food/condiment/saltshaker/afterattack(obj/target, mob/living/user, proximity)
	if(!proximity)
		return
	if(isturf(target))
		if(!reagents.has_reagent("sodiumchloride", 2))
			to_chat(user, "<span class='warning'>You don't have enough salt to make a pile!</span>")
			return
		user.visible_message("<span class='notice'>[user] shakes some salt onto [target].</span>", "<span class='notice'>You shake some salt onto [target].</span>")
		reagents.remove_reagent("sodiumchloride", 2)
		new/obj/effect/decal/cleanable/salt(target)
		return
	..()

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/peppermill/on_reagent_change()
	if(reagents.reagent_list.len == 0)
		icon_state = "emptyshaker"
	else
		icon_state = "peppermillsmall"

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list("milk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list("flour" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list("soymilk" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list("rice" = 30)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list("soysauce" = 50)
	possible_states = list()

/obj/item/reagent_containers/food/condiment/mayonnaise
	name = "mayonnaise"
	desc = "An oily condiment made from egg yolks."
	icon_state = "mayonnaise"
	list_reagents = list("mayonnaise" = 50)
	possible_states = list()



//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food"
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list()
	possible_states = list("ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."), "capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"), "soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"), "frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"), "sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"), "blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"), "cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"), "sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!"))

/obj/item/reagent_containers/food/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but there's nothing in it.</span>")
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>" )
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>")
			src.reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)

/obj/item/reagent_containers/food/condiment/pack/on_reagent_change()
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
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list("ketchup" = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list("capsaicin" = 10)
