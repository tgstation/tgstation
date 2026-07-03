//Nodes that are found inside Bepis Disks.

/datum/techweb_node/light_apps
	id = TECHWEB_NODE_LIGHT_APPS
	display_name = "Технологии освещения"
	description = "Применение технологий освещения и визуализации, которые изначально не считались коммерчески жизнеспособными."
	design_ids = list(
		"bright_helmet",
		"rld_mini",
		"photon_cannon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/extreme_office
	id = TECHWEB_NODE_EXTREME_OFFICE
	display_name = "Продвинутые офисные улучшения"
	description = "Оптимизация рабочих процессов и внедрение инновационных решений для повышения эффективности документооборота и административной деятельности на 350%."
	design_ids = list(
		"mauna_mug",
		"rolling_table",
		"plasticducky",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/spec_eng
	id = TECHWEB_NODE_SPEC_ENG
	display_name = "Специализированное снаряжение инженерии"
	description = "Общепринятое мнение считает эти инженерные продукты «технически» безопасными, но слишком опасными, чтобы с ними можно было традиционно мириться."
	design_ids = list(
		"eng_gloves",
		"lava_rods",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/aus_security
	id = TECHWEB_NODE_AUS_SECURITY
	display_name = "Протоколы безопасности Австраликус"
	description = "Говорят, что в секторе Австраликус строгая безопасность, так что мы позаимствовали некоторые элементы их экипировки. К счастью, в нашем секторе нет никаких признаков этих «дропбеаров»."
	design_ids = list(
		"pin_explorer",
		"stun_boomerang",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/interrogation
	id = TECHWEB_NODE_INTERROGATION
	display_name = "Усовершенствованная технология ведения допроса"
	description = "Сопоставив несколько рассекреченных документов прошлых диктаторских режимов, мы смогли разработать невероятно эффективное устройство для ведения допроса. \
	Согласно галактическому законодательству, этические соображения, связанные с потерей свободы воли, не распространяются на преступников."
	design_ids = list(
		"hypnochair",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/sticky_advanced
	id = TECHWEB_NODE_STICKY_ADVANCED
	display_name = "Передовая технология прилипания"
	description = "Экспериментальные разработки в области адгезивных материалов. Результаты показывают, что данный образец демонстрирует аномально высокие показатели сцепления с поверхностями — лаборатория не несет ответственности за невозможность последующего отделения материала."
	design_ids = list(
		"pointy_tape",
		"super_sticky_tape",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/tackle_advanced
	id = TECHWEB_NODE_TACKLE_ADVANCED
	display_name = "Продвинутая технология захвата"
	description = "Корпорация Нанотрейзен напоминает своему исследовательскому персоналу, что «тискать» своих коллег совершенно недопустимо, и дальнейшие «научные испытания» по данной теме больше не будут приниматься в академических журналах корпорации."
	design_ids = list(
		"tackle_dolphin",
		"tackle_rocket",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/mod_experimental
	id = TECHWEB_NODE_MOD_EXPERIMENTAL
	display_name = "Экспериментальные МОДули"
	description = "Применение экспериментальности при создании МОДкостюмов привело к появлению такого."
	design_ids = list(
		"mod_disposal",
		"mod_joint_torsion",
		"mod_recycler",
		"mod_shooting",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_COMMON)

/datum/techweb_node/posisphere
	id = TECHWEB_NODE_POSITRONIC_SPHERE
	display_name = "Экспериментальный сферический позитронный мозг"
	description = "Недавние разработки в области сокращения затрат позволили нам разрезать кубики позитронного мозга на сферы, которые стоят вдвое дешевле. К сожалению, это также позволяет им перемещаться по лаборатории с помощью подвижных маневров."
	design_ids = list(
		"posisphere",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/donk_shell
	id = TECHWEB_NODE_DONK_PRODUCTS
	display_name = "Схемы неудачных продуктов компании Donk Co."
	description = "Нанотрейзен не интересуют причины наполнения ваших базы данных известными неудачными продуктами корпорации-конкурента. Это ваш выбор. Однако предупреждаем: в случае загрузки вредоносного ПО, связанного с продукцией Donk Co. и похищающего ваши пароли от Starscape, не ожидайте поддержки. Сотрудники указанной корпорации способны удалить вашего персонажа."
	design_ids = list(
		"donkshell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE
	announce_channels = list(RADIO_CHANNEL_SECURITY)
