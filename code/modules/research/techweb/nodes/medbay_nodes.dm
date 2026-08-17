/datum/techweb_node/medbay_equip
	display_name = "Оборудование медицинского отдела"
	description = "Базовый комплект медицинского оборудования для оказания неотложной помощи при сохранении функциональности медотдела."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/beaker,
		/datum/design/blood_filter,
		/datum/design/blood_pack,
		/datum/design/blood_scanner,
		/datum/design/bonesetter,
		/datum/design/cautery,
		/datum/design/chem_pack,
		/datum/design/circular_saw,
		/datum/design/defibrillator_mount,
		/datum/design/dropper,
		/datum/design/hemostat,
		/datum/design/jerrycan,
		/datum/design/large_beaker,
		/datum/design/medical_bed,
		/datum/design/board/operating,
		/datum/design/organ_jar,
		/datum/design/penlight,
		/datum/design/penlight_paramedic,
		/datum/design/pillbottle,
		/datum/design/reflexhammer,
		/datum/design/retractor,
		/datum/design/scalpel,
		/datum/design/stethoscope,
		/datum/design/suit_sensor,
		/datum/design/surgical_drapes,
		/datum/design/sticky_tape/surgical,
		/datum/design/surgicaldrill,
		/datum/design/syringe,
		/datum/design/vitals_monitor,
		/datum/design/xlarge_beaker,
	)
	experiments_to_unlock = list(
		/datum/experiment/autopsy/human,
		/datum/experiment/autopsy/nonhuman,
		/datum/experiment/autopsy/xenomorph,
		/datum/experiment/scanning/reagent/haloperidol,
		/datum/experiment/scanning/reagent/cryostylane,
	)

/datum/techweb_node/chem_synthesis
	display_name = "Химический синтез"
	description = "Технология синтеза сложных химических соединений с использованием электричества и газовых сред."
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip)
	unlocked_designs = list(
		/datum/design/medical_spray_bottle,
		/datum/design/inhaler,
		/datum/design/inhaler_canister,
		/datum/design/medigel,
		/datum/design/board/medipen_refiller,
		/datum/design/board/soda_dispenser,
		/datum/design/board/beer_dispenser,
		/datum/design/board/chem_dispenser,
		/datum/design/portable_chem_mixer,
		/datum/design/board/chem_heater,
		/datum/design/water_recycler,
		/datum/design/meta_beaker,
		/datum/design/plumbing_rcd,
		/datum/design/plumbing_rcd_service,
		/datum/design/plunger,
		/datum/design/ducts,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/medbay_equip_adv
	display_name = "Продвинутое оборудование медицинского отдела"
	description = "Современное медицинское оборудование для поддержания жизнеспособности экипажа с минимальными физическими повреждениями."
	prerequisite_nodes = list(/datum/techweb_node/chem_synthesis)
	unlocked_designs = list(
		/datum/design/board/chem_mass_spec,
		/datum/design/crewpinpointer,
		/datum/design/defibrillator_mount_charging,
		// /datum/design/diode_disk_healing, // BANDASTATION EDIT: Healing beam design removal
		/datum/design/diode_disk_sanity,
		/datum/design/healthanalyzer_advanced,
		/datum/design/emergency_bed,
		/datum/design/module/mod_health_analyzer,
		/datum/design/piercesyringe,
		/datum/design/board/smoke_machine,
		/datum/design/vitals_monitor/advanced,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/reagent/haloperidol)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cryostasis
	display_name = "Криостазис"
	description = "Технология криогенной консервации экипажа, разработанная на основе случайного химического воздействия и адаптированная для безопасного применения."
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip_adv, /datum/techweb_node/fusion)
	unlocked_designs = list(
		/datum/design/cryo_grenade,
		/datum/design/board/cryotube,
		/datum/design/mech_sleeper,
		/datum/design/noreactbeaker,
		/datum/design/board/stasis,
		/datum/design/stasis_bag,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/reagent/cryostylane = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
