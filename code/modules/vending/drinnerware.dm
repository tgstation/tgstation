/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Dinnerware Vendor"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/storage/bag/tray = 8,
		            /obj/item/kitchen/fork = 6,
		            /obj/item/kitchen/knife = 6,
		            /obj/item/kitchen/rollingpin = 2,
		            /obj/item/reagent_containers/food/drinks/drinkingglass = 8,
		            /obj/item/clothing/suit/apron/chef = 2,
		            /obj/item/reagent_containers/food/condiment/pack/ketchup = 5,
		            /obj/item/reagent_containers/food/condiment/pack/hotsauce = 5,
		            /obj/item/reagent_containers/food/condiment/saltshaker = 5,
		            /obj/item/reagent_containers/food/condiment/peppermill = 5,
		            /obj/item/reagent_containers/glass/bowl = 20)
	contraband = list(/obj/item/kitchen/rollingpin = 2,
		              /obj/item/kitchen/knife/butcher = 2)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	default_price = 30
	extra_price = 50
	payment_department = ACCOUNT_SRV
