/obj/item/stock_parts
	var/initial_parent

/obj/item/stock_parts/Initialize(mapload)
	. = ..()

	if (!should_hack())
		return

	if (!ismachinery(loc))
		new /obj/item/paper/fluff/no_stock_parts(loc)
		return INITIALIZE_HINT_QDEL

	initial_parent = loc

/obj/item/stock_parts/Destroy(force)
	initial_parent = null
	return ..()

/obj/item/stock_parts/proc/should_hack()
	return SSpower_bars.enabled && !istype(src, /obj/item/stock_parts/cell)

/obj/item/stock_parts/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	if (QDELING(src))
		return ..()

	if (!should_hack())
		return ..()

	if (old_loc == initial_parent)
		return ..()

	new /obj/item/paper/fluff/no_stock_parts(loc)
	qdel(src)
	initial_parent = null

/obj/item/paper/fluff/no_stock_parts
	name = "cease and desist"
	default_raw_text = {"
		<h1>Legal Notice from Nanotrasen</h1><hr />
		Pressure from investors into discovering more efficient power systems has led us to impose a temporary
		embargo on all stock parts. To improve machines, please ask engineering to provide your department
		with additional power upgrades. We apologize for the inconvenience.
	"}
