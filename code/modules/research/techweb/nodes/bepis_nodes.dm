// Nodes that are found inside Bepis Disks.

/datum/techweb_node/bepis
	abstract_type = /datum/techweb_node/bepis
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_EXPERIMENTAL

/datum/techweb_node/bepis/light_apps
	display_name = "Технологии освещения"
	description = "Применение технологий освещения и визуализации, которые изначально не считались коммерчески жизнеспособными."
	unlocked_designs = list(
		/datum/design/bright_helmet,
		/datum/design/rld_mini,
		/datum/design/photon_cannon,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/extreme_office
	display_name = "Продвинутые офисные улучшения"
	description = "Оптимизация рабочих процессов и внедрение инновационных решений для повышения эффективности документооборота и административной деятельности на 350%."
	unlocked_designs = list(
		/datum/design/mauna_mug,
		/datum/design/rolling_table,
		/datum/design/plasticducky,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/spec_eng
	display_name = "Специализированное снаряжение инженерии"
	description = "Общепринятое мнение считает эти инженерные продукты «технически» безопасными, но слишком опасными, чтобы с ними можно было традиционно мириться."
	unlocked_designs = list(
		/datum/design/eng_gloves,
		/datum/design/lavarods,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/bepis/aus_security
	display_name = "Протоколы безопасности Австраликус"
	description = "Говорят, что в секторе Австраликус строгая безопасность, так что мы позаимствовали некоторые элементы их экипировки. К счастью, в нашем секторе нет никаких признаков этих «дропбеаров»."
	unlocked_designs = list(
		/datum/design/pin_explorer,
		/datum/design/stun_boomerang,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/interrogation
	display_name = "Усовершенствованная технология ведения допроса"
	description = "Сопоставив несколько рассекреченных документов прошлых диктаторских режимов, мы смогли разработать невероятно эффективное устройство для ведения допроса. \
	Согласно галактическому законодательству, этические соображения, связанные с потерей свободы воли, не распространяются на преступников."
	unlocked_designs = list(
		/datum/design/board/hypnochair,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/sticky_advanced
	display_name = "Передовая технология прилипания"
	description = "Экспериментальные разработки в области адгезивных материалов. Результаты показывают, что данный образец демонстрирует аномально высокие показатели сцепления с поверхностями — лаборатория не несет ответственности за невозможность последующего отделения материала."
	unlocked_designs = list(
		/datum/design/pointy_tape,
		/datum/design/super_sticky_tape,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/tackle_advanced
	display_name = "Продвинутая технология захвата"
	description = "Корпорация Нанотрейзен напоминает своему исследовательскому персоналу, что «тискать» своих коллег совершенно недопустимо, и дальнейшие «научные испытания» по данной теме больше не будут приниматься в академических журналах корпорации."
	unlocked_designs = list(
		/datum/design/tackle_dolphin,
		/datum/design/tackle_rocket,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/bepis/mod_experimental
	display_name = "Экспериментальные МОДули"
	description = "Применение экспериментальности при создании МОДкостюмов привело к появлению такого."
	unlocked_designs = list(
		/datum/design/module/disposal,
		/datum/design/module/joint_torsion,
		/datum/design/module/recycler,
		/datum/design/module/shooting_assistant,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/bepis/posisphere
	display_name = "Экспериментальный сферический позитронный мозг"
	description = "Недавние разработки в области сокращения затрат позволили нам разрезать кубики позитронного мозга на сферы, которые стоят вдвое дешевле. К сожалению, это также позволяет им перемещаться по лаборатории с помощью подвижных маневров."
	unlocked_designs = list(
		/datum/design/posisphere,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bepis/donk_shell
	display_name = "Схемы неудачных продуктов компании Donk Co."
	description = "Нанотрейзен не интересуют причины наполнения ваших базы данных известными неудачными продуктами корпорации-конкурента. Это ваш выбор. Однако предупреждаем: в случае загрузки вредоносного ПО, связанного с продукцией Donk Co. и похищающего ваши пароли от Starscape, не ожидайте поддержки. Сотрудники указанной корпорации способны удалить вашего персонажа."
	unlocked_designs = list(
		/datum/design/donkflechette,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)
