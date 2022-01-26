/datum/autowiki/vending
	page = "Template:Autowiki/VendingMachines"

/datum/autowiki/vending/generate()
	var/output = ""

	var/list/cached_products = list()

	// `powered()` checks if its in a null loc to say it's not powered.
	// So we put it inside, something
	var/obj/parent = new

	// MOTHBLOCKS TODO: Stable sort
	for (var/vending_type in subtypesof(/obj/machinery/vending))
		var/obj/machinery/vending/vending_machine = new vending_type(parent)
		vending_machine.use_power = FALSE
		vending_machine.update_icon(UPDATE_ICON_STATE)

		// Technically won't match if product amounts change, but this isn't likely
		var/products_cache_key = vending_machine.products.Join("-") + "&" + vending_machine.contraband.Join("-") + "&" + vending_machine.premium.Join("-")

		// MOTHBLOCKS TODO: Show all vending machines that have the same products?
		if (products_cache_key in cached_products)
			qdel(vending_machine)
			continue

		cached_products += products_cache_key

		var/filename = SANITIZE_FILENAME(escape_value(format_text(vending_machine.name)))

		output += include_template("Autowiki/VendingMachine", list(
			"icon" = escape_value(filename),
			"name" = escape_value(format_text(vending_machine.name)),
			"products" = format_product_list(vending_machine.products),
			"contraband" = format_product_list(vending_machine.contraband),
			"premium" = format_product_list(vending_machine.premium),
		))

		// It would be cool to make this support gifs someday, but not now
		upload_icon(getFlatIcon(vending_machine, no_anim = TRUE), filename)

		qdel(vending_machine)

	qdel(parent)

	return output

/datum/autowiki/vending/proc/format_product_list(list/product_list)
	var/output = ""

	for (var/obj/product_path as anything in product_list)
		output += include_template("Autowiki/VendingMachineProduct", list(
			"name" = escape_value(capitalize(format_text(initial(product_path.name)))),
			"amount" = product_list[product_path],
		))

	return output
