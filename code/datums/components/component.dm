/datum/component
	var/enabled = TRUE
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/list/signal_procs
	var/datum/parent

/datum/component/New(datum/P, ...)
	var/dm = dupe_mode
	if(dm != COMPONENT_DUPE_ALLOWED)
		var/datum/component/old = P.GetExactComponent(type)
		if(old)
			switch(dm)
				if(COMPONENT_DUPE_HIGHLANDER)
					InheritComponent(old, FALSE)
					qdel(old)
				if(COMPONENT_DUPE_UNIQUE)
					old.InheritComponent(src, TRUE)
					qdel(src)
					return
	P.SendSignal(COMSIG_COMPONENT_ADDED, src)
	LAZYADD(P.datum_components, src)
	parent = P

/datum/component/Destroy()
	enabled = FALSE
	var/datum/P = parent
	if(P)
		_RemoveNoSignal()
		P.SendSignal(COMSIG_COMPONENT_REMOVING, src)
	LAZYCLEARLIST(signal_procs)
	return ..()

/datum/component/proc/_RemoveNoSignal()
	var/datum/P = parent
	if(P)
		LAZYREMOVE(P.datum_components, src)
		parent = null

/datum/component/proc/RegisterSignal(sig_type, proc_on_self, override = FALSE)
	if(QDELETED(src))
		return
	var/list/procs = signal_procs
	if(!procs)
		procs = list()
		signal_procs = procs
	
	if(!override)
		. = procs[sig_type]
		if(.)
			stack_trace("[sig_type] overridden. Use override = TRUE to suppress this warning")
	
	procs[sig_type] = CALLBACK(src, proc_on_self)    

/datum/component/proc/ReceiveSignal(sigtype, ...)
	var/list/sps = signal_procs
	var/datum/callback/CB = LAZYACCESS(sps, sigtype)
	if(!CB)
		return FALSE
	var/list/arguments = args.Copy()
	arguments.Cut(1, 2)
	return CB.InvokeAsync(arglist(arguments))

/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return

/datum/component/proc/OnTransfer(datum/new_parent)
	return

/datum/var/list/datum_components //list of /datum/component

/datum/proc/SendSignal(sigtype, ...)
	var/list/comps = datum_components
	. = FALSE
	for(var/I in comps)
		var/datum/component/C = I
		if(!C.enabled)
			continue
		if(C.ReceiveSignal(arglist(args)))
			ComponentActivated(C)
			. = TRUE

/datum/proc/ComponentActivated(datum/component/C)
	return

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

/datum/proc/AddComponent(new_type, ...)
	var/nt = new_type
	args[1] = src
	var/datum/component/C = new nt(arglist(args))
	return QDELING(C) ? GetComponent(new_type) : C

/datum/proc/TakeComponent(datum/component/C)
	if(!C)
		return
	var/datum/helicopter = C.parent
	if(helicopter == src)
		//wat
		return
	C._RemoveNoSignal()
	helicopter.SendSignal(COMSIG_COMPONENT_REMOVING, C)
	C.OnTransfer(src)
	C.parent = src
	SendSignal(COMSIG_COMPONENT_ADDED, C)