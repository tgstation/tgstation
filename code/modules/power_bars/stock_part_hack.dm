/obj/item/stock_parts
	var/initial_parent_ref

/obj/item/stock_parts/Initialize(mapload)
	. = ..()

	if (!should_hack())
		return

	if (!ismachinery(loc))
		new /obj/item/paper/fluff/no_stock_parts(loc)
		return INITIALIZE_HINT_QDEL

	initial_parent_ref = WEAKREF(loc)

/obj/item/stock_parts/Destroy(force)
	initial_parent_ref = null
	. = ..()
#ifdef REFERENCE_TRACKING
	return QDEL_HINT_IFFAIL_FINDREFERENCE
#endif

/obj/item/stock_parts/proc/should_hack()
	return SSpower_bars.enabled && !istype(src, /obj/item/stock_parts/cell)

/obj/item/stock_parts/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	if (QDELING(src))
		return ..()

	if (!should_hack())
		return ..()

	if (IS_WEAKREF_OF(old_loc, initial_parent_ref))
		return ..()

	new /obj/item/paper/fluff/no_stock_parts(loc)
	qdel(src)
	initial_parent_ref = null

/obj/item/paper/fluff/no_stock_parts
	name = "cease and desist"
	default_raw_text = {"
		<h1>Legal Notice from Nanotrasen</h1><hr />
		Pressure from investors into discovering more efficient power systems has led us to impose a temporary
		embargo on all stock parts. To improve machines, please ask engineering to provide your department
		with additional power upgrades. We apologize for the inconvenience.
	"}

/obj/item/storage/part_replacer/Initialize(mapload)
	if (SSpower_bars.enabled)
		return INITIALIZE_HINT_QDEL

	return ..()
