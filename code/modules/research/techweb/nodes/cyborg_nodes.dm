/datum/techweb_node/augmentation
	display_name = "Аугментации"
	description = "Для тех, кто предпочитает блестящий металл мягкой плоти."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/borg_chest,
		/datum/design/borg_head,
		/datum/design/borg_l_arm,
		/datum/design/borg_l_leg,
		/datum/design/borg_r_arm,
		/datum/design/borg_r_leg,
		/datum/design/borg_suit,
		/datum/design/cybernetic_eyes,
		/datum/design/cybernetic_eyes/moth,
		/datum/design/cybernetic_ears,
		/datum/design/cybernetic_ears/cat,
		/datum/design/cybernetic_lungs,
		/datum/design/cybernetic_stomach,
		/datum/design/cybernetic_liver,
		/datum/design/cybernetic_heart,
	)
	experiments_to_unlock = list(
		/datum/experiment/scanning/people/android,
	)

/datum/techweb_node/cybernetics
	display_name = "Кибернетика"
	description = "Разумные роботы с предустановленными инструментальными модулями и программируемыми законами."
	prerequisite_nodes = list(/datum/techweb_node/augmentation)
	unlocked_designs = list(
		/datum/design/board/robocontrol,
		/datum/design/board/cyborgrecharger,
		/datum/design/posibrain,
		/datum/design/mmi,
		/datum/design/mmi/medical,
		/datum/design/advanced_l_arm,
		/datum/design/advanced_r_arm,
		/datum/design/advanced_l_leg,
		/datum/design/advanced_r_leg,
		/datum/design/borg_upgrade_rename,
		/datum/design/borg_upgrade_restart,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_service
	display_name = "Улучшение киборгов обслуживания"
	description = "Специализированные модули для автоматизации кулинарных процессов в соответствии с установленными регламентами."
	prerequisite_nodes = list(/datum/techweb_node/cybernetics)
	unlocked_designs = list(
		/datum/design/borg_upgrade_rolling_table,
		/datum/design/borg_upgrade_condiment_synthesizer,
		/datum/design/borg_upgrade_silicon_knife,
		/datum/design/borg_upgrade_service_apparatus,
		/datum/design/borg_upgrade_drink_apparatus,
		/datum/design/borg_upgrade_service_cookbook,
		/datum/design/borg_upgrade_botany,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_mining
	display_name = "Улучшение киборгов-шахтёров"
	description = "Для работы в условиях, представляющих повышенную опасность для человека."
	prerequisite_nodes = list(/datum/techweb_node/cybernetics)
	unlocked_designs = list(
		/datum/design/borg_upgrade_lavaproof,
		/datum/design/borg_upgrade_holding,
		/datum/design/borg_upgrade_diamonddrill,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_medical
	display_name = "Улучшение киборгов-медиков"
	description = "Реализация Первого закона Азимова в рамках медицинских протоколов."
	prerequisite_nodes = list(/datum/techweb_node/borg_service, /datum/techweb_node/surgery_adv)
	unlocked_designs = list(
		/datum/design/borg_upgrade_pinpointer,
		/datum/design/borg_upgrade_beaker_app,
		/datum/design/borg_upgrade_defibrillator,
		/datum/design/borg_upgrade_expandedsynthesiser,
		/datum/design/borg_upgrade_piercinghypospray,
		/datum/design/borg_upgrade_surgicalprocessor,
		/datum/design/borg_upgrade_surgicalomnitool,
		/datum/design/borg_upgrade_syringe,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_utility
	display_name = "Служебные улучшения киборгов"
	description = "Автоматизация задач по поддержанию санитарного состояния помещений."
	prerequisite_nodes = list(/datum/techweb_node/borg_service, /datum/techweb_node/sanitation)
	unlocked_designs = list(
		/datum/design/borg_upgrade_advancedmop,
		/datum/design/borg_upgrade_broomer,
		/datum/design/borg_upgrade_expand,
		/datum/design/borg_upgrade_prt,
		/datum/design/borg_upgrade_plunger,
		/datum/design/borg_upgrade_high_capacity_replacer,
		/datum/design/borg_upgrade_selfrepair,
		/datum/design/borg_upgrade_thrusters,
		/datum/design/borg_upgrade_trashofholding,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_utility/New()
	. = ..()
	if(!CONFIG_GET(flag/disable_secborg))
		unlocked_designs += /datum/design/borg_upgrade_disablercooler

/datum/techweb_node/borg_engi
	display_name = "Улучшение киборгов-инженеров"
	description = "Оптимизация выполнения технических задач с повышенной эффективностью."
	prerequisite_nodes = list(/datum/techweb_node/borg_mining, /datum/techweb_node/parts_upg)
	unlocked_designs = list(
		/datum/design/borg_upgrade_rped,
		/datum/design/borg_upgrade_engineeringomnitool,
		/datum/design/borg_upgrade_engineering_app,
		/datum/design/borg_upgrade_inducer,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

// Implants root node
/datum/techweb_node/passive_implants
	display_name = "Пассивные импланты"
	description = "Импланты, предназначенные для бесперебойной работы без активного участия пользователя, улучшающие различные физиологические функции или обеспечивающие постоянные преимущества."
	prerequisite_nodes = list(/datum/techweb_node/augmentation)
	unlocked_designs = list(
		/datum/design/board/skill_station,
		/datum/design/implant_sadtrombone,
		/datum/design/implant_chem,
		/datum/design/implant_tracking,
		/datum/design/implant_exile,
		/datum/design/implant_beacon,
		/datum/design/implant_bluespace,
		/datum/design/implantcase,
		/datum/design/implanter,
		/datum/design/locator,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_implants
	display_name = "Кибернетические импланты"
	description = "Передовые технологические усовершенствования, интегрированные в организм, предлагающие улучшенные физические возможности."
	prerequisite_nodes = list(/datum/techweb_node/passive_implants, /datum/techweb_node/cybernetics)
	unlocked_designs = list(
		/datum/design/cyberimp_breather,
		/datum/design/cyberimp_nutriment,
		/datum/design/cyberimp_thrusters,
		/datum/design/cyberimp_herculean,
		/datum/design/cyberimp_connector,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] /= 2

/datum/techweb_node/cyber/combat_implants
	display_name = "Боевые импланты"
	description = "Обеспечение оперативного восстановления боеспособности в критических ситуациях."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(
		/datum/design/cyberimp_reviver,
		/datum/design/cyberimp_antidrop,
		/datum/design/cyberimp_antistun,
		/datum/design/cyberimp_tacvisor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/integrated_toolsets
	display_name = "Встроенный набор инструментов"
	description = "Результат многолетнего анализа методов контрабанды, приведший к разработке компактного инструментального комплекса, интегрируемого в предплечье."
	prerequisite_nodes = list(/datum/techweb_node/cyber/combat_implants, /datum/techweb_node/exp_tools)
	unlocked_designs = list(
		/datum/design/cyberimp_nutriment_plus,
		/datum/design/cyberimp_surgical,
		/datum/design/cyberimp_surgery_brain,
		/datum/design/cyberimp_toolset,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs
	display_name = "Кибернетические органы"
	description = "Технологии реконструкции биологических систем с применением кибернетических компонентов."
	prerequisite_nodes = list(/datum/techweb_node/cybernetics)
	unlocked_designs = list(
		/datum/design/cybernetic_eyes/improved,
		/datum/design/cybernetic_eyes/improved/moth,
		/datum/design/cybernetic_ears_u,
		/datum/design/cybernetic_ears_u/cat,
		/datum/design/cybernetic_lungs/tier2,
		/datum/design/cybernetic_stomach/tier2,
		/datum/design/cybernetic_liver/tier2,
		/datum/design/cybernetic_heart/tier2,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs_upgraded
	display_name = "Улучшенные кибернетические органы"
	description = "Модернизация кибернетических органов с расширенным функционалом."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_organs)
	unlocked_designs = list(
		/datum/design/cyberimp_gloweyes,
		/datum/design/cyberimp_welding,
		/datum/design/cyberimp_gloweyes/moth,
		/datum/design/cyberimp_welding/moth,
		/datum/design/cybernetic_ears_whisper,
		/datum/design/cybernetic_ears_whisper/cat,
		/datum/design/cybernetic_ears_volume,
		/datum/design/cybernetic_ears_volume/cat,
		/datum/design/cybernetic_lungs/tier3,
		/datum/design/cybernetic_stomach/tier3,
		/datum/design/cybernetic_liver/tier3,
		/datum/design/cybernetic_heart/tier3,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/people/augmented_organs)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs_adv
	display_name = "Продвинутые кибернетические органы"
	description = "Передовые кибернетические органы с улучшенными сенсорными возможностями для повышения эффективности обнаружения."
	prerequisite_nodes = list(/datum/techweb_node/cyber/cyber_organs_upgraded, /datum/techweb_node/night_vision)
	unlocked_designs = list(
		/datum/design/cybernetic_ears_xray,
		/datum/design/cybernetic_ears_xray/cat,
		/datum/design/cyberimp_thermals,
		/datum/design/cyberimp_xray,
		/datum/design/cyberimp_thermals/moth,
		/datum/design/cyberimp_xray/moth,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/android = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
