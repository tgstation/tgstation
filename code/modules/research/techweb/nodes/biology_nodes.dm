/datum/techweb_node/bio_scan
	display_name = "Биологическое сканирование"
	description = "Передовые технологии для анализа состояния пациентов и состава реагентов, обеспечивающие точную диагностику и лечение в медицинском отделе."
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip)
	unlocked_designs = list(
		/datum/design/healthanalyzer,
		/datum/design/autopsy_scanner,
		/datum/design/genescanner,
		/datum/design/board/medical_kiosk,
		/datum/design/board/chem_master,
		/datum/design/ph_meter,
		/datum/design/sci_goggles,
		/datum/design/module/mod_reagent_scanner,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cytology
	display_name = "Цитология"
	description = "Исследования в области клеточной биологии, сфокусированные на культивировании конечностей и разнообразных организмов из клеток."
	prerequisite_nodes = list(/datum/techweb_node/bio_scan)
	unlocked_designs = list(
		/datum/design/board/limbgrower,
		/datum/design/board/pandemic,
		/datum/design/board/vatgrower,
		/datum/design/petridish,
		/datum/design/swab,
		/datum/design/biopsy_tool,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/xenobiology
	display_name = "Ксенобиология"
	description = "Изучение нечеловеческой биологии, раскрывающее секреты внеземных форм жизни и их уникальных биологических процессов."
	prerequisite_nodes = list(/datum/techweb_node/cytology)
	unlocked_designs = list(
		/datum/design/board/xenobiocamera,
		/datum/design/slime_scanner,
		/datum/design/limb_disk/ethereal,
		/datum/design/limb_disk/felinid,
		/datum/design/limb_disk/lizard,
		/datum/design/limb_disk/plasmaman,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/cytology/slime = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/gene_engineering
	display_name = "Генная инженерия"
	description = "Исследование сложных методов манипуляции с ДНК, позволяющих модифицировать человеческие генетические признаки для получения специфических способностей и улучшений."
	prerequisite_nodes = list(/datum/techweb_node/selection, /datum/techweb_node/xenobiology)
	unlocked_designs = list(
		/datum/design/board/dnascanner,
		/datum/design/board/scan_console,
		/datum/design/dna_disk,
		/datum/design/board/dnainfuser,
		/datum/design/module/mod_dna_lock,
		/datum/design/flesh_reshapers,
		/datum/design/flesh_reshapers/medical,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/mutant = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

// Botany root node
/datum/techweb_node/botany_equip
	display_name = "Ботаническое оборудование"
	description = "Базовое оборудование для содержания бортовых садов, поддерживающее рост растений в уникальных условиях космической станции."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/seed_extractor,
		/datum/design/plant_analyzer,
		/datum/design/watering_can,
		/datum/design/spade,
		/datum/design/cultivator,
		/datum/design/secateurs,
		/datum/design/hatchet,
	)

/datum/techweb_node/hydroponics
	display_name = "Гидропоника"
	description = "Исследование передовых гидропонных систем для эффективного и устойчивого культивирования растений."
	prerequisite_nodes = list(/datum/techweb_node/botany_equip, /datum/techweb_node/chem_synthesis)
	unlocked_designs = list(
		/datum/design/board/biogenerator,
		/datum/design/board/hydroponics,
		/datum/design/portaseeder,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

/datum/techweb_node/selection
	display_name = "Искусственный отбор"
	description = "Развитие техник культивирования растений посредством искусственного отбора, позволяющее осуществлять точные манипуляции с растительной ДНК."
	prerequisite_nodes = list(/datum/techweb_node/hydroponics)
	unlocked_designs = list(
		/datum/design/flora_gun,
		/datum/design/geneshears,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)
