/datum/component
	var/enabled = TRUE      					// Enables or disables the components
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER	// How components of the same type are handled in the same parent
	var/list/signal_procs						// list of signals -> callbacks
	var/datum/parent							// parent datum

/datum/component/New(datum/P, ...)
	var/dm = dupe_mode
	if(dm != COMPONENT_DUPE_ALLOWED)
		var/datum/component/old = P.GetExactComponent(type)
		if(old)
			switch(dm)
				if(COMPONENT_DUPE_HIGHLANDER)
					P.RemoveComponent(old)
					old = null	//in case SendSignal() blocks
				if(COMPONENT_DUPE_UNIQUE)
					qdel(src)
					return
	P.SendSignal(COMSIG_COMPONENT_ADDED, list(src), FALSE)
	LAZYADD(P.datum_components, src)
	parent = P

/datum/component/Destroy()
	RemoveNoSignal()
	return ..()

/datum/component/proc/RemoveNoSignal()
	var/datum/P = parent
	if(P)
		LAZYREMOVE(P.datum_components, src)
		parent = null

/datum/component/proc/RegisterSignal(sig_type, proc_on_self, override = FALSE)
	var/list/procs = signal_procs
	if(!procs)
		procs = list()
		signal_procs = procs
	
	if(!override)
		. = procs[sig_type]
		if(.)
			stack_trace("[sig_type] overridden. Use override = TRUE to suppress this warning")
	
	procs[sig_type] = CALLBACK(src, proc_on_self)    

/datum/component/proc/ReceiveSignal(sigtype, list/sig_args, async)
	var/list/sps = signal_procs
	var/datum/callback/CB = LAZYACCESS(sps, sigtype)
	if(!CB)
		return FALSE
	if(!async)
		return CB.Invoke(arglist(sig_args))
	else
		return CB.InvokeAsync(arglist(sig_args))

/datum/var/list/datum_components //list of /datum/component

// Send a signal to all other components in the container.
/datum/proc/SendSignal(sigtype, list/sig_args, async = FALSE)
	var/list/comps = datum_components
	. = FALSE
	for(var/I in comps)
		var/datum/component/C = I
		if(!C.enabled)
			continue
		if(C.ReceiveSignal(sigtype, sig_args, async))
			ComponentActivated(C)
			. = TRUE

// Callback for when a component activates
/datum/proc/ComponentActivated(datum/component/C)

/datum/proc/GetComponent(c_type)
	for(var/I in datum_components)
		if(istype(I, c_type))
			return I

/datum/proc/GetExactComponent(c_type)
	for(var/I in datum_components)
		var/datum/component/C = I
		if(C.type == c_type)
			return I

/datum/proc/GetComponents(c_type)
	. = list()
	for(var/I in datum_components)
		if(istype(I, c_type))
			. += I

/datum/proc/AddComponents(list/new_types)
	for(var/new_type in new_types)
		AddComponent(new_type)

/datum/proc/AddComponent(new_type, ...)
	var/nt = new_type
	args[1] = src
	var/datum/component/C = new nt(arglist(args))
	return QDELING(C) ? GetComponent(new_type) : C

/datum/proc/RemoveComponent(datum/component/C)
	if(!C)
		return
	C.RemoveNoSignal()
	SendSignal(COMSIG_COMPONENT_REMOVING, list(C), FALSE)
	qdel(C)
