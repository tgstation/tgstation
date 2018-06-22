SUBSYSTEM_DEF(dcs)
	name = "Datum Component System"
	flags = SS_NO_INIT | SS_NO_FIRE

	var/list/comp_lookup = list()	// A signal:list(components) assoc list

/datum/controller/subsystem/dcs/proc/_SendGlobalSignal(sigtype, list/arguments)
	. = NONE
	for(var/i in comp_lookup[sigtype])
		var/datum/component/comp = i
		if(!comp.enabled)
			continue
		var/datum/callback/CB = comp.signal_procs[sigtype]
		if(!CB)
			continue // Should we error from this?
		. |= CB.InvokeAsync(arglist(arguments))

/datum/controller/subsystem/dcs/proc/RegisterSignal(datum/component/comp, sigtype)
	if(!comp_lookup[sigtype])
		comp_lookup[sigtype] = list()
	
	comp_lookup[sigtype][comp] = TRUE

/datum/controller/subsystem/dcs/proc/UnregisterSignal(datum/component/comp, list/sigtypes)
	if(!length(sigtypes))
		sigtypes = list(sigtypes)
	for(var/sigtype in sigtypes)
		switch(length(comp_lookup[sigtype]))
			if(1)
				comp_lookup -= sigtype
			if(2 to INFINITY)
				comp_lookup[sigtype] -= comp

/datum/controller/subsystem/dcs/Recover()
	comp_lookup = SSdcs.comp_lookup
