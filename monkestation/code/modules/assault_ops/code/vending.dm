//VENDING MACHINES
/obj/machinery/vending/assaultops_ammo
	name = "\improper Syndicate Ammo Station"
	desc = "An ammo vending machine which holds a variety of different ammo mags."
	icon_state = "liberationstation"
	vend_reply = "Item dispensed."
	scan_id = FALSE
	resistance_flags = FIRE_PROOF
	onstation = FALSE
	light_mask = "liberation-light-mask"
	default_price = 0
	/// Have we been FILLED?
	var/filled = FALSE

/obj/machinery/vending/assaultops_ammo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		fill_ammo(user)
		ui = new(user, src, "Vending")
		ui.open()

/obj/machinery/vending/assaultops_ammo/proc/fill_ammo(mob/user)
	if(last_shopper == user && filled)
		return
	else
		filled = FALSE

	if(!ishuman(user))
		return FALSE

	if(!user.mind.has_antag_datum(/datum/antagonist/assault_operative))
		return FALSE

	//Remove all current items from the vending machine
	products.Cut()
	product_records.Cut()

	var/mob/living/carbon/human/human_user = user

	//Find all the ammo we should display
	for(var/object in human_user.contents)
		if(istype(object, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/gun = object
			if(!gun.internal_magazine)
				products.Add(gun.spawn_magazine_type)
		if(istype(object, /obj/item/storage))
			var/obj/item/storage/storage = object
			for(var/storage_item in storage.contents)
				if(istype(storage_item, /obj/item/gun/ballistic))
					var/obj/item/gun/ballistic/gun = storage_item
					if(!gun.internal_magazine)
						products.Add(gun.spawn_magazine_type)

	//Add our items to the list of products
	build_inventory(products, product_records, FALSE)

	filled = TRUE

/obj/machinery/vending/assaultops_ammo/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	default_price = 0
	extra_price = 0
	for(var/typepath in productlist)
		var/amount = 4
		var/atom/temp = typepath
		var/datum/data/vending_product/vending_product = new /datum/data/vending_product()

		vending_product.name = initial(temp.name)
		vending_product.product_path = typepath
		if(!start_empty)
			vending_product.amount = amount
		vending_product.max_amount = amount
		vending_product.custom_price = 0
		vending_product.custom_premium_price = 0
		vending_product.age_restricted = FALSE
		recordlist += vending_product
