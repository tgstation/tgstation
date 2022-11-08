/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	panel_type = "panel4"
	products = list(
		/obj/item/storage/bag/tray = 8,
		/obj/item/reagent_containers/cup/bowl = 20,
		/obj/item/kitchen/fork = 6,
		/obj/item/kitchen/spoon = 6,
		/obj/item/reagent_containers/cup/glass/drinkingglass = 8,
		/obj/item/reagent_containers/condiment/pack/ketchup = 5,
		/obj/item/reagent_containers/condiment/pack/hotsauce = 5,
		/obj/item/reagent_containers/condiment/pack/astrotame = 5,
		/obj/item/reagent_containers/condiment/saltshaker = 5,
		/obj/item/reagent_containers/condiment/peppermill = 5,
		/obj/item/clothing/suit/apron/chef = 2,
		/obj/item/kitchen/rollingpin = 2,
		/obj/item/knife/kitchen = 2,
		/obj/item/book/granter/crafting_recipe/cooking_sweets_101 = 2,
		/obj/item/skillchip/chefs_kiss = 2,
		/obj/item/plate/small = 5,
		/obj/item/plate = 10,
		/obj/item/plate/large = 5,
	)
	contraband = list(
		/obj/item/kitchen/rollingpin/illegal = 2,
		/obj/item/knife/butcher = 2,
	)
	refill_canister = /obj/item/vending_refill/dinnerware
	default_price = PAYCHECK_CREW * 0.8
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SRV
	light_mask = "dinnerware-light-mask"

/obj/item/vending_refill/dinnerware
	machine_name = "Plasteel Chef's Dinnerware Vendor"
	icon_state = "refill_smoke"
