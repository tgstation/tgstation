///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/list/blocked = list(
		/obj/item/food/drug,
		/obj/item/food/spaghetti,
		/obj/item/food/bread,
		/obj/item/food/breadslice,
		/obj/item/food/cake,
		/obj/item/food/cakeslice,
		/obj/item/food/pie,
		/obj/item/food/pieslice,
		/obj/item/food/kebab,
		/obj/item/food/pizza,
		/obj/item/food/pizzaslice,
		/obj/item/food/salad,
		/obj/item/food/meat,
		/obj/item/food/meat/slab,
		/obj/item/food/soup,
		/obj/item/food/grown,
		/obj/item/food/grown/mushroom,
		/obj/item/food/deepfryholder,
		/obj/item/food/clothing,
		/obj/item/food/meat/slab/human/mutant,
		/obj/item/food/grown/ash_flora,
		/obj/item/food/grown/nettle,
		/obj/item/food/grown/shell
		)

	return pick(subtypesof(/obj/item/food) - blocked)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/list/blocked = list(
		/obj/item/reagent_containers/food/drinks/soda_cans,
		/obj/item/reagent_containers/food/drinks/bottle
		)
	return pick(subtypesof(/obj/item/reagent_containers/food/drinks) - blocked)

///Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ion_num() //! is at the start to prevent us from changing say modes via get_message_mode()
	return "![pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

///Returns a string for a random nuke code
/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str
