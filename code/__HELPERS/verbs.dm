/**
  * handles adding verbs and updating the stat panel browser
  *
  * pass the verb type path to this instead of adding it directly to verbs so the statpanel can update
  * Arguments:
  * * target - Who the verb is being added to, client or mob typepath
  * * verb - typepath to a verb, or a list of verbs, supports lists of lists
  */
/proc/add_verb(target, verb_to_add)
	if(!target || IsAdminAdvancedProcCall())
		return
	var/list/V = list()
	if(istype(target, /client))
		var/client/C = target
		if(!islist(verb_to_add))
			C.verbs += verb_to_add
			if(verb_to_add:hidden || !verb_to_add:category)// no category
				return
			V = list("[verb_to_add:category]", "[verb_to_add:name]")
			V = url_encode(json_encode(V))
			C << output("[V];", "statbrowser:add_verb")
		else if(islist(verb_to_add))
			for(var/L in verb_to_add)
				if(islist(L)) // list in a list? more likely than you think
					add_verb(target, L) // just pass it through again til we get the verb
					continue
				C.verbs += L
				V[++V.len] = list("[L:category]", "[L:name]")
			V = url_encode(json_encode(V))
			C << output("[V];", "statbrowser:add_verb_list")
	else if(istype(target, /mob)) // copy pasta for mobs
		var/mob/M = target
		if(!islist(verb_to_add))
			M.verbs += verb_to_add
			if(verb_to_add:hidden || !verb_to_add:category)// no category
				return
			V = list("[verb_to_add:category]", "[verb_to_add:name]")
			V = url_encode(json_encode(V))
			if(M.client)
				M.client << output("[V];", "statbrowser:add_verb")
		else if(islist(verb_to_add))
			for(var/L in verb_to_add)
				if(islist(L)) // list in a list? more likely than you think
					add_verb(target, L) // just pass it through again til we get the verb
					continue
				M.verbs += L
				V[++V.len] = list("[L:category]", "[L:name]")
			V = url_encode(json_encode(V))
			M?.client << output("[V];", "statbrowser:add_verb_list")

/**
  * handles removing verb and sending it to browser to update, use this for removing verbs
  *
  * pass the verb type path to this instead of removing it from verbs so the statpanel can update
  * Arguments:
  * * target - Who the verb is being removed from, client or mob typepath
  * * verb - typepath to a verb, or a list of verbs, supports lists of lists
  */
/proc/remove_verb(target, verb_to_remove)
	if(!target || IsAdminAdvancedProcCall())
		return
	var/list/V = list()
	if(istype(target, /client))
		var/client/C = target
		if(!islist(verb_to_remove))
			C.verbs -= verb_to_remove
			V = list("[verb_to_remove:category]", "[verb_to_remove:name]")
			V = url_encode(json_encode(V))
			C << output("[V];", "statbrowser:remove_verb")
		else if(islist(verb_to_remove))
			for(var/L in verb_to_remove)
				if(islist(L)) // list in a list? more likely than you think
					remove_verb(target, L) // just pass it through again til we get the verb
					continue
				C.verbs -= L
				V[++V.len] = list("[L:category]", "[L:name]")
			V = url_encode(json_encode(V))
			C << output("[V];", "statbrowser:remove_verb_list")
	else if(istype(target, /mob)) // copy pasta for mobs
		var/mob/M = target
		if(!islist(verb_to_remove))
			M.verbs -= verb_to_remove
			V = list("[verb_to_remove:category]", "[verb_to_remove:name]")
			V = url_encode(json_encode(V))
			if(M.client)
				M.client << output("[V];", "statbrowser:remove_verb")
		else if(islist(verb_to_remove)) // we have list of verbs
			for(var/L in verb_to_remove) // get verb in list
				if(islist(L)) // list in a list? more likely than you think
					remove_verb(target, L) // just pass it through again til we get the verb
					continue
				M.verbs -= L
				V[++V.len] = list("[L:category]", "[L:name]")
			V = url_encode(json_encode(V))
			M?.client << output("[V];", "statbrowser:remove_verb_list")
