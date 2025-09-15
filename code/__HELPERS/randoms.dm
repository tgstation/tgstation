///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/static/list/allowed_food = list()

	if(!LAZYLEN(allowed_food)) //it's static so we only ever do this once
		var/list/blocked = list() // This used to be populated

		allowed_food = get_sane_item_types(/obj/item/food) - blocked

	return pick(allowed_food)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/static/list/allowed_drinks = list()

	if(!LAZYLEN(allowed_drinks))
		var/list/blocked = list(
			/obj/item/reagent_containers/cup/glass/bottle
		)

		allowed_drinks = get_sane_item_types(/obj/item/reagent_containers/cup/glass) + get_sane_item_types(/obj/item/reagent_containers/cup/soda_cans) - blocked

	return pick(allowed_drinks)

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

///Gets a random coin excluding the blocked type and including extra coins which aren't pathed like coins.
/proc/get_random_coin()
	var/list/blocked = list(
		/obj/item/coin/gold/debug,
		/obj/item/coin/eldritch,
		/obj/item/coin/mythril,
	)
	var/list/extra_coins = list(
		/obj/item/food/chococoin,
	)
	var/list/allowed_coins = subtypesof(/obj/item/coin) - blocked + extra_coins
	return pick(allowed_coins)
