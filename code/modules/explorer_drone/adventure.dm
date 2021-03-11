#define ADVENTURE_NAME_FIELD "adventure_name"
#define STARTING_NODE_FIELD "starting_node"
#define REQUIRED_SITE_TRAITS_FIELD "required_site_traits"
#define SCAN_BAND_MODS_FIELD "scan_band_mods"
#define LOOT_FIELD "loot_categories"
#define STARTING_QUALITIES_FIELD "starting_qualities"

#define CHOICE_ON_SELECTION_EFFECT_FIELD "on_selection_effects"
#define CHOICE_REQUIREMENTS_FIELD "requirements"
#define EXIT_NODE_FIELD "exit_node"


GLOBAL_LIST_EMPTY(explorer_drone_adventures)


/proc/load_adventures()
	. = list()
	for(var/filename in flist(ADVENTURE_DIR))
		var/datum/adventure/A = try_loading_adventure(filename)
		if(A)
			. += A

/proc/try_loading_adventure(filename)
	var/list/json_data = json_load(ADVENTURE_DIR+filename)
	if(!islist(json_data))
		CRASH("Invalid JSON in adventure file [replacetext(filename,ADVENTURE_DIR,"")]")
	//Basic validation of required fields
	var/static/list/required_fields = list(ADVENTURE_NAME_FIELD,STARTING_NODE_FIELD)
	for(var/field in required_fields)
		if(!json_data[field])
			CRASH("Adventure file [replacetext(filename,ADVENTURE_DIR,"")] missing [field] value")

	var/datum/adventure/loaded_adventure = new
	//load properties
	loaded_adventure.starting_node = json_data[STARTING_NODE_FIELD]
	loaded_adventure.name = json_data[ADVENTURE_NAME_FIELD]
	loaded_adventure.required_site_traits = json_data[REQUIRED_SITE_TRAITS_FIELD]
	loaded_adventure.band_modifiers = json_data[SCAN_BAND_MODS_FIELD]
	loaded_adventure.loot_categories = json_data[LOOT_FIELD]
	loaded_adventure.starting_qualities = json_data[STARTING_QUALITIES_FIELD]
	loaded_adventure.deep_scan_description = json_data["deep_scan_description"]

	for(var/list/node_data in json_data["nodes"])
		var/datum/adventure_node/node = try_loading_node(node_data)
		if(node)
			if(loaded_adventure.nodes[node.id])
				CRASH("Duplicate [node.id] node in [replacetext(filename,ADVENTURE_DIR,"")] adventure")
			loaded_adventure.nodes[node.id] = node
	loaded_adventure.triggers = json_data["triggers"]
	if(!loaded_adventure.validate())
		CRASH("Validation failed for [replacetext(filename,ADVENTURE_DIR,"")] adventure")
	return loaded_adventure

/proc/try_loading_node(node_data)
	if(!islist(node_data))
		CRASH("Invalid adventure node data")
	var/datum/adventure_node/fresh_node = new
	fresh_node.id = node_data["name"]
	fresh_node.description = node_data["description"]
	fresh_node.image_name = node_data["image"]
	fresh_node.raw_image = node_data["raw_image"]
	fresh_node.choices = list()
	for(var/list/choice_data in node_data["choices"])
		fresh_node.choices[choice_data["key"]] = choice_data
	fresh_node.on_enter_effects = node_data["on_enter_effects"]
	fresh_node.on_exit_effects = node_data["on_exit_effects"]
	return fresh_node

/datum/adventure
	/// Adventure name, this organization only, not visible to users
	var/name
	/// Node the adventure will start at
	var/starting_node
	/// Required site traits for the adventure to appear
	var/list/required_site_traits = list()
	/// Modifiers to band scan values
	var/list/band_modifiers = list()
	/// Loot table ids used as reward for finishing the adventure succesfully.
	var/list/loot_categories = list()
	/// Nodes for this adventure, represent single scene.
	var/list/nodes = list()
	/// Triggers for this adventure, checked after quality changes to cause instantenous results
	var/list/triggers = list()
	/// List of starting quality values, these will be set before first node is ecountered.
	var/list/starting_qualities = list()
	///Keeps track firing of triggers until stop state to prevent loops
	var/list/trigger_loop_safety = list()
	/// Opional description shown after site deep scan
	var/deep_scan_description

	// State tracking variables
	/// Current active adventure node
	var/datum/adventure_node/current_node
	/// Last other node than this one. Used by GO_BACK_NODE
	var/previous_node_id
	/// Assoc list of quality name = value
	var/list/qualities
	/// Was this adventure placed on generated exploration site already.
	var/placed = FALSE

/// Basic sanity checks to ensure broken adventures are not used.
/datum/adventure/proc/validate()
	///Check all nodes have choices
	for(var/node_id in nodes)
		var/datum/adventure_node/node = nodes[node_id]
		if(!length(node.choices))
			return FALSE
	return TRUE

/datum/adventure/proc/start_adventure()
	initialize_qualities()
	previous_node_id = starting_node
	navigate_to_node(starting_node)

/// Finish adventure
/datum/adventure/proc/end_adventure(result)
	SEND_SIGNAL(src,COMSIG_ADVENTURE_FINISHED,result)

/datum/adventure/proc/initialize_qualities()
	qualities = starting_qualities || list()
	SEND_SIGNAL(src,COMSIG_ADVENTURE_QUALITY_INIT,qualities)

/datum/adventure/proc/end_delay()
	return

/datum/adventure/proc/navigate_to_node(node_id)
	if(current_node)
		if(current_node.on_exit(src)) //Trigger on exit caused node change <- I don't really see much use for this so might want to warn about it ?
			return
		if(current_node.id != previous_node_id)
			previous_node_id = current_node.id
	if(handle_special_nodes(node_id))
		return
	if(!nodes[node_id])
		stack_trace("Invalid adventure node navigation from node [current_node.id]")
	current_node = nodes[node_id]
	current_node.on_enter(src)

/// Handles special node ID's
/datum/adventure/proc/handle_special_nodes(node_id)
	switch(node_id)
		if(FAIL_NODE)
			end_adventure(ADVENTURE_RESULT_DAMAGE)
			return TRUE
		if(FAIL_DEATH_NODE)
			end_adventure(ADVENTURE_RESULT_DEATH)
			return TRUE
		if(WIN_NODE)
			end_adventure(ADVENTURE_RESULT_SUCCESS)
			return TRUE
		if(GO_BACK_NODE)
			if(previous_node_id)
				navigate_to_node(previous_node_id)
				return TRUE
			else
				return FALSE
		else
			return FALSE

/datum/adventure/proc/select_choice(choice_id)
	if(!current_node || !islist(current_node.choices[choice_id]))
		return
	var/list/choice_data = current_node.choices[choice_id]
	if(!check_requirements(choice_data[CHOICE_REQUIREMENTS_FIELD]))
		return
	if(choice_data[CHOICE_ON_SELECTION_EFFECT_FIELD])
		if(apply_adventure_effect(choice_data[CHOICE_ON_SELECTION_EFFECT_FIELD],src))
			return //Trigger forced node change.
	var/exit_id = choice_data[EXIT_NODE_FIELD]
	if(!exit_id)
		CRASH("No exit node for choice [choice_id] in adventure [name]")
	if(choice_data["delay"])
		var/delay_message = choice_data["delay_message"]
		var/delay_time = choice_data["delay"]
		if(!isnum(delay_time))
			CRASH("Invalid delay in adventure [name]")
		SEND_SIGNAL(src,COMSIG_ADVENTURE_DELAY_START,delay_time,delay_message)
		addtimer(CALLBACK(src,.proc/finish_delay,exit_id),delay_time)
		return
	navigate_to_node(exit_id)

/datum/adventure/proc/finish_delay(exit_id)
	navigate_to_node(exit_id)
	SEND_SIGNAL(src,COMSIG_ADVENTURE_DELAY_END)

/datum/adventure/ui_data(mob/user)
	. = ..()
	.["description"] = current_node?.description
	.["image"] = current_node?.image_name
	.["raw_image"] = current_node?.raw_image
	.["choices"] = current_node?.get_availible_choices(src)


/datum/adventure_node
	/// Unique identifier for this node
	var/id
	/// The actual displayed text
	var/description
	/// Preset image name, exclusive with raw_image
	var/image_name
	/// Image in base64 form. Exclusive with image_name
	var/raw_image
	/// All possible choices from this node, associative list of choice_id -> choice_data
	var/list/choices
	/// Effects fired when navigating to this node.
	var/list/on_enter_effects
	/// Effects fired when leaving this node.
	var/list/on_exit_effects
	/// Pauses adventure for this long after the choice
	var/delay
	/// This will show when the delay is happening.
	var/delay_message


/datum/adventure_node/proc/on_enter(datum/adventure/context)
	if(on_enter_effects)
		if(context.apply_adventure_effect(on_enter_effects))
			return TRUE


/datum/adventure_node/proc/on_exit(datum/adventure/context)
	if(on_exit_effects)
		if(context.apply_adventure_effect(on_exit_effects))
			return TRUE


/datum/adventure_node/proc/get_availible_choices(datum/adventure/context)
	. = list()
	for(var/choice_key in choices)
		var/list/choice_data = choices[choice_key]
		if(context.check_requirements(choice_data["requirements"]))
			. += list(list("key" = choice_key,"text" = choice_data["name"]))



///Applies changes encoded in effect data and processes triggers, returns TRUE if the change forced node change.
/datum/adventure/proc/apply_adventure_effect(list/effect_data,process_triggers=TRUE)
	if(!islist(effect_data))
		CRASH("Invalid effect data [json_encode(effect_data)] in adventure [name]")
	for(var/list/effect_group in effect_data)
		var/effect_keyword = effect_group["effect_type"]
		var/list/quality_name = effect_group["quality"]
		var/value = process_adventure_value(effect_group["value"])
		switch(effect_keyword)
			if(ADVENTURE_EFFECT_TYPE_REMOVE) //remove quality doesn't care about value for now
				qualities -= quality_name
			if(ADVENTURE_EFFECT_TYPE_ADD)
				if(!isnum(value))
					CRASH("Invalid add quality effect value in effect [json_encode(effect_data)] in adventure [name]")
				if(!qualities[quality_name])
					qualities[quality_name] = 0
				qualities[quality_name] += value
			if(ADVENTURE_EFFECT_TYPE_SET)
				qualities[quality_name] = value
			else
				CRASH("Invalid effect keyword in effect [json_encode(effect_data)] in adventure [name]")
	///Check Triggers
	if(process_triggers)
		for(var/list/trigger_data in triggers)
			if(!check_requirements(trigger_data["requirements"]))
				continue
			if(LAZYACCESS(trigger_loop_safety,trigger_data["name"]))
				stack_trace("Loop in trigger processing detected in adventure [name]")
				continue
			LAZYADD(trigger_loop_safety,trigger_data["name"])
			if(trigger_data["on_trigger_effects"])
				apply_adventure_effect(trigger_data["on_trigger_effects"],FALSE) //Let's keep this simple
			if(trigger_data["target_node"])
				navigate_to_node(trigger_data["target_node"])
				return TRUE
	//We're out of trigger processing
	LAZYCLEARLIST(trigger_loop_safety)
	return FALSE

/// Extracts raw value from special value objects
/datum/adventure/proc/process_adventure_value(raw_value)
	if(islist(raw_value))
		var/list/value_as_list = raw_value
		switch(value_as_list["value_type"])
			if(ADVENTURE_QUALITY_TYPE_RANDOM)
				return rand(value_as_list[ADVENTURE_RANDOM_QUALITY_LOW_FIELD],value_as_list[ADVENTURE_RANDOM_QUALITY_HIGH_FIELD])
			else
				CRASH("Invalid special value type in adventure [name]")
	else
		return raw_value

/// Checks if current qualities satisfy passed in requirements
/datum/adventure/proc/check_requirements(raw_requirements)
	if(!islist(raw_requirements))
		return TRUE
	var/list/req_groups = raw_requirements
	// Top level list - can contain either req groups or single requirements and is AND type group
	for(var/list/group_data in req_groups)
		if(group_data["requirements"]) //It's a group
			if(!check_requirement_group(group_data))
				return FALSE
		else //It's a single requirement
			if(!check_single_requirement(group_data))
				return FALSE
	return TRUE

/// Recursively validates group requirements.
/datum/adventure/proc/check_requirement_group(raw_group_data)
	if(!islist(raw_group_data))
		CRASH("Invalid group requirement in adventure [name]")
	var/list/group_data = raw_group_data
	var/group_type = group_data["group_type"]
	var/list/group_elements = group_data["requirements"]
	switch(group_type)
		if("OR") //Just one out of subgroups/reqs need to be true for this to return true
			for(var/list/subgroup_data in group_elements)
				if(subgroup_data["requirements"]) //It's a group
					if(check_requirement_group(subgroup_data))
						return TRUE
				else //It's a single requirement
					if(check_single_requirement(subgroup_data))
						return TRUE
			return FALSE
		if("AND") //All subgroups/reqs need to be true for this to return true
			for(var/list/subgroup_data in group_elements)
				if(subgroup_data["requirements"]) //It's a group
					if(!check_requirement_group(subgroup_data))
						return FALSE
				else //It's a single requirement
					if(!check_single_requirement(subgroup_data))
						return FALSE
			return TRUE
		else
			CRASH("Invalid requirement group in adventure [name]")


//Checks unit requirement {"quality": "a","op": "==","value": "something"},
/datum/adventure/proc/check_single_requirement(raw_requirement)
	var/qkey = raw_requirement["quality"]
	var/qval = raw_requirement["value"]
	switch(raw_requirement["operator"])
		if("==")
			return qualities[qkey] == qval
		if("!=")
			return qualities[qkey] != qval
		if(">")
			return qualities[qkey] > qval
		if(">=")
			return qualities[qkey] >= qval
		if("<=")
			return qualities[qkey] <= qval
		if("<")
			return qualities[qkey] < qval
		if("exists")
			return qkey in qualities

#undef ADVENTURE_NAME_FIELD
#undef STARTING_NODE_FIELD
#undef REQUIRED_SITE_TRAITS_FIELD
#undef SCAN_BAND_MODS_FIELD
#undef LOOT_FIELD
#undef STARTING_QUALITIES_FIELD

#undef CHOICE_ON_SELECTION_EFFECT_FIELD
#undef CHOICE_REQUIREMENTS_FIELD
#undef EXIT_NODE_FIELD
