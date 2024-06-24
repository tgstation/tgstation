///the minimum size of a pill or patch
#define MIN_VOLUME 5
///the maximum size a pill or patch can be
#define MAX_VOLUME 50
///max amount of pills allowed on our tile before we start storing them instead
#define MAX_FLOOR_PRODUCTS 10

///We take a constant input of reagents, and produce a pill once a set volume is reached
/obj/machinery/plumbing/pill_press
	name = "chemical press"
	desc = "A press that makes pills, patches and bottles."
	icon_state = "pill_press"

	/// current operating product (pills or patches)
	var/product = "pill"
	/// selected size of the product
	var/current_volume = 10
	/// prefix for the product name
	var/product_name = "factory"
	/// All packaging types wrapped up in 1 big list
	var/static/list/packaging_types = null
	///The type of packaging to use
	var/packaging_type
	///Category of packaging
	var/packaging_category
	/// list of products stored in the machine, so we dont have 610 pills on one tile
	var/list/stored_products = list()

/obj/machinery/plumbing/pill_press/Initialize(mapload, bolt, layer)
	. = ..()

	if(!packaging_types)
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/chemmaster)

		var/list/types = list(
			CAT_PILLS = GLOB.reagent_containers[CAT_PILLS],
			CAT_PATCHES = GLOB.reagent_containers[CAT_PATCHES],
			"Bottles" = list(/obj/item/reagent_containers/cup/bottle),
		)

		packaging_types = list()
		for(var/category in types)
			var/list/packages = types[category]

			var/list/category_item = list("cat_name" = category)
			for(var/obj/item/reagent_containers/container as anything in packages)
				var/list/package_item = list(
					"class_name" = assets.icon_class_name(sanitize_css_class_name("[container]")),
					"ref" = REF(container)
				)
				category_item["products"] += list(package_item)

			packaging_types += list(category_item)

	packaging_type = REF(GLOB.reagent_containers[CAT_PILLS][1])
	decode_category()

	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

/obj/machinery/plumbing/pill_press/examine(mob/user)
	. = ..()
	. += span_notice("The [name] currently has [stored_products.len] stored. There needs to be less than [MAX_FLOOR_PRODUCTS] on the floor to continue dispensing.")

/// decode product category from it's type path and returns the decoded typepath
/obj/machinery/plumbing/pill_press/proc/decode_category()
	var/obj/item/reagent_containers/container = locate(packaging_type)
	if(ispath(container, /obj/item/reagent_containers/pill/patch))
		packaging_category = CAT_PATCHES
	else if(ispath(container, /obj/item/reagent_containers/pill))
		packaging_category = CAT_PILLS
	else
		packaging_category = "Bottles"
	return container

/obj/machinery/plumbing/pill_press/process(seconds_per_tick)
	if(!is_operational)
		return

	//shift & check to account for floating point inaccuracies
	if(reagents.total_volume >= current_volume)
		var/obj/item/reagent_containers/container = locate(packaging_type)
		container = new container(src)
		var/suffix
		switch(packaging_category)
			if(CAT_PILLS)
				suffix = "Pill"
			if(CAT_PATCHES)
				suffix = "Patch"
			else
				suffix = "Bottle"
		container.name = "[product_name] [suffix]"
		reagents.trans_to(container, current_volume)
		stored_products += container

	//dispense stored products on the floor
	if(stored_products.len)
		var/pill_amount = 0
		for(var/obj/item/reagent_containers/thing in loc)
			pill_amount++
			if(pill_amount >= MAX_FLOOR_PRODUCTS) //too much so just stop
				break
		if(pill_amount < MAX_FLOOR_PRODUCTS && anchored)
			var/atom/movable/AM = stored_products[1] //AM because forceMove is all we need
			stored_products -= AM
			AM.forceMove(drop_location())

	use_energy(active_power_usage * seconds_per_tick)

/obj/machinery/plumbing/pill_press/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chemmaster)
	)

/obj/machinery/plumbing/pill_press/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemPress", name)
		ui.open()

/obj/machinery/plumbing/pill_press/ui_static_data(mob/user)
	var/list/data = list()

	data["min_volume"] = MIN_VOLUME
	data["max_volume"] = MAX_VOLUME
	data["packaging_types"] = packaging_types

	return data

/obj/machinery/plumbing/pill_press/ui_data(mob/user)
	var/list/data = list()

	data["current_volume"] = current_volume
	data["product_name"] = product_name
	data["packaging_type"] = packaging_type
	data["packaging_category"] = packaging_category

	return data

/obj/machinery/plumbing/pill_press/ui_act(action, params)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("change_current_volume")
			current_volume = round(clamp(text2num(params["volume"]), MIN_VOLUME, MAX_VOLUME))
		if("change_product_name")
			var/formatted_name = html_encode(params["name"])
			if (length(formatted_name) > MAX_NAME_LEN)
				product_name = copytext(formatted_name, 1, MAX_NAME_LEN + 1)
			else
				product_name = formatted_name
		if("change_product")
			packaging_type = params["ref"]
			var/obj/item/reagent_containers/container = decode_category()
			current_volume = clamp(current_volume, MIN_VOLUME, initial(container.volume))

#undef MIN_VOLUME
#undef MAX_VOLUME
#undef MAX_FLOOR_PRODUCTS
