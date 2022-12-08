
/**
 * Datum used to designate certain areas that do not need to exist nor be loaded at world start
 * but do want to be loaded under certain circumstances. Use this for stuff like the nukie base or wizden, aka stuff that only matters when their antag is rolled.
 */
/datum/lazy_template
	/// If this is true each load will increment an index keyed to the type and it will load [map_name]_[index]
	var/list/datum/turf_reservation/reservations = list()
	var/uses_multiple_allocations = FALSE
	var/key
	var/map_dir = "_maps/templates/lazy_templates"
	var/map_name
	var/map_width
	var/map_height

/**
 * Does the grunt work of loading the template.
 */
/datum/lazy_template/proc/lazy_load()
	RETURN_TYPE(/turf)
	var/static/list/multiple_allocation_hash

	var/load_path = "[map_dir]/[map_name].dmm"
	if(uses_multiple_allocations)
		var/times = LAZYACCESS(multiple_allocation_hash, type) || 0
		times += 1
		LAZYSET(multiple_allocation_hash, type, times)
		load_path = "[map_dir]/[map_name]_[times].dmm"

	if(!load_path || !fexists(load_path))
		CRASH("lazy_template_pivot [type] has an invalid map_path: '[load_path]'")

	var/datum/map_template/loading = new(path = load_path, cache = TRUE)
	if(!loading.cached_map)
		CRASH("Failed to cache lazy template for loading: '[key]'")

	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(loading.width, loading.height)
	if(!reservation)
		CRASH("Failed to reserve a block for lazy template: '[key]'")

	var/turf/reservation_bottom_left = coords2turf(reservation.bottom_left_coords)
	if(!loading.load(reservation_bottom_left))
		CRASH("Failed to load lazy template: '[key]'")
	reservations += reservation

	return reservation

/datum/lazy_template/nukie_base
	key = LAZY_TEMPLATE_KEY_NUKIEBASE
	map_name = "nukie_base"
	map_width = 89
	map_height = 100

/datum/lazy_template/wizard_dem
	key = LAZY_TEMPLATE_KEY_WIZARDDEN
	map_name = "wizard_den"

/datum/lazy_template/ninja_holding_facility
	key = LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY
	map_name = "ninja_den"

/datum/lazy_template/abductor_ship
	key = LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS
	map_name = "abductor_ships"
