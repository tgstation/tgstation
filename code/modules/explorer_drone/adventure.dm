// json field definitions bit verbose but i've had it with the typos
#define ADVENTURE_NAME_FIELD "adventure_name"
#define ADVENTURE_STARTING_NODE_FIELD "starting_node"
#define ADVENTURE_REQUIRED_SITE_TRAITS_FIELD "required_site_traits"
#define ADVENTURE_SCAN_BAND_MODS_FIELD "scan_band_mods"
#define ADVENTURE_LOOT_FIELD "loot_categories"
#define ADVENTURE_STARTING_QUALITIES_FIELD "starting_qualities"
#define ADVENTURE_DEEP_SCAN_DESCRIPTION "deep_scan_description"
#define ADVENTURE_NODES_FIELD "nodes"
#define ADVENTURE_TRIGGERS_FIELD "triggers"
#define ADVENTURE_VERSION_FIELD "version"

#define NODE_NAME_FIELD "name"
#define NODE_DESCRIPTION_FIELD "description"
#define NODE_IMAGE_FIELD "image"
#define NODE_RAW_IMAGE_FIELD "raw_image"
#define NODE_CHOICES_FIELD "choices"
#define NODE_ON_ENTER_EFFECTS_FIELD "on_enter_effects"
#define NODE_ON_EXIT_EFFECTS_FIELD "on_exit_effects"

#define CHOICE_KEY_FIELD "key"
#define CHOICE_NAME_FIELD "name"
#define CHOICE_ON_SELECTION_EFFECT_FIELD "on_selection_effects"
#define CHOICE_REQUIREMENTS_FIELD "requirements"
#define CHOICE_EXIT_NODE_FIELD "exit_node"
#define CHOICE_DELAY_FIELD "delay"
#define CHOICE_DELAY_MESSAGE_FIELD "delay_message"

#define EFFECT_TYPE_FIELD "effect_type"
#define EFFECT_QUALITY_FIELD "quality"
#define EFFECT_VALUE_FIELD "value"
#define EFFECT_VALUE_VALUE_TYPE_FIELD "value_type"
#define TRIGGER_NAME_FIELD "name"
#define TRIGGER_REQUIREMENTS_FIELD "requirements"
#define TRIGGER_ON_TRIGGER_EFFECTS_FIELD "on_trigger_effects"
#define TRIGGER_TARGET_NODE_FIELD "target_node"

#define REQ_GROUP_REQUIREMENTS_FIELD "requirements"
#define REQ_GROUP_GROUP_TYPE_FIELD "group_type"

#define REQ_QUALITY_FIELD "quality"
#define REQ_VALUE_FIELD "value"
#define REQ_OPERATOR_FIELD "operator"

#define CURRENT_ADVENTURE_VERSION 1
#define ADVENTURE_LOOK_PATH "strings/exoadventures/"

/// All possible adventures in raw form
GLOBAL_LIST_EMPTY(explorer_drone_adventure_db_entries)

/// Loads all adventures from DB
/proc/load_adventures()
	. = list()
	for(var/filename in flist(ADVENTURE_LOOK_PATH))
		var/raw_json = file2text(ADVENTURE_LOOK_PATH + filename)
		var/list/json_decoded = json_decode(raw_json)
		var/datum/adventure_db_entry/entry = new()
		entry.filename = filename
		entry.raw_json = raw_json
		entry.uploader = json_decoded["author"]
		entry.extract_metadata()
		. += entry
	GLOB.explorer_drone_adventure_db_entries = .

/datum/adventure_db_entry
	/// filename of the adventure
	var/filename
	/// actual adventure json string
	var/raw_json
	/// Unapproved adventures won't be used for exploration sites.
	var/approved = FALSE
	/// Was the adventure used for exploration site this round.
	var/placed = FALSE

	//Variables below are extracted from the JSON

	/// whoever made the json
	var/uploader
	/// json version
	var/version
	/// adventure name
	var/name
	/// required site traits to use this adventure
	var/list/required_site_traits

/// Check if the adventure usable for given exploration site traits
/datum/adventure_db_entry/proc/valid_for_use(list/site_traits)
	if(!raw_json || version != CURRENT_ADVENTURE_VERSION || placed)
		return FALSE
	if(required_site_traits && length(required_site_traits - site_traits) != 0)
		return FALSE
	return TRUE

/// Extracts fields that are used by adventure browser / generation before instantiating
/datum/adventure_db_entry/proc/extract_metadata()
	if(!raw_json)
		CRASH("Trying to extract metadata from empty adventure")
	var/list/json_data = json_decode(raw_json)
	if(!islist(json_data))
		CRASH("Invalid JSON for adventure with at path:[filename]")
	version = json_data[ADVENTURE_VERSION_FIELD] || 0
	name = json_data[ADVENTURE_NAME_FIELD]
	required_site_traits = json_data[ADVENTURE_REQUIRED_SITE_TRAITS_FIELD]

/// Creates new adventure instance
/datum/adventure_db_entry/proc/create_adventure()
	if(version != CURRENT_ADVENTURE_VERSION)
		CRASH("Trying to instance outdated adventure version")
	return try_loading_adventure()

/// Parses adventure JSON and returns /datum/adventure instance on success
/datum/adventure_db_entry/proc/try_loading_adventure()
	var/list/json_data = json_decode(raw_json)
	if(!islist(json_data))
		CRASH("Invalid JSON in adventure with path:[filename], name:[name]")

	//Basic validation of required fields, don't even bother loading if they are missing.
	var/static/list/required_fields = list(ADVENTURE_NAME_FIELD,ADVENTURE_STARTING_NODE_FIELD,ADVENTURE_NODES_FIELD)
	for(var/field in required_fields)
		if(!json_data[field])
			CRASH("Adventure path:[filename], name:[name] missing [field] value")

	var/datum/adventure/loaded_adventure = new
	//load properties
	loaded_adventure.starting_node = json_data[ADVENTURE_STARTING_NODE_FIELD]
	loaded_adventure.name = json_data[ADVENTURE_NAME_FIELD]
	loaded_adventure.required_site_traits = json_data[ADVENTURE_REQUIRED_SITE_TRAITS_FIELD]
	loaded_adventure.band_modifiers = json_data[ADVENTURE_SCAN_BAND_MODS_FIELD]
	loaded_adventure.loot_categories = json_data[ADVENTURE_LOOT_FIELD]
	loaded_adventure.starting_qualities = json_data[ADVENTURE_STARTING_QUALITIES_FIELD]
	loaded_adventure.deep_scan_description = json_data[ADVENTURE_DEEP_SCAN_DESCRIPTION]

	for(var/list/node_data in json_data[ADVENTURE_NODES_FIELD])
		var/datum/adventure_node/node = try_loading_node(node_data)
		if(node)
			if(loaded_adventure.nodes[node.id])
				CRASH("Duplicate [node.id] node in path:[filename], name:[name] adventure")
			loaded_adventure.nodes[node.id] = node
	loaded_adventure.triggers = json_data[ADVENTURE_TRIGGERS_FIELD]
	if(!loaded_adventure.validate())
		CRASH("Validation failed for path:[filename], name:[name] adventure")
	return loaded_adventure

/datum/adventure_db_entry/proc/try_loading_node(node_data)
	if(!islist(node_data))
		CRASH("Invalid adventure node data in path:[filename], name:[name] adventure.")
	var/datum/adventure_node/fresh_node = new
	fresh_node.id = node_data[NODE_NAME_FIELD]
	fresh_node.description = node_data[NODE_DESCRIPTION_FIELD]
	fresh_node.image_name = node_data[NODE_IMAGE_FIELD]
	fresh_node.raw_image = node_data[NODE_RAW_IMAGE_FIELD]
	fresh_node.choices = list()
	for(var/list/choice_data in node_data[NODE_CHOICES_FIELD])
		fresh_node.choices[choice_data[CHOICE_KEY_FIELD]] = choice_data
	fresh_node.on_enter_effects = node_data[NODE_ON_ENTER_EFFECTS_FIELD]
	fresh_node.on_exit_effects = node_data[NODE_ON_EXIT_EFFECTS_FIELD]
	return fresh_node

/// text adventure instance, holds data about nodes/choices/etc and of current play state.
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
	/// List of starting quality values, these will be set before first node is encountered.
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
	/// Delayed state properties. If not null, means adventure is in delayed action state and will contain list(delay_time,delay_message)
	var/list/delayed_action

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
	var/exit_id = choice_data[CHOICE_EXIT_NODE_FIELD]
	if(!exit_id)
		CRASH("No exit node for choice [choice_id] in adventure [name]")
	if(choice_data[CHOICE_DELAY_FIELD])
		var/delay_message = choice_data[CHOICE_DELAY_MESSAGE_FIELD]
		var/delay_time = choice_data[CHOICE_DELAY_FIELD]
		if(!isnum(delay_time))
			CRASH("Invalid delay in adventure [name]")
		SEND_SIGNAL(src,COMSIG_ADVENTURE_DELAY_START,delay_time,delay_message)
		delayed_action = list(delay_time,delay_message)
		addtimer(CALLBACK(src, PROC_REF(finish_delay),exit_id),delay_time)
		return
	navigate_to_node(exit_id)

/datum/adventure/proc/finish_delay(exit_id)
	delayed_action = null
	navigate_to_node(exit_id)
	SEND_SIGNAL(src,COMSIG_ADVENTURE_DELAY_END)

/datum/adventure/ui_data(mob/user)
	. = ..()
	.["description"] = current_node?.description
	.["image"] = current_node?.image_name
	.["raw_image"] = current_node?.raw_image
	.["choices"] = current_node?.get_available_choices(src)


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


/datum/adventure_node/proc/get_available_choices(datum/adventure/context)
	. = list()
	for(var/choice_key in choices)
		var/list/choice_data = choices[choice_key]
		if(context.check_requirements(choice_data[CHOICE_REQUIREMENTS_FIELD]))
			. += list(list("key" = choice_key,"text" = choice_data[CHOICE_NAME_FIELD]))

///Applies changes encoded in effect data and processes triggers, returns TRUE if the change forced node change.
/datum/adventure/proc/apply_adventure_effect(list/effect_data,process_triggers=TRUE)
	if(!islist(effect_data))
		CRASH("Invalid effect data [json_encode(effect_data)] in adventure [name]")
	for(var/list/effect_group in effect_data)
		var/effect_keyword = effect_group[EFFECT_TYPE_FIELD]
		var/list/quality_name = effect_group[EFFECT_QUALITY_FIELD]
		var/value = process_adventure_value(effect_group[EFFECT_VALUE_FIELD])
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
			if(!check_requirements(trigger_data[TRIGGER_REQUIREMENTS_FIELD]))
				continue
			if(LAZYACCESS(trigger_loop_safety,trigger_data[TRIGGER_NAME_FIELD]))
				stack_trace("Loop in trigger processing detected in adventure [name]")
				continue
			LAZYADD(trigger_loop_safety,trigger_data[TRIGGER_NAME_FIELD])
			if(trigger_data[TRIGGER_ON_TRIGGER_EFFECTS_FIELD])
				apply_adventure_effect(trigger_data[TRIGGER_ON_TRIGGER_EFFECTS_FIELD],FALSE) //Let's keep this simple
			if(trigger_data[TRIGGER_TARGET_NODE_FIELD])
				navigate_to_node(trigger_data[TRIGGER_TARGET_NODE_FIELD])
				return TRUE
	//We're out of trigger processing
	LAZYCLEARLIST(trigger_loop_safety)
	return FALSE

/// Extracts raw value from special value objects
/datum/adventure/proc/process_adventure_value(raw_value)
	if(islist(raw_value))
		var/list/value_as_list = raw_value
		switch(value_as_list[EFFECT_VALUE_VALUE_TYPE_FIELD])
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
		if(group_data[REQ_GROUP_REQUIREMENTS_FIELD]) //It's a group
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
	var/group_type = group_data[REQ_GROUP_GROUP_TYPE_FIELD]
	var/list/group_elements = group_data[REQ_GROUP_REQUIREMENTS_FIELD]
	switch(group_type)
		if("OR") //Just one out of subgroups/reqs need to be true for this to return true
			for(var/list/subgroup_data in group_elements)
				if(subgroup_data[REQ_GROUP_REQUIREMENTS_FIELD]) //It's a group
					if(check_requirement_group(subgroup_data))
						return TRUE
				else //It's a single requirement
					if(check_single_requirement(subgroup_data))
						return TRUE
			return FALSE
		if("AND") //All subgroups/reqs need to be true for this to return true
			for(var/list/subgroup_data in group_elements)
				if(subgroup_data[REQ_GROUP_REQUIREMENTS_FIELD]) //It's a group
					if(!check_requirement_group(subgroup_data))
						return FALSE
				else //It's a single requirement
					if(!check_single_requirement(subgroup_data))
						return FALSE
			return TRUE
		else
			CRASH("Invalid requirement group in adventure [name]")

//Checks if unit requirement {"quality": "a","op": "==","value": "something"} is met.
/datum/adventure/proc/check_single_requirement(raw_requirement)
	var/qkey = raw_requirement[REQ_QUALITY_FIELD]
	var/qval = raw_requirement[REQ_VALUE_FIELD]
	switch(raw_requirement[REQ_OPERATOR_FIELD])
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

#undef ADVENTURE_LOOK_PATH
#undef ADVENTURE_VERSION_FIELD
#undef CURRENT_ADVENTURE_VERSION

#undef ADVENTURE_NAME_FIELD
#undef ADVENTURE_STARTING_NODE_FIELD
#undef ADVENTURE_REQUIRED_SITE_TRAITS_FIELD
#undef ADVENTURE_SCAN_BAND_MODS_FIELD
#undef ADVENTURE_LOOT_FIELD
#undef ADVENTURE_STARTING_QUALITIES_FIELD
#undef ADVENTURE_DEEP_SCAN_DESCRIPTION
#undef ADVENTURE_NODES_FIELD
#undef ADVENTURE_TRIGGERS_FIELD

#undef NODE_NAME_FIELD
#undef NODE_DESCRIPTION_FIELD
#undef NODE_IMAGE_FIELD
#undef NODE_RAW_IMAGE_FIELD
#undef NODE_CHOICES_FIELD
#undef NODE_ON_ENTER_EFFECTS_FIELD
#undef NODE_ON_EXIT_EFFECTS_FIELD

#undef CHOICE_KEY_FIELD
#undef CHOICE_NAME_FIELD
#undef CHOICE_ON_SELECTION_EFFECT_FIELD
#undef CHOICE_REQUIREMENTS_FIELD
#undef CHOICE_EXIT_NODE_FIELD
#undef CHOICE_DELAY_FIELD
#undef CHOICE_DELAY_MESSAGE_FIELD

#undef EFFECT_TYPE_FIELD
#undef EFFECT_QUALITY_FIELD
#undef EFFECT_VALUE_FIELD
#undef EFFECT_VALUE_VALUE_TYPE_FIELD
#undef TRIGGER_NAME_FIELD
#undef TRIGGER_REQUIREMENTS_FIELD
#undef TRIGGER_ON_TRIGGER_EFFECTS_FIELD
#undef TRIGGER_TARGET_NODE_FIELD

#undef REQ_GROUP_REQUIREMENTS_FIELD
#undef REQ_GROUP_GROUP_TYPE_FIELD

#undef REQ_QUALITY_FIELD
#undef REQ_VALUE_FIELD
#undef REQ_OPERATOR_FIELD
