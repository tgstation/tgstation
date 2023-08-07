/obj/machinery/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Even prisoners deserve their daily bread!;Have some more candy corn!;Try our new ice cups!"
	light_mask = "snack-light-mask"
	icon_state = "sustenance"
	panel_type = "panel2"
	products = list(
		/obj/item/food/tofu/prison = 24,
		/obj/item/food/breadslice/moldy = 15,
		/obj/item/reagent_containers/cup/glass/ice/prison = 12,
		/obj/item/food/candy_corn/prison = 6,
		/obj/item/kitchen/spoon/plastic = 6,
	)
	contraband = list(
		/obj/item/knife = 6,
		/obj/item/kitchen/spoon = 6,
		/obj/item/reagent_containers/cup/glass/coffee = 12,
		/obj/item/tank/internals/emergency_oxygen = 6,
		/obj/item/clothing/mask/breath = 6,
	)

	refill_canister = /obj/item/vending_refill/sustenance
	default_price = PAYCHECK_LOWER
	extra_price = PAYCHECK_LOWER * 0.6
	payment_department = NO_FREEBIES

/obj/item/vending_refill/sustenance
	machine_name = "Sustenance Vendor"
	icon_state = "refill_snack"

//Labor camp subtype that uses labor points obtained from mining and processing ore
/obj/machinery/vending/sustenance/labor_camp
	name = "\improper Labor Camp Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement. \
			This one, however, processes labor points for its products if the user is incarcerated."
	icon_state = "sustenance_labor"
	onstation_override = TRUE
	displayed_currency_icon = "digging"
	displayed_currency_name = " LP"

/obj/machinery/vending/sustenance/interact(mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!(machine_stat & NOPOWER) && !istype(living_user.get_idcard(TRUE), /obj/item/card/id/advanced/prisoner))
			speak("No valid labor points account found. Vending is not permitted.")
			return
	return ..()

/obj/machinery/vending/sustenance/proceed_payment(obj/item/card/id/paying_id_card, datum/data/vending_product/product_to_vend, price_to_use)
	if(!istype(paying_id_card, /obj/item/card/id/advanced/prisoner))
		speak("I don't take bribes! Pay with labor points!")
		return FALSE
	var/obj/item/card/id/advanced/prisoner/paying_scum_id = paying_id_card
	if(coin_records.Find(product_to_vend) || hidden_records.Find(product_to_vend))
		price_to_use = product_to_vend.custom_premium_price ? product_to_vend.custom_premium_price : extra_price
	if(LAZYLEN(product_to_vend.returned_products))
		price_to_use = 0 //returned items are free
	if(price_to_use && !(paying_scum_id.points >= price_to_use)) //not enough good prisoner points
		speak("You do not possess enough points to purchase [product_to_vend.name].")
		flick(icon_deny, src)
		vend_ready = TRUE
		return FALSE

	paying_scum_id.points -= price_to_use
	return TRUE

/obj/machinery/vending/sustenance/fetch_balance_to_use(obj/item/card/id/passed_id)
	if(!istype(passed_id, /obj/item/card/id/advanced/prisoner))
		return null //no points balance - no balance at all
	var/obj/item/card/id/advanced/prisoner/paying_scum_id = passed_id
	return paying_scum_id.points
