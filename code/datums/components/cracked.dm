/// Tracks damage to add or remove crack overlays, when none are needed this components is qdeleted
/datum/component/cracked
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/mutable_appearance/crack_appearances
	var/crack_integrity
	var/list/applied_cracks = list()

/datum/component/cracked/Initialize(list/crack_appearances, crack_integrity)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.crack_appearances = crack_appearances
	src.crack_integrity = crack_integrity

/datum/component/cracked/Destroy(force, silent)
	RemoveCracks(parent, length(applied_cracks))
	return ..()

/datum/component/cracked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_INTEGRITY_CHANGED, PROC_REF(IntegrityChanged))
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
		var/mutable_appearance/new_crack_overlay = new(pick(crack_appearances))
		// Now that we have our overlay, we need to give it a unique render source so we can use a filter against it
		var/static/uuid = 0
		uuid++
		// * so it doesn't render on its own
		new_crack_overlay.render_target = "*cracked_overlay_[uuid]"
		var/render_source = new_crack_overlay.render_target

		var/list/new_filter_data = alpha_mask_filter(render_source=render_source, x=rand_x, y=rand_y, flags=MASK_INVERSE)
		applied_cracks[render_source] = new_crack_overlay

		// We need to add it as an overlay so the render target from the filter knows what to point at
		source.add_overlay(new_crack_overlay)
		source.add_filter(render_source, 1, new_filter_data)

/datum/component/cracked/proc/RemoveCracks(obj/source, count)
	for(var/i in 1 to count)
		var/removed_filter = pick(applied_cracks)
		source.remove_filter(removed_filter)
		source.cut_overlay(applied_cracks[removed_filter])
		applied_cracks -= removed_filter
