/datum/techweb_node/nanite_base
	id = "nanite_base"
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	prereq_ids = list("datatheory")
	design_ids = list(
		"access_nanites",
		"debugging_nanites",
		"monitoring_nanites",
		"nanite_chamber",
		"nanite_chamber_control",
		"nanite_cloud_control",
		"nanite_comm_remote",
		"nanite_disk",
		"nanite_program_hub",
		"nanite_programmer",
		"nanite_remote",
		"nanite_scanner",
		"public_nanite_chamber",
		"relay_nanites",
		"relay_repeater_nanites",
		"repairing_nanites",
		"repeater_nanites",
		"sensor_nanite_volume",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/nanite_smart
	id = "nanite_smart"
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list("nanite_base","robotics")
	design_ids = list(
		"memleak_nanites",
		"metabolic_nanites",
		"purging_nanites",
		"sensor_voice_nanites",
		"stealth_nanites",
		"voice_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_mesh
	id = "nanite_mesh"
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prereq_ids = list("nanite_base","engineering")
	design_ids = list(
		"conductive_nanites",
		"cryo_nanites",
		"dermal_button_nanites",
		"emp_nanites",
		"hardening_nanites",
		"refractive_nanites",
		"shock_nanites",
		"temperature_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_bio
	id = "nanite_bio"
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list("nanite_base","biotech")
	design_ids = list(
		"bloodheal_nanites",
		"coagulating_nanites",
		"flesheating_nanites",
		"poison_nanites",
		"regenerative_nanites",
		"sensor_crit_nanites",
		"sensor_damage_nanites",
		"sensor_death_nanites",
		"sensor_health_nanites",
		"sensor_species_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list("nanite_bio")
	design_ids = list(
		"bad_mood_nanites",
		"brainheal_nanites",
		"good_mood_nanites",
		"nervous_nanites",
		"paralyzing_nanites",
		"selfscan_nanites",
		"stun_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list("nanite_neural","neural_programming")
	design_ids = list(
		"blinding_nanites",
		"hallucination_nanites",
		"mindshield_nanites",
		"mute_nanites",
		"pacifying_nanites",
		"sleep_nanites",
		"speech_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology. Passively increases nanite regeneration rate for all clouds upon researching."
	prereq_ids = list("nanite_bio","nanite_smart","nanite_mesh")
	design_ids = list(
		"aggressive_nanites",
		"brainheal_plus_nanites",
		"defib_nanites",
		"fakedeath_nanites",
		"purging_plus_nanites",
		"regenerative_plus_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 3000)

/datum/techweb_node/nanite_combat
	id = "nanite_military"
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list("nanite_harmonic", "syndicate_basic")
	design_ids = list(
		"explosive_nanites",
		"meltdown_nanites",
		"nanite_sting_nanites",
		"pyro_nanites",
		"viral_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list("nanite_harmonic", "alientech")
	design_ids = list(
		"mindcontrol_nanites",
		"mitosis_nanites",
		"spreading_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)

/datum/techweb_node/nanite_replication_protocols
	id = "nanite_replication_protocols"
	display_name = "Nanite Replication Protocols"
	description = "Protocols that overwrite the default nanite replication routine to achieve more efficiency in certain circumstances."
	prereq_ids = list("nanite_smart")
	design_ids = list(
		"factory_nanites",
		"kickstart_nanites",
		"offline_nanites",
		"pyramid_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/nanite_storage_protocols
	id = "nanite_storage_protocols"
	display_name = "Nanite Storage Protocols"
	description = "Protocols that overwrite the default nanite storage routine to achieve more efficiency or greater capacity."
	prereq_ids = list("nanite_smart")
	design_ids = list(
		"free_range_nanites",
		"hive_nanites",
		"unsafe_storage_nanites",
		"zip_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 2500)
	hidden = TRUE
	experimental = TRUE
