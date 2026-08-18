/**
 * Global Science techweb for RND consoles
 */
/datum/techweb/science
	id = "SCIENCE"
	organization = "Nanotrasen"
	should_generate_points = TRUE

/datum/techweb/science/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, get_that_dosh = TRUE, atom/research_source)
	. = ..()
	if(!.)
		return

	if(ispath(node))
		node = SSresearch.techweb_nodes[node]
	node.on_station_research(research_source)

/datum/techweb/oldstation
	id = "CHARLIE"
	organization = "Nanotrasen"
	should_generate_points = TRUE

/datum/techweb/oldstation/New()
	. = ..()
	research_node(/datum/techweb_node/oldstation_surgery, TRUE, TRUE, FALSE)

/**
 * Admin techweb that has everything unlocked by default
 */
/datum/techweb/admin
	id = "ADMIN"
	organization = "Central Command"

/datum/techweb/admin/New()
	. = ..()
	for(var/node_path, node in SSresearch.techweb_nodes)
		research_node(node, TRUE, TRUE, FALSE)
	adjust_all_points(INFINITY)
	hidden_nodes.Cut()

GLOBAL_LIST_EMPTY(autounlock_techwebs)

/**
 * Techweb node that automatically unlocks a given buildtype.
 * Saved in GLOB.autounlock_techwebs and used to prevent
 * creating new ones each time it's needed.
 */
/datum/techweb/autounlocking
	///The buildtype we will automatically unlock.
	var/allowed_buildtypes = ALL
	///Designs that are only available when the printer is hacked.
	var/list/hacked_designs = list()

/datum/techweb/autounlocking/New()
	. = ..()
	for(var/design_path, _design in SSresearch.techweb_designs)
		var/datum/design/design = _design
		if(!(design.build_type & allowed_buildtypes))
			continue
		if(RND_CATEGORY_INITIAL in design.category)
			add_design(design_path)
		if(RND_CATEGORY_HACKED in design.category)
			add_design(design_path, add_to = hacked_designs)

/datum/techweb/autounlocking/add_design(datum/design/design, custom = FALSE, list/add_to)
	if(ispath(design))
		design = SSresearch.techweb_designs[design]
	if(!istype(design) || !(design.build_type & allowed_buildtypes))
		return FALSE
	return ..()

/datum/techweb/autounlocking/autolathe
	allowed_buildtypes = AUTOLATHE

/datum/techweb/autounlocking/limbgrower
	allowed_buildtypes = LIMBGROWER

/datum/techweb/autounlocking/biogenerator
	allowed_buildtypes = BIOGENERATOR

/datum/techweb/autounlocking/smelter
	allowed_buildtypes = SMELTER
