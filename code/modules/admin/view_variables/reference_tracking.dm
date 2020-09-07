#ifdef REFERENCE_TRACKING

GLOBAL_LIST_EMPTY(deletion_failures)

/world/proc/enable_reference_tracking()
	var/extools = world.GetConfig("env", "EXTOOLS_DLL") || (world.system_type == MS_WINDOWS ? "./byond-extools.dll" : "./libbyond-extools.so")
	if (fexists(extools))
		call(extools, "ref_tracking_initialize")()

/proc/get_back_references(datum/D)
	CRASH("/proc/get_back_references not hooked by extools, reference tracking will not function!")

/proc/get_forward_references(datum/D)
	CRASH("/proc/get_forward_references not hooked by extools, reference tracking will not function!")

/proc/clear_references(datum/D)
	return

/datum/admins/proc/view_refs(atom/D in world) //it actually supports datums as well but byond no likey
	set category = "Debug"
	set name = "View References"

	if(!check_rights(R_DEBUG) || !D)
		return

	var/list/backrefs = get_back_references(D)
	if(isnull(backrefs))
		var/datum/browser/popup = new(usr, "ref_view", "<div align='center'>Error</div>")
		popup.set_content("Reference tracking not enabled")
		popup.open(FALSE)
		return

	var/list/frontrefs = get_forward_references(D)
	var/list/dat = list()
	dat += "<h1>References of \ref[D] - [D]</h1><br><a href='?_src_=vars;[HrefToken()];[VV_HK_VIEW_REFERENCES]=TRUE;[VV_HK_TARGET]=[REF(D)]'>\[Refresh\]</a><hr>"
	dat += "<h3>Back references - these things hold references to this object.</h3>"
	dat += "<table>"
	dat += "<tr><th>Ref</th><th>Type</th><th>Variable Name</th><th>Follow</th>"
	for(var/ref in backrefs)
		var/datum/backreference = ref
		if(isnull(backreference))
			dat += "<tr><td>GC'd Reference</td></tr>"
		if(istype(backreference))
			dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(backreference)]'>[REF(backreference)]</td><td>[backreference.type]</td><td>[backrefs[backreference]]</td><td><a href='?_src_=vars;[HrefToken()];[VV_HK_VIEW_REFERENCES]=TRUE;[VV_HK_TARGET]=[REF(backreference)]'>\[Follow\]</a></td></tr>"
		else if(islist(backreference))
			dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(backreference)]'>[REF(backreference)]</td><td>list</td><td>[backrefs[backreference]]</td><td><a href='?_src_=vars;[HrefToken()];[VV_HK_VIEW_REFERENCES]=TRUE;[VV_HK_TARGET]=[REF(backreference)]'>\[Follow\]</a></td></tr>"
		else
			dat += "<tr><td>Weird reference type. Add more debugging checks.</td></tr>"
	dat += "</table><hr>"
	dat += "<h3>Forward references - this object is referencing those things.</h3>"
	dat += "<table>"
	dat += "<tr><th>Variable name</th><th>Ref</th><th>Type</th><th>Follow</th>"
	for(var/ref in frontrefs)
		var/datum/backreference = frontrefs[ref]
		dat += "<tr><td>[ref]</td><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(backreference)]'>[REF(backreference)]</a></td><td>[backreference.type]</td><td><a href='?_src_=vars;[HrefToken()];[VV_HK_VIEW_REFERENCES]=TRUE;[VV_HK_TARGET]=[REF(backreference)]'>\[Follow\]</a></td></tr>"
	dat += "</table><hr>"
	dat = dat.Join()

	var/datum/browser/popup = new(usr, "ref_view", "<div align='center'>References of \ref[D]</div>")
	popup.set_content(dat)
	popup.open(FALSE)


/datum/admins/proc/view_del_failures()
	set category = "Debug"
	set name = "View Deletion Failures"

	if(!check_rights(R_DEBUG))
		return

	var/list/dat = list("<table>")
	for(var/t in GLOB.deletion_failures)
		if(isnull(t))
			dat += "<tr><td>GC'd Reference | <a href='byond://?src=[REF(src)];[HrefToken(TRUE)];delfail_clearnulls=TRUE'>Clear Nulls</a></td></tr>"
			continue
		var/datum/thing = t
		dat += "<tr><td>\ref[thing] | [thing.type][thing.gc_destroyed ? " (destroyed)" : ""] [ADMIN_VV(thing)]</td></tr>"
	dat += "</table><hr>"
	dat = dat.Join()

	var/datum/browser/popup = new(usr, "del_failures", "<div align='center'>Deletion Failures</div>")
	popup.set_content(dat)
	popup.open(FALSE)


/datum/proc/find_references()
	testing("Beginning search for references to a [type].")
	var/list/backrefs = get_back_references(src)
	for(var/ref in backrefs)
		if(isnull(ref))
			log_world("## TESTING: Datum reference found, but gone now.")
			continue
		if(islist(ref))
			log_world("## TESTING: Found [type] \ref[src] in list.")
			continue
		var/datum/datum_ref = ref
		if(!istype(datum_ref))
			log_world("## TESTING: Found [type] \ref[src] in unknown type reference: [datum_ref].")
			return
		log_world("## TESTING: Found [type] \ref[src] in [datum_ref.type][datum_ref.gc_destroyed ? " (destroyed)" : ""]")
		message_admins("Found [type] \ref[src] [ADMIN_VV(src)] in [datum_ref.type][datum_ref.gc_destroyed ? " (destroyed)" : ""] [ADMIN_VV(datum_ref)]")
	testing("Completed search for references to a [type].")

#endif

#ifdef LEGACY_REFERENCE_TRACKING

/datum/verb/legacy_find_refs()
	set category = "Debug"
	set name = "Find References"
	set src in world

	find_references(FALSE)


/datum/proc/find_references_legacy(skip_alert)
	running_find_references = type
	if(usr?.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = TRUE
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert && alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") != "Yes")
			running_find_references = null
			return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = FALSE

	if(usr?.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	last_find_references = world.time

	DoSearchVar(GLOB) //globals
	for(var/datum/thing in world) //atoms (don't beleive its lies)
		DoSearchVar(thing, "World -> [thing]")

	for(var/datum/thing) //datums
		DoSearchVar(thing, "World -> [thing]")

	for(var/client/thing) //clients
		DoSearchVar(thing, "World -> [thing]")

	testing("Completed search for references to a [type].")
	if(usr?.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = TRUE
	SSgarbage.next_fire = world.time + world.tick_lag


/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set src in world

	qdel(src, TRUE) //force a qdel
	if(!running_find_references)
		find_references(TRUE)


/datum/verb/qdel_then_if_fail_find_references()
	set category = "Debug"
	set name = "qdel() then Find References if GC failure"
	set src in world

	qdel_and_find_ref_if_fail(src, TRUE)


/datum/proc/DoSearchVar(potential_container, container_name, recursive_limit = 64)
	if(usr?.client && !usr.client.running_find_references)
		return

	if(!recursive_limit)
		return

	if(istype(potential_container, /datum))
		var/datum/datum_container = potential_container
		if(datum_container.last_find_references == last_find_references)
			return

		datum_container.last_find_references = last_find_references
		var/list/vars_list = datum_container.vars

		for(var/varname in vars_list)
			if (varname == "vars")
				continue
			var/variable = vars_list[varname]

			if(variable == src)
				testing("Found [type] \ref[src] in [datum_container.type]'s [varname] var. [container_name]")

			else if(islist(variable))
				DoSearchVar(variable, "[container_name] -> list", recursive_limit - 1)

	else if(islist(potential_container))
		var/normal = IS_NORMAL_LIST(potential_container)
		for(var/element_in_list in potential_container)
			if(element_in_list == src)
				testing("Found [type] \ref[src] in list [container_name].")

			else if(element_in_list && !isnum(element_in_list) && normal && potential_container[element_in_list] == src)
				testing("Found [type] \ref[src] in list [container_name]\[[element_in_list]\]")

			else if(islist(element_in_list))
				DoSearchVar(element_in_list, "[container_name] -> list", recursive_limit - 1)

	#ifndef FIND_REF_NO_CHECK_TICK
	CHECK_TICK
	#endif


/proc/qdel_and_find_ref_if_fail(datum/thing_to_del, force = FALSE)
	SSgarbage.reference_find_on_fail[REF(thing_to_del)] = TRUE
	qdel(thing_to_del, force)

#endif
