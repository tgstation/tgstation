/datum/techweb_node/basic_microfusion
	id = "basic_microfusion"
	starting_node = TRUE
	display_name = "Basic Microfusion Technology"
	description = "Basic microfusion technology allowing for basic microfusion designs."
	design_ids = list(
		"basic_microfusion_cell",
		"microfusion_phase_emitter_undercharger",
	)

//Enhanced microfusion
/datum/techweb_node/enhanced_microfusion
	id = "enhanced_microfusion"
	display_name = "Enhanced Microfusion Technology"
	description = "Enhanced microfusion technology allowing for upgraded basic microfusion!"
	prereq_ids = list(
		"basic_microfusion",
		"engineering",
		"weaponry",
		"high_efficiency",
	)
	design_ids = list(
		"enhanced_microfusion_cell",
		"microfusion_cell_attachment_rechargeable",
		"enhanced_microfusion_phase_emitter",
		"microfusion_gun_attachment_black_camo",
		"microfusion_gun_attachment_heatsink",
		"microfusion_gun_attachment_rgb",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)

//Advanced microfusion
/datum/techweb_node/advanced_microfusion
	id = "advanced_microfusion"
	display_name = "Advanced Microfusion Technology"
	description = "Advanced microfusion technology allowing for advanced microfusion!"
	prereq_ids = list(
		"enhanced_microfusion",
		"adv_engi",
		"adv_weaponry",
		"adv_power",
		"adv_plasma",
	)
	design_ids = list(
		"advanced_microfusion_cell",
		"microfusion_cell_attachment_overcapacity",
		"microfusion_cell_attachment_stabiliser",
		"microfusion_gun_attachment_scatter",
		"microfusion_gun_attachment_superheat",
		"advanced_microfusion_phase_emitter",
		"microfusion_gun_attachment_grip",
		"microfusion_gun_attachment_rail",
		"microfusion_gun_attachment_scope",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)


// Bluespace microfusion
/datum/techweb_node/bluespace_microfusion
	id = "bluespace_microfusion"
	display_name = "Bluespace Microfusion Technology"
	description = "Bluespace tinkering plus microfusion technology!"
	prereq_ids = list(
		"advanced_microfusion",
		"bluespace_power",
		"beam_weapons",
		"explosive_weapons",
	)
	design_ids = list(
		"bluespace_microfusion_cell",
		"microfusion_gun_attachment_repeater",
		"bluespace_microfusion_phase_emitter",
		"microfusion_cell_attachment_selfcharging",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)

// Bluespace microfusion
/datum/techweb_node/quantum_microfusion
	id = "quantum_microfusion"
	display_name = "Quantum Microfusion Technology"
	description = "Bleeding edge microfusion tech, making use of the latest in materials and components, bluespace or otherwise."
	prereq_ids = list(
		"bluespace_microfusion",
		"alientech",
	)
	design_ids = list(
		"microfusion_gun_attachment_xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
