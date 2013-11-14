/obj/item/weapon/vending_refill
	name = "Resupply canister"
	var/machine = "Generic"

	icon = 'icons/obj/storage.dmi'
	icon_state = "box"
	item_state = "box"
	desc = ""
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 7.0
	throwforce = 15.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0

	var/list/products	= list()	//use the following pattern:list(/type/path = amount,/type/path2 = amount2)
									//No specified amount = only one in stock

/obj/item/weapon/vending_refill/proc/build_inventory(list/productlist)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount)) amount = 1

		var/atom/temp = new typepath(null)
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.product_name = initial(temp.name)
		R.product_path = typepath
		R.amount = amount
		products += R

/obj/item/weapon/vending_refill/New()
	//Build the inventory on creation, like vending machines do.
	name = "[machine] restocking canister"
	build_inventory(products)

/obj/item/weapon/vending_refill/examine()
	set src in usr
	usr << "[src] \icon[src] restocking canister for a [machine] machine"
	usr << "It contains the following:"

	var/count = 0
	for(var/datum/data/vending_product/content in products)
		if(content.amount > 0)
			usr << "[content.amount] [content.product_name]"
			count++
	if(!count)
		usr << "Nothing!"

//NOTE I decided to go for about 1/3 of a machine's capacity
/obj/item/weapon/vending_refill/boozeomat
	machine = "Booze-O-Mat"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 1,
					/obj/item/weapon/reagent_containers/food/drinks/beer = 2,
					/obj/item/weapon/reagent_containers/food/drinks/ale = 2,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 1,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 1,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/tonic = 2,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cola = 2,
					/obj/item/weapon/reagent_containers/food/drinks/soda_cans/sodawater = 5,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 10,
					/obj/item/weapon/reagent_containers/food/drinks/ice = 3,
					/obj/item/weapon/reagent_containers/food/drinks/tea = 3)