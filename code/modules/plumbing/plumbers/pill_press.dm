///maximum size of a pill
#define MAX_PILL_VOLUME 50
///maximum size of a patch
#define MAX_PATCH_VOLUME 40
///maximum size of a bottle
#define MAX_BOTTLE_VOLUME 50
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
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

	///current operating product (pills or patches)
	var/product = "pill"
	///selected size of the product
	var/current_volume = 10
	///prefix for the product name
	var/product_name = "factory"
	///pill styles used by plumbing pill press factory format = list("id" = <id of this pill>, "class_name" = <class name inside spritesheet>)
	var/static/list/pill_styles = null
	///the icon_state number for the pill.
	var/pill_number = RANDOM_PILL_STYLE
	/// patch styles used by plumbing pill press factory format = list("style" = <string patch style>, "class_name" = <class name inside spritesheet>)
	var/static/list/patch_styles = null
	/// Currently selected patch style
	var/patch_style = DEFAULT_PATCH_STYLE
	///list of products stored in the machine, so we dont have 610 pills on one tile
	var/list/stored_products = list()

/obj/machinery/plumbing/pill_press/Initialize(mapload, bolt, layer)
	. = ..()

	//initialize these static lists only once
	if(!pill_styles || !patch_styles)
		//init pill styles
		var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
		pill_styles = list()
		for (var/x in 1 to PILL_STYLE_COUNT)
			var/list/SL = list()
			SL["id"] = x
			SL["class_name"] = assets.icon_class_name("pill[x]")
			pill_styles += list(SL)

		//init patch styles
		var/datum/asset/spritesheet/simple/patches_assets = get_asset_datum(/datum/asset/spritesheet/simple/patches)
		patch_styles = list()
		for (var/raw_patch_style in PATCH_STYLE_LIST)
			//adding class_name for use in UI
			var/list/patch_style = list()
			patch_style["style"] = raw_patch_style
			patch_style["class_name"] = patches_assets.icon_class_name(raw_patch_style)
			patch_styles += list(patch_style)

	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

/obj/machinery/plumbing/pill_press/examine(mob/user)
	. = ..()
	. += span_notice("The [name] currently has [stored_products.len] stored. There needs to be less than [MAX_FLOOR_PRODUCTS] on the floor to continue dispensing.")

/obj/machinery/plumbing/pill_press/process(seconds_per_tick)
	if(machine_stat & NOPOWER)
		return

	//round & check to account for floating point inaccuracies
	if(ROUND_UP(reagents.total_volume) >= current_volume)
		if (product == "pill")
			var/obj/item/reagent_containers/pill/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] pill")
			stored_products += P
			if(pill_number == RANDOM_PILL_STYLE)
				P.icon_state = "pill[rand(1,21)]"
			else
				P.icon_state = "pill[pill_number]"
			if(P.icon_state == "pill4") //mirrored from chem masters
				P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
		else if (product == "patch")
			var/obj/item/reagent_containers/pill/patch/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] patch")
			P.icon_state = patch_style
			stored_products += P
		else if (product == "bottle")
			var/obj/item/reagent_containers/cup/bottle/P = new(src)
			reagents.trans_to(P, current_volume)
			P.name = trim("[product_name] bottle")
			stored_products += P

	//dispense stored products on the floor
	if(stored_products.len)
		var/pill_amount = 0
		for(var/thing in loc)
			if(!istype(thing, /obj/item/reagent_containers/cup/bottle) && !istype(thing, /obj/item/reagent_containers/pill))
				continue
			pill_amount++
			if(pill_amount >= MAX_FLOOR_PRODUCTS) //too much so just stop
				break
		if(pill_amount < MAX_FLOOR_PRODUCTS && anchored)
			var/atom/movable/AM = stored_products[1] //AM because forceMove is all we need
			stored_products -= AM
			AM.forceMove(drop_location())

	use_power(active_power_usage * seconds_per_tick)

/obj/machinery/plumbing/pill_press/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
		get_asset_datum(/datum/asset/spritesheet/simple/patches),
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
	data["pill_styles"] = pill_styles
	data["patch_styles"] = patch_styles
	return data

/obj/machinery/plumbing/pill_press/ui_data(mob/user)
	var/list/data = list()

	data["pill_style"] = pill_number
	data["current_volume"] = current_volume
	data["product_name"] = product_name
	data["product"] = product
	data["patch_style"] = patch_style

	return data

/obj/machinery/plumbing/pill_press/ui_act(action, params)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("change_pill_style")
			pill_number = clamp(text2num(params["id"]), 1 , PILL_STYLE_COUNT)
		if("change_current_volume")
			current_volume = round(clamp(text2num(params["volume"]), MIN_VOLUME, MAX_VOLUME))
		if("change_product_name")
			var/formatted_name = html_encode(params["name"])
			if (length(formatted_name) > MAX_NAME_LEN)
				product_name = copytext(formatted_name, 1, MAX_NAME_LEN+1)
			else
				product_name = formatted_name
		if("change_product")
			product = params["product"]
			var/max_volume
			if (product == "pill")
				max_volume = MAX_PILL_VOLUME
			else if (product == "patch")
				max_volume = MAX_PATCH_VOLUME
			else if (product == "bottle")
				max_volume = MAX_BOTTLE_VOLUME
			else
				return
			current_volume = clamp(current_volume, MIN_VOLUME, max_volume)
		if("change_patch_style")
			patch_style = params["patch_style"]

#undef MAX_PILL_VOLUME
#undef MAX_PATCH_VOLUME
#undef MAX_BOTTLE_VOLUME
#undef MIN_VOLUME
#undef MAX_VOLUME
#undef MAX_FLOOR_PRODUCTS
