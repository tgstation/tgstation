/datum/component/status_effect_listener
	dupe_mode = COMPONENT_DUPE_UNIQUE
	report_signal_origin = TRUE
	var/list/effect_signals = list()

/datum/component/status_effect_listener/proc/RegisterEffectSignal(datum/status_effect/se, sig_type_or_types, proc_or_callback)
	var/list/sig_types = islist(sig_type_or_types) ? sig_type_or_types : list(sig_type_or_types)
	RegisterSignal(sig_type_or_types, .proc/signal, override = TRUE)
	for(var/type in sig_types)
		var/list/callbacks = effect_signals[type]
		if(!callbacks)
			callbacks = list()
			effect_signals[type] = callbacks
		if(!istype(proc_or_callback, /datum/callback)) //if it wasnt a callback before, it is now
			proc_or_callback = CALLBACK(se, proc_or_callback)
		effect_signals[type] += proc_or_callback

/datum/component/status_effect_listener/proc/ClearSignalRegister(datum/status_effect/se)
	for(var/type in effect_signals)
		for(var/datum/callback/cb in effect_signals[type])
			if(cb.object == se)
				effect_signals[type] -= cb
				QDEL_NULL(cb)
		if(effect_signals[type].len <= 0)
			QDEL_LIST(effect_signals[type])
			effect_signals[type] = null
			effect_signals -= type
	if(effect_signals.len <= 0)
		QDEL_LIST(effect_signals)
		qdel(src)

/datum/component/status_effect_listener/proc/signal(sigtype, ...)
	var/list/arguments = args.Copy(2)
	if(effect_signals[sigtype])
		for(var/datum/callback/CB in effect_signals[sigtype])
			if(!CB)
				continue
			. |= CB.InvokeAsync(arglist(arguments))
