/datum/component/cooking
	/// Whether you are currently occupied with cooking
	var/busy = FALSE
	/// Whether to show the recipes in a compact mode, without description and ingredient icons
	var/compact = FALSE
	/// Whether to show only craftable recipes
	var/craftable_only = FALSE

/datum/component/cooking/Initialize()
	if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(create_mob_button))

/datum/component/cooking/proc/create_mob_button(mob/user, client/CL)
	SIGNAL_HANDLER
	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/cook/C = new()
	C.icon = H.ui_style
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(component_ui_interact))

/datum/component/cooking/proc/component_ui_interact(atom/movable/screen/cook/image, location, control, params, user)
	SIGNAL_HANDLER
	if(user == parent)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/cooking/ui_state(mob/user)
	return GLOB.not_incapacitated_turf_state

/datum/component/cooking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PersonalCooking", "Cook Book")
		ui.open()

/datum/component/cooking/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	data["compact"] = compact
	data["craftable_only"] = craftable_only
	return data

/datum/component/cooking/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	if(user.has_dna())
		var/mob/living/carbon/carbon = user
		data["diet"] = carbon.dna.species.get_species_diet()
	data["foodtypes"] = list()
	data["recipes"] = list()
	for(var/path in GLOB.crafting_recipes)
		if (!istype(path, /datum/crafting_recipe/food/))
			continue
		var/datum/crafting_recipe/recipe = path
		if (!recipe.result)
			continue
		var/list/recipe_data = list()
		recipe_data["name"] = recipe.name
		var/list/reqs = recipe.reqs
		for(var/atom/req_atom as anything in reqs)
			recipe_data["reqs"] += list(list(
				"path" = req_atom,
				"name" = initial(req_atom.name),
				"amount" = reqs[req_atom],
				"is_reagent" = ispath(req_atom, /datum/reagent/)
			))
		recipe_data["category"] = recipe.subcategory
		if(!(recipe.subcategory in data["categories"]))
			data["categories"] += recipe.subcategory
		recipe_data["result"] = recipe.result
		if(ispath(recipe.result, /obj/item/food))
			var/obj/item/food/item = recipe.result
			recipe_data["desc"] = initial(item.desc)
			var/list/foodtypes = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
			for(var/type in foodtypes)
				if(!(type in data["foodtypes"]))
					data["foodtypes"] += type
			recipe_data["foodtypes"] = foodtypes
		else
			recipe_data["desc"] = "Not an item"
		data["recipes"] += list(recipe_data)
	return data

/datum/component/cooking/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_compact")
			compact = !compact
			return TRUE
		if("toggle_craftable_only")
			craftable_only = !craftable_only
			return TRUE
		if("cook")
			busy = TRUE
			return TRUE

/datum/component/cooking/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/food)
	)
