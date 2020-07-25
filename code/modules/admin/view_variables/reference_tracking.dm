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

#endif

#ifdef LEGACY_REFERENCE_TRACKING

/datum/proc/find_references(skip_alert)
	return

#endif
