/// Display data for every techweb node and design, shared between the R&D console and the Science Hub app
/datum/asset/json/techweb_catalogue
	name = "techweb_catalogue"
	/// The number of times the catalogue has been built this round, so the UI knows which build it has
	var/version = 0
	/// Whether or not the catalogue needs to be (re)built on next use. Set at first and whenever a node or design changes
	var/needs_build = TRUE
	/// The id of everything in the catalogue, by typepath or name. Kept between builds so live data still matches an older one
	var/list/ids = list()
	/// How many nodes the last build had, so we know to rebuild if one gets registered
	var/node_count = 0
	/// How many designs the last build had, so we know to rebuild if one gets registered
	var/design_count = 0

// We only build through ensure_ready(), since SSassets can initialize before SSresearch has made the nodes and designs
/datum/asset/json/techweb_catalogue/register()
	if(needs_build)
		return
	version++
	return ..()

/datum/asset/json/techweb_catalogue/ensure_ready()
	if(node_count != length(SSresearch.techweb_nodes) || design_count != length(SSresearch.techweb_designs))
		needs_build = TRUE
	if(needs_build)
		needs_build = FALSE
		regenerate()
		needs_build = !SSresearch.initialized
	return src

/// Returns the id for a typepath or name, giving it the next free one if it doesn't have one yet
/datum/asset/json/techweb_catalogue/proc/get_id(key)
	. = ids[key]
	if(!.)
		. = length(ids) + 1
		ids[key] = .

/// Sends the catalogue to the user, then returns the url their window loads it from and which build it is
/datum/asset/json/techweb_catalogue/proc/get_window_data(mob/user)
	send(user)
	return list(
		"url" = SSassets.transport.get_asset_url("[name].json"),
		"version" = version,
	)

/datum/asset/json/techweb_catalogue/generate()
	node_count = length(SSresearch.techweb_nodes)
	design_count = length(SSresearch.techweb_designs)
	// Nodes get the lowest ids, since live data sends one for every node every update
	for(var/node_path in SSresearch.techweb_nodes)
		get_id(node_path)

	var/list/node_cache = list()
	for(var/node_path, node_definition in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = node_definition
		var/list/node_data = list(
			"name" = node.display_name,
			"description" = node.description
		)

		if (LAZYLEN(node.research_costs))
			node_data["costs"] = list()
			for (var/point_type, point_amount in node.research_costs)
				node_data["costs"]["[get_id(point_type)]"] = point_amount
		if (LAZYLEN(node.prerequisite_nodes))
			node_data["prerequisite_nodes"] = list()
			for (var/prerequisite_node in node.prerequisite_nodes)
				node_data["prerequisite_nodes"] += get_id(prerequisite_node)
		if (LAZYLEN(node.unlocked_designs))
			node_data["unlocked_designs"] = list()
			for (var/unlocked_design in node.unlocked_designs)
				node_data["unlocked_designs"] += get_id(unlocked_design)
		if (LAZYLEN(node.unlocked_nodes))
			node_data["unlocked_nodes"] = list()
			for (var/unlocked_node in node.unlocked_nodes)
				node_data["unlocked_nodes"] += get_id(unlocked_node)
		if (LAZYLEN(node.required_experiments))
			node_data["required_experiments"] = list()
			for (var/experiment_type in node.required_experiments)
				node_data["required_experiments"] += get_id(experiment_type)
		// Sent as id, discount pairs because numeric object keys lose their order on the js side
		if (LAZYLEN(node.discount_experiments))
			node_data["discount_experiments"] = list()
			for (var/experiment_type, discount in node.discount_experiments)
				node_data["discount_experiments"] += list(get_id(experiment_type), discount)
		if (LAZYLEN(node.discount_boosts))
			node_data["discount_boosts"] = node.discount_boosts

		node_cache["[get_id(node_path)]"] = node_data

	// Build design cache
	var/list/design_cache = list()
	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"
	for (var/design_path, design_definition in SSresearch.techweb_designs)
		var/datum/design/design = design_definition

		// Material id, amount pairs, same reason as the discounts
		var/list/cost = list()
		for(var/datum/material/mat, amount in design.materials)
			cost += list(get_id(mat.name), OPTIMAL_COST(amount))

		var/size = spritesheet.icon_size_id(design.asset_id)
		design_cache["[get_id(design_path)]"] = list(
			design.name,
			cost,
			design.build_type,
			design.departmental_flags,
			"[size == size32x32 ? "" : "[size] "][design.asset_id]"
		)

	var/list/department_flags = list()
	for (var/datum/job_department/department as anything in subtypesof(/datum/job_department))
		if (department::department_bitflags)
			department_flags["[department::department_bitflags]"] = department::department_name

	// Don't pass away flags as those are irrelevant to the station
	var/list/build_types = GLOB.build_types_to_string.Copy()
	build_types -= "[AWAY_IMPRINTER]"
	build_types -= "[AWAY_LATHE]"

	// The UI only ever looks designs up by id, so we don't bother sending their typepaths
	var/list/id_cache = list()
	for(var/key in ids)
		id_cache += ispath(key, /datum/design) ? 0 : key

	return list(
		"version" = version,
		"point_types_abbreviations" = SSresearch.point_types,
		"node_cache" = node_cache,
		"design_cache" = design_cache,
		"id_cache" = id_cache,
		"SHEET_MATERIAL_AMOUNT" = SHEET_MATERIAL_AMOUNT,
		"build_types" = build_types,
		"department_flags" = department_flags,
	)
