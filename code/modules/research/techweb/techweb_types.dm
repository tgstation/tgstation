/**
 * Global Science techweb for RND consoles
 */
/datum/techweb/science
	id = "SCIENCE"
	organization = "Nanotrasen"
	should_generate_points = TRUE

/datum/techweb/science/node_added(datum/techweb_node/node, atom/research_source)
	node.on_station_research(research_source)

/datum/techweb/science/design_added(datum/design/design)
	design.on_station_research()

/datum/techweb/science/design_removed(datum/design/design)
	design.on_station_unresearch()

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
		if(RND_CATEGORY_INITIAL in design.category)
			add_design(design)
		if(RND_CATEGORY_HACKED in design.category)
			add_design(design, add_to = hacked_designs)

/datum/techweb/autounlocking/is_valid_design(datum/design/design)
	return (design.build_type & allowed_buildtypes)

/datum/techweb/autounlocking/autolathe
	allowed_buildtypes = AUTOLATHE

/datum/techweb/autounlocking/limbgrower
	allowed_buildtypes = LIMBGROWER

/datum/techweb/autounlocking/biogenerator
	allowed_buildtypes = BIOGENERATOR

/datum/techweb/autounlocking/smelter
	allowed_buildtypes = SMELTER
