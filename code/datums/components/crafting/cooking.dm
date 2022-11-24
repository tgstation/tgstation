/datum/component/cooking
	var/busy = FALSE

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
		ui = new(user, src, "PersonalCooking")
		ui.open()

/datum/component/cooking/ui_data(mob/user)
	var/list/data = list()
	data["busy"] = busy
	return data

/datum/component/cooking/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	data["recipes"] = list()
	for(var/path in GLOB.crafting_recipes)
		if (!istype(path, /datum/crafting_recipe/food))
			continue
		var/datum/crafting_recipe/recipe =  path
		var/list/recipe_data = list()
		recipe_data["name"] = recipe.name
		var/list/reqs = recipe.reqs
		for(var/atom/req_atom as anything in reqs)
			recipe_data["reqs"] += list(list(
				"path" = req_atom,
				"name" = initial(req_atom.name),
				"amount" = reqs[req_atom]
			))
		recipe_data["category"] = recipe.subcategory
		if(!(recipe.subcategory in data["categories"]))
			data["categories"] += recipe.subcategory
		recipe_data["result"] = recipe.result
		if(ispath(recipe.result, /obj/item/food))
			var/obj/item/food/item = recipe.result
			recipe_data["desc"] = initial(item.desc)
			recipe_data["foodtypes"] = bitfield_to_list(initial(item.foodtypes), FOOD_FLAGS)
		else
			recipe_data["desc"] = "Not an item"
		data["recipes"] += list(recipe_data)
	return data

/datum/component/cooking/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("cook")
			busy = TRUE
			return TRUE

/datum/component/cooking/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/food)
	)
