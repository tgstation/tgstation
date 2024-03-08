/datum/component/sticker
	dupe_mode = COMPONENT_DUPE_ALLOWED

	var/obj/item/sticker/our_sticker

	var/mutable_appearance/sticker_overlay

/datum/component/sticker/Initialize(obj/item/our_sticker, px = 0, py = 0)
	if(!(ismob(parent) || isobj(parent) || isturf(parent)))
		return COMPONENT_INCOMPATIBLE

	src.our_sticker = our_sticker

	var/icon/sticker_icon = icon(our_sticker.icon, our_sticker.icon_state)

	sticker_overlay = mutable_appearance(sticker_icon)
	sticker_overlay.pixel_w = px - sticker_icon.Width() / 2
	sticker_overlay.pixel_z = py - sticker_icon.Height() / 2

	var/atom/parent_atom = parent
	parent_atom.add_overlay(sticker_overlay)

	our_sticker.moveToNullspace()

/datum/component/sticker/Destroy(force)
	remove()
	QDEL_NULL(our_sticker)
	QDEL_NULL(sticker_overlay)
	return ..()

/datum/component/sticker/RegisterWithParent()
	if(isliving(parent))
		RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_EXPOSE, PROC_REF(on_turf_expose))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/sticker/UnregisterFromParent()
	if(isliving(parent))
		UnregisterSignal(parent, COMSIG_LIVING_IGNITED)
	if(isturf(parent))
		UnregisterSignal(parent, COMSIG_TURF_EXPOSE)
	UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)


/datum/component/sticker/proc/remove()
	var/atom/parent_atom = parent
	parent_atom.cut_overlay(sticker_overlay)

/datum/component/sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/component/sticker/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	our_sticker.forceMove(parent)
	our_sticker = null

	qdel(src)

	return COMPONENT_CLEANED

/datum/component/sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER

	if(our_sticker.should_atmos_process(air, exposed_temperature))
		qdel(src)
