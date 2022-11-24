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
	for(var/path in subtypesof(/datum/crafting_recipe/food))
		var/datum/crafting_recipe/food/recipe = new path
		data["recipes"] += list(list(
			"name" = recipe.name,
			"icon" = sanitize_css_class_name("[recipe.result]")
		))
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
