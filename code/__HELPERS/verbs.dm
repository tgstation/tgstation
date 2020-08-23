/**
  * handles adding verbs and updating the stat panel browser
  *
  * pass the verb type path to this instead of adding it directly to verbs so the statpanel can update
  * Arguments:
  * * target - Who the verb is being added to, client or mob typepath
  * * verb - typepath to a verb, or a list of verbs, supports lists of lists
  */
/proc/add_verb(target, verb_or_list_to_add)
	if(!target)
		CRASH("add_verb called without a target")
	if(IsAdminAdvancedProcCall())
		return
	if(ismob(target))
		if(!target.client)
			return
		target = target.client

	var/list/verbs_list = list()
	if(!islist(verb_or_list_to_add))
		verbs_list += verb_or_list_to_add
	else
		var/list/elements_to_process = verb_or_list_to_add.Copy()
		while(length(elements_to_process))
			var/element_or_list = elements_to_process[length(elements_to_process)] //Last element
			elements_to_process.len--
			if(islist(element_or_list))
				elements_to_process += element_or_list //list/a += list/b adds the contents of b into a, not the reference to the list itself
			else
				verbs_list += element_or_list

	var/list/output_list = list()
	for(var/verb in verbs_list)
		target.verbs += verb_or_list
		output_list[++output_list.len] = list("[verb_or_list:category]", "[verb_or_list:name]")
	output_list = url_encode(json_encode(output_list))
	target << output("[output_list];", "statbrowser:add_verb_list")

/**
  * handles removing verb and sending it to browser to update, use this for removing verbs
  *
  * pass the verb type path to this instead of removing it from verbs so the statpanel can update
  * Arguments:
  * * target - Who the verb is being removed from, client or mob typepath
  * * verb - typepath to a verb, or a list of verbs, supports lists of lists
  */
/proc/remove_verb(target, verb_to_remove)
	if(!target)
		CRASH("remove_verb called without a target")
	if(IsAdminAdvancedProcCall())
		return
	if(ismob(target))
		if(!target.client)
			return
		target = target.client

	var/list/verbs_list = list()
	if(!islist(verb_or_list_to_remove))
		verbs_list += verb_or_list_to_remove
	else
		var/list/elements_to_process = verb_or_list_to_remove.Copy()
		while(length(elements_to_process))
			var/element_or_list = elements_to_process[length(elements_to_process)] //Last element
			elements_to_process.len--
			if(islist(element_or_list))
				elements_to_process += element_or_list //list/a += list/b adds the contents of b into a, not the reference to the list itself
			else
				verbs_list += element_or_list

	var/list/output_list = list()
	for(var/verb in verbs_list)
		client_target.verbs -= verb_or_list
		output_list[++output_list.len] = list("[verb_or_list:category]", "[verb_or_list:name]")
	output_list = url_encode(json_encode(output_list))
	client_target << output("[output_list];", "statbrowser:remove_verb_list")
