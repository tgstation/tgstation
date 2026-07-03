/datum/techweb_node/medbay_equip
	id = TECHWEB_NODE_MEDBAY_EQUIP
	starting_node = TRUE
	display_name = "Оборудование медицинского отдела"
	description = "Базовый комплект медицинского оборудования для оказания неотложной помощи при сохранении функциональности медотдела."
	design_ids = list(
		"beaker",
		"blood_filter",
		"blood_pack",
		"blood_scanner",
		"bonesetter",
		"cautery",
		"chem_pack",
		"circular_saw",
		"defibmountdefault",
		"dropper",
		"hemostat",
		"jerrycan",
		"large_beaker",
		"medicalbed",
		"operating",
		"organ_jar",
		"penlight",
		"penlight_paramedic",
		"pillbottle",
		"reflex_hammer",
		"retractor",
		"scalpel",
		"stethoscope",
		"suit_sensor",
		"surgical_drapes",
		"surgical_tape",
		"surgicaldrill",
		"syringe",
		"vitals_monitor",
		"xlarge_beaker",
	)
	experiments_to_unlock = list(
		/datum/experiment/autopsy/human,
		/datum/experiment/autopsy/nonhuman,
		/datum/experiment/autopsy/xenomorph,
		/datum/experiment/scanning/reagent/haloperidol,
		/datum/experiment/scanning/reagent/cryostylane,
	)

/datum/techweb_node/chem_synthesis
	id = TECHWEB_NODE_CHEM_SYNTHESIS
	display_name = "Химический синтез"
	description = "Технология синтеза сложных химических соединений с использованием электричества и газовых сред."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"med_spray_bottle",
		"inhaler",
		"inhaler_canister",
		"medigel",
		"medipen_refiller",
		"soda_dispenser",
		"beer_dispenser",
		"chem_dispenser",
		"portable_chem_mixer",
		"chem_heater",
		"w-recycler",
		"meta_beaker",
		"plumbing_rcd",
		"plumbing_rcd_service",
		"plunger",
		"fluid_ducts",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/medbay_equip_adv
	id = TECHWEB_NODE_MEDBAY_EQUIP_ADV
	display_name = "Продвинутое оборудование медицинского отдела"
	description = "Современное медицинское оборудование для поддержания жизнеспособности экипажа с минимальными физическими повреждениями."
	prereq_ids = list(TECHWEB_NODE_CHEM_SYNTHESIS)
	design_ids = list(
		"chem_mass_spec",
		"crewpinpointer",
		"defibmount",
		//"diode_disk_healing", // BANDASTATION REMOVAL - Healing beam design removal
		"diode_disk_sanity",
		"healthanalyzer_advanced",
		"medicalbed_emergency",
		"mod_health_analyzer",
		"piercesyringe",
		"smoke_machine",
		"vitals_monitor_advanced",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/reagent/haloperidol)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cryostasis
	id = TECHWEB_NODE_CRYOSTASIS
	display_name = "Криостазис"
	description = "Технология криогенной консервации экипажа, разработанная на основе случайного химического воздействия и адаптированная для безопасного применения."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP_ADV, TECHWEB_NODE_FUSION)
	design_ids = list(
		"cryo_grenade",
		"cryotube",
		"mech_sleeper",
		"splitbeaker",
		"stasis",
		"stasis_bodybag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/reagent/cryostylane = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
