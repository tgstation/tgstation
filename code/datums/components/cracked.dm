/// Tracks damage to add or remove crack overlays, when none are needed this components is qdeleted
/datum/component/cracked
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/icon/crack_icons
	var/crack_integrity
	var/list/applied_cracks = list()

/datum/component/cracked/Initialize(list/crack_icons, crack_integrity)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.crack_icons = crack_icons
	src.crack_integrity = crack_integrity

/datum/component/cracked/Destroy(force, silent)
	RemoveCracks(parent, length(applied_cracks))
	return ..()

/datum/component/cracked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_INTEGRITY_CHANGED, .proc/IntegrityChanged)
	var/obj/master = parent
	var/integrity = master.get_integrity()
	IntegrityChanged(parent, integrity, integrity)

/datum/component/cracked/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_INTEGRITY_CHANGED)

/datum/component/cracked/proc/IntegrityChanged(obj/source, old_value, new_value)
	SIGNAL_HANDLER
	var/cracked_max_integrity = source.max_integrity * crack_integrity
	if(new_value >= cracked_max_integrity)
		qdel(src)
		return

	var/current_percent = 1 - (new_value / cracked_max_integrity)
	var/cracks = CEILING(10 * current_percent, 1) // 1 crack per 10% integrity lost
	var/current_cracks = length(applied_cracks)
	if(!islist(source.filters))
		if(isnull(source.filters))
			source.filters = list()
		else
			source.filters = list(source.filters)

	if(current_cracks == cracks)
		return

	if(current_cracks < cracks)
		AddCracks(source, cracks - current_cracks)
	else
		RemoveCracks(source, current_cracks - cracks)

/datum/component/cracked/proc/AddCracks(obj/source, count)
	for(var/i in 1 to count)
		var/rand_x = rand(0, 20) - 10
		var/rand_y = rand(0, 20) - 10
		var/icon/new_crack_icon = pick(crack_icons)
		var/list/new_filter_data = alpha_mask_filter(icon=new_crack_icon, x=rand_x, y=rand_y, flags=MASK_INVERSE)
		var/name
		for(var/k in 1 to 100)
			name = "crack[rand(0, 999)]"
			if(!applied_cracks[name])
				break
		if(applied_cracks[name])
			CRASH("No unique name could be found after 100 iterations.")
		applied_cracks[name] = TRUE
		source.add_filter(name, 1, new_filter_data)

/datum/component/cracked/proc/RemoveCracks(obj/source, count)
	for(var/i in 1 to count)
		var/removed_filter = pick(applied_cracks)
		applied_cracks -= removed_filter
		source.remove_filter(removed_filter)
