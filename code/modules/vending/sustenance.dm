/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Even prisoners deserve their daily bread!;Have some more candy corn!;Try our new ice cups!"
	light_mask = "snack-light-mask"
	icon_state = "sustenance"
	products = list(
		/obj/item/food/tofu/prison = 24,
		/obj/item/food/breadslice/moldy = 15,
		/obj/item/reagent_containers/food/drinks/ice/prison = 12,
		/obj/item/food/candy_corn/prison = 6,
		/obj/item/kitchen/spoon/plastic = 6,
	)
	contraband = list(
		/obj/item/kitchen/knife = 6,
		/obj/item/kitchen/spoon = 6,
		/obj/item/reagent_containers/food/drinks/coffee = 12,
		/obj/item/tank/internals/emergency_oxygen = 6,
		/obj/item/clothing/mask/breath = 6,
	)

	refill_canister = /obj/item/vending_refill/sustenance
	default_price = PAYCHECK_PRISONER
	extra_price = PAYCHECK_PRISONER * 0.6
	payment_department = NO_FREEBIES

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"
	icon_state = "refill_snack"
