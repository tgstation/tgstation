/datum/techweb_node/office_equip
	display_name = "Офисное оборудование"
	description = "Передовые разработки Нанотрейзен в области эргономичных офисных технологий, обеспечивающие продуктивность и соответствие корпоративной политике. Даже в космосе документооборот не прекращается."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/fax,
		/datum/design/sec_pen,
		/datum/design/handlabeler,
		/datum/design/paperroll,
		/datum/design/universal_scanner,
		/datum/design/desttagger,
		/datum/design/package_wrap,
		/datum/design/sticky_tape,
		/datum/design/toner/large,
		/datum/design/toner,
		/datum/design/boxcutter,
		/datum/design/bounced_radio,
		/datum/design/radio_headset,
		/datum/design/earmuffs,
		/datum/design/recorder,
		/datum/design/tape,
		/datum/design/toy_balloon,
		/datum/design/pet_carrier,
		/datum/design/chisel,
		/datum/design/spraycan,
		/datum/design/camera_film,
		/datum/design/camera,
		/datum/design/razor,
		/datum/design/bucket,
		/datum/design/mop,
		/datum/design/wet_floor_sign,
		/datum/design/broom,
		/datum/design/normtrash,
		/datum/design/wirebrush,
		/datum/design/flashlight,
		/datum/design/flare,
		/datum/design/water_balloon,
		/datum/design/ticket_machine,
		/datum/design/entertainment_radio,
		/datum/design/rdd,
		/datum/design/board/photopcopier,
	)

/datum/techweb_node/sanitation
	display_name = "Продвинутые санитарные технологии"
	description = "Новейшие разработки Нанотрейзен в области клининговых технологий, обеспечивающие безупречную чистоту станции и отсутствие медведей."
	prerequisite_nodes = list(/datum/techweb_node/office_equip)
	unlocked_designs = list(
		/datum/design/advmop,
		/datum/design/light_replacer,
		/datum/design/spraybottle,
		/datum/design/paint_remover,
		/datum/design/beartrap,
		/datum/design/buffer_upgrade,
		/datum/design/vacuum_upgrade,
		/datum/design/board/washing_machine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/janitor_trash = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

/datum/techweb_node/consoles
	display_name = "Гражданские консоли"
	description = "Пользовательские консоли для нетехнического персонала, улучшающие коммуникацию и доступ к основной информации станции."
	prerequisite_nodes = list(/datum/techweb_node/office_equip)
	unlocked_designs = list(
		/datum/design/board/comconsole,
		/datum/design/board/announcement_system,
		/datum/design/board/cargo,
		/datum/design/board/cargorequest,
		/datum/design/board/med_data,
		/datum/design/board/crewconsole,
		/datum/design/board/bankmachine,
		/datum/design/board/accounting_console,
		/datum/design/id,
		/datum/design/card_reader,
		/datum/design/board/libraryconsole,
		/datum/design/board/libraryscanner,
		/datum/design/board/bookbinder,
		/datum/design/barcode_scanner,
		/datum/design/board/vendor,
		/datum/design/custom_vendor_refill,
		/datum/design/board/bountypad_control,
		/datum/design/board/bountypad,
		/datum/design/digital_clock_frame,
		/datum/design/telescreen_research,
		/datum/design/telescreen_ordnance,
		/datum/design/telescreen_interrogation,
		/datum/design/telescreen_prison,
		/datum/design/telescreen_bar,
		/datum/design/telescreen_entertainment,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

/datum/techweb_node/consoles/New()
	. = ..()
	var/has_monastery = CHECK_MAP_JOB_CHANGE(JOB_CHAPLAIN, "has_monastery")
	if(has_monastery)
		unlocked_designs += /datum/design/telescreen_monastery

/datum/techweb_node/gaming
	display_name = "Гейминг"
	description = "Изучение игровых автоматов для бездельников станции."
	prerequisite_nodes = list(/datum/techweb_node/consoles)
	unlocked_designs = list(
		/datum/design/board/arcade_battle,
		/datum/design/board/orion_trail,
		/datum/design/board/slot_machine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/physical/arcade_winner = TECHWEB_TIER_2_POINTS)

// Kitchen root node
/datum/techweb_node/cafeteria_equip
	display_name = "Оборудование для кафетерия"
	description = "Разработка оборудования для организации питания экипажа после отказа от тюбиковой еды."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/griddle,
		/datum/design/board/microwave,
		/datum/design/bowl,
		/datum/design/plate,
		/datum/design/oven_tray,
		/datum/design/tray,
		/datum/design/tongs,
		/datum/design/spoon,
		/datum/design/fork,
		/datum/design/kitchen_knife,
		/datum/design/plastic_spoon,
		/datum/design/plastic_fork,
		/datum/design/plastic_knife,
		/datum/design/shaker,
		/datum/design/drinking_glass,
		/datum/design/shot_glass,
		/datum/design/coffee_cartridge,
		/datum/design/board/coffeemaker,
		/datum/design/coffeepot,
		/datum/design/syrup_bottle,
		/datum/design/cafeteria_tray,
		/datum/design/board/restaurant_portal,
	)

/datum/techweb_node/food_proc
	display_name = "Пищевая промышленность"
	description = "Высококлассное кухонное оборудование Нанотрейзен, предназначенное для обеспечения сытости и удовлетворенности экипажа."
	prerequisite_nodes = list(/datum/techweb_node/cafeteria_equip)
	unlocked_designs = list(
		/datum/design/board/deepfryer,
		/datum/design/board/oven,
		/datum/design/board/stove,
		/datum/design/board/range,
		/datum/design/board/processor,
		/datum/design/board/gibber,
		/datum/design/board/monkey_recycler,
		/datum/design/board/reagentgrinder,
		/datum/design/board/microwave_engineering,
		/datum/design/board/smartfridge,
		/datum/design/board/dehydrator,
		/datum/design/board/sheetifier,
		/datum/design/board/fat_sucker,
		/datum/design/board/dish_drive,
		/datum/design/roastingstick,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

// Fishing root node
/datum/techweb_node/fishing_equip
	display_name = "Рыболовные снасти"
	description = "Базовое рыболовное снаряжение, адаптированное для условий космической станции, идеально подходящее для внеземных водных промыслов."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/fishing_portal_generator,
		/datum/design/fishing_rod_basic,
		/datum/design/fish_case,
		/datum/design/aquarium_kit,
	)

/datum/techweb_node/fishing_equip_adv
	display_name = "Продвинутые рыболовные снасти"
	description = "Дальнейшее развитие рыболовных технологий с использованием передовых решений для космического рыболовства. Использование на космических карпах строго не рекомендуется."
	prerequisite_nodes = list(/datum/techweb_node/fishing_equip)
	unlocked_designs = list(
		/datum/design/fishing_rod_tech,
		/datum/design/fishing_gloves,
		/datum/design/module/fishing_glove,
		/datum/design/stabilized_hook,
		/datum/design/auto_reel,
		/datum/design/fish_analyzer,
		/datum/design/bluespace_fish_case,
		/datum/design/bluespace_fish_tank,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/fish)

/datum/techweb_node/marine_util
	display_name = "Польза моря"
	description = "На рыбу приятно смотреть, но её можно и использовать с пользой."
	prerequisite_nodes = list(/datum/techweb_node/fishing_equip_adv)
	unlocked_designs = list(
		/datum/design/bioelec_gen,
		/datum/design/bluespace_reel,
		/datum/design/fish_genegun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	// only available if you've done the first fishing experiment (thus unlocking fishing tech), but not a strict requirement to get the tech
	discount_experiments = list(/datum/experiment/scanning/fish/second = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/fishing_anomalous
	display_name = "Anomalous Fishing"
	description = "For the truly adventurous fisher, these experimental tools could augment your catches in unpredictable ways."
	prerequisite_nodes = list(/datum/techweb_node/fishing_equip_adv, /datum/techweb_node/anomaly_research)
	unlocked_designs = list(
		/datum/design/anomalous_fishing_hook,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
