/// High mobility nuisance antag with a focus on stealing things the crew would rather not lose (but not high value targets)
/datum/antagonist/flock_agent
	name = "\improper Flock Agent"
	roundend_category = "flock agents"
	antagpanel_category = ANTAG_GROUP_FLOCK
	pref_flag = ROLE_FLOCK_AGENT
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	stinger_sound = 'troutstation/sound/music/antag/flock_intro.ogg'
	ui_name = "AntagInfoFlockAgent"
	suicide_cry = "FOR MY LORD!!"

	var/datum/team/flock_agent/team = null
	var/mob/living/basic/flock/agent/agent
	var/list/cached_recipe_data

/datum/antagonist/flock_agent/Destroy()
	team = null
	agent = null
	return ..()

/datum/antagonist/flock_agent/greet()
	. = ..()
	to_chat(owner, span_bold("Awoken from cryosleep. It appears your Lord has need for you once more..."))
	owner.announce_objectives()

/datum/antagonist/flock_agent/forge_objectives()
	objectives |= team.objectives

/datum/antagonist/flock_agent/create_team(datum/team/new_team)
	GLOB.flock_agent_team ||= new()
	team = GLOB.flock_agent_team

/datum/antagonist/flock_agent/get_team()
	return team

/datum/antagonist/flock_agent/on_gain()
	agent = owner.current
	forge_objectives()
	send_to_outpost()
	return ..()

/datum/antagonist/flock_agent/proc/send_to_outpost()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_FLOCK_OUTPOST)
	for(var/obj/effect/landmark/flock_agent/landmark in GLOB.landmarks_list)
		if(!locate(/mob/living/basic/flock/agent, landmark))
			agent.forceMove(landmark.loc)
			break

/datum/antagonist/flock_agent/admin_add(datum/mind/new_owner, mob/admin)
	if (!new_owner.current)
		return

	if (!istype(new_owner.current, /mob/living/basic/flock/agent))
		var/old_mob = new_owner.current
		var/mob/living/basic/flock/agent/new_agent = new(get_turf(new_owner.current))
		new_owner.transfer_to(new_agent, force_key_move = TRUE)
		qdel(old_mob)

	return ..()

/datum/antagonist/flock_agent/get_preview_icon()
	var/datum/universal_icon/icon = uni_icon('troutstation/icons/mob/simple/flock.dmi', "agent")
	return finish_preview_icon(icon)

/datum/antagonist/flock_agent/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui?.set_autoupdate(FALSE) // note to self: this might actually be best left alone
	// find out with testing

/datum/antagonist/flock_agent/proc/get_recipe_ui_data(datum/flock_recipe/recipe)
	if(!recipe.item)
		CRASH("WHO'S TRYING TO BUILD THE PARENT FLOCK RECIPE???? I DEMAND TO SEE THEM")
	var/list/recipe_data = list()
	recipe_data["path"] = recipe
	recipe_data["name"] = recipe.item.name
	recipe_data["icon_params"] = get_recipe_item_icon(recipe)
	recipe_data["cost"] = get_flock_recipe_cost(recipe)
	recipe_data["desc"] = recipe.desc
	return recipe_data

/datum/antagonist/flock_agent/proc/get_recipe_item_icon(datum/flock_recipe/recipe)
	if(!recipe.item)
		CRASH("Icon flock recipe called for recipe with no item (did the parent show up by mistake?)")
	var/icon_path = recipe.item.icon
	var/icon_state = recipe.item.icon_state
	var/icon_frame = 1 // but cirr magic numbers is bad SHUT UP WHEN WILL THIS EVER BE DIFFERENT
	var/icon_dir = SOUTH
	var/icon_moving = 0

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/flock_agent/proc/generate_recipe_list_data()
	var/list/data = list()
	var/list/recipes = subtypesof(/datum/flock_recipe)
	for(var/recipe in recipes)
		data += list(get_recipe_ui_data(recipe))
	return data

/datum/antagonist/flock_agent/ui_data(mob/user)
	var/list/data = list()
	data["resources"] = agent?.resources || 0
	// data["lord_name"] = agent.get_lord_name()
	data["objectives"] = get_objectives()

	var/recipes_list = list()
	if(length(cached_recipe_data))
		recipes_list = cached_recipe_data
	else
		recipes_list = generate_recipe_list_data()
		cached_recipe_data = recipes_list
	data["recipes"] = recipes_list

	return data

/datum/antagonist/flock_agent/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create")
			var/datum/flock_recipe/recipe = text2path(params["path"])
			if(!ispath(recipe, /datum/flock_recipe))
				CRASH("Flock Agent attempted to create non-flock_recipe path! (Got: [recipe || "invalid recipe"])")
			agent.create_recipe(recipe)
			update_data_for_all_viewers()

/datum/antagonist/flock_agent/ui_status(mob/user, datum/ui_state/state)
	if(isnull(owner.current) || owner.current.stat == DEAD)
		return UI_UPDATE
	return ..()

/datum/antagonist/flock_agent/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/flock),
	)
