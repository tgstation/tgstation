/datum/supply_pack/engineering
	group = "Engineering"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/shieldgen
	name = "Ящик с противопробойным генератором щита"
	desc = "Опять пробит корпус? Ни слова больше при использовании противопробойного генератора поля Нанотрейзен! \
		Использует технологию силового поля, чтобы удерживать воздух внутри и космос снаружи. Содержит 2 генератора силового поля внутри."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/shieldgen = 2)
	crate_name = "ящик с противопробойным генератором щита"

/datum/supply_pack/engineering/ripley
	name = "Ящик с АПЛУ МОД-1"
	desc = "Набор «сделай сам» с АПЛУ МОД-1 \"Рипли\", разработанный для пoдъёма и \
		переноса тяжёлого снаряжения, а также других задач на станции. Без батареек."
	cost = CARGO_CRATE_VALUE * 10
	access_view = ACCESS_ROBOTICS
	contains = list(/obj/item/mecha_parts/chassis/ripley,
					/obj/item/mecha_parts/part/ripley_torso,
					/obj/item/mecha_parts/part/ripley_right_arm,
					/obj/item/mecha_parts/part/ripley_left_arm,
					/obj/item/mecha_parts/part/ripley_right_leg,
					/obj/item/mecha_parts/part/ripley_left_leg,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/scanning_module,
					/obj/item/stock_parts/servo,
					/obj/item/circuitboard/mecha/ripley/main,
					/obj/item/circuitboard/mecha/ripley/peripherals,
					/obj/item/mecha_parts/mecha_equipment/drill,
					/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
				)
	crate_name= "набор АПЛУ МОД-1"
	crate_type = /obj/structure/closet/crate/science/robo

/datum/supply_pack/engineering/conveyor
	name = "Ящик сборочных компонентов конвейера"
	desc = "Наладьте непрерывное производство с помощью тридцати конвейерных лент. В состав входит переключатель. \
		А так же инструкция для тех, у кого остались вопросы."
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/stack/conveyor/thirty,
					/obj/item/conveyor_switch_construct,
					/obj/item/paper/guides/conveyor,
				)
	crate_name = "ящик сборочных компонентов конвейера"

/datum/supply_pack/engineering/engiequipment
	name = "Ящик инженерного снаряжения"
	desc = "Снарядитесь тремя поясами для инструментов, жилетами со светоотражателями, масками для сварки, касками, \
		и двумя парами мезонных очков!"
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/storage/belt/utility = 3,
					/obj/item/clothing/suit/hazardvest = 3,
					/obj/item/clothing/head/utility/welding = 3,
					/obj/item/clothing/head/utility/hardhat = 3,
					/obj/item/clothing/glasses/meson/engine = 2,
				)
	crate_name = "ящик инженерного снаряжения"

/datum/supply_pack/engineering/powergamermitts
	name = "Ящик изолирующих перчаток"
	desc = "Кость в горле современного общества. Практически не используются для инженерных работ. \
		Содержит три пары изолирующих перчаток."
	cost = CARGO_CRATE_VALUE * 8 //Made of pure-grade bullshittinium
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/clothing/gloves/color/yellow = 3)
	crate_name = "ящик изолирующих перчаток"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/inducers
	name = "Ящик электромагнитных силовых индукторов НТ-75"
	desc = "Нет зарядников? Не беда! С помощью ЭМСИ НТ-75 вы можете зарядить\
		аккумуляторное снаряжение в любое время, в любом месте. Содержит два индуктора."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/inducer/orderable = 2)
	crate_name = "ящик электромагнитных силовых индукторов НТ-75"
	crate_type = /obj/structure/closet/crate/nakamura

/datum/supply_pack/engineering/pacman
	name = "Ящик с генератором P.A.C.M.A.N"
	desc = "Инженеры не могут запустить двигатель? Это перестанет быть вашей проблемой, после того, как вы получите ваш личный генератор P.A.C.M.A.N.! \
		Поглощает плазму, выдавая сладкую энергию."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/machinery/power/port_gen/pacman)
	crate_name = "ящик с генератором P.A.C.M.A.N"
	crate_type = /obj/structure/closet/crate/nakamura

/datum/supply_pack/engineering/power
	name = "Ящик батареек"
	desc = "Вы ищете больше СИЛЫ (тока)? Вы её нашли. Контейнер содержит три высоковольтные батареи питания."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/stock_parts/power_store/cell/high = 3)
	crate_name = "ящик батареек"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/shuttle_engine
	name = "Ящик с двигателем шаттла"
	desc = "Благодаря передовым блюспейс-технологиям, наши инженеры придумали, как запихать целый двигатель шаттла \
		в маленюсенький ящичек."
	cost = CARGO_CRATE_VALUE * 6
	access = ACCESS_ENGINEERING
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/flatpack/shuttle_engine)
	crate_name = "ящик с двигателем шаттла"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/tools
	name = "Ящик с ящиками для инструментов"
	desc = "Любой робастный космонавтик всегда имеет под рукой надёжный ящик с инструментами. Содержит три ящика электрика \
		и три ящика механика."
	access_view = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/storage/toolbox/electrical = 3,
					/obj/item/storage/toolbox/mechanical = 3,
				)
	cost = CARGO_CRATE_VALUE * 5
	crate_name = "ящик с ящиками для инструментов"

/datum/supply_pack/engineering/portapump
	name = "Ящик с портативными воздушными насосами"
	desc = "Кто-то опять решил проветрить шаттл? Мы вас прикроем. \
		Содержит два портативных насоса для воздуха."
	cost = CARGO_CRATE_VALUE * 4.5
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/pump = 2)
	crate_name = "ящик с портативными воздушными насосами"
	crate_type = /obj/structure/closet/crate/secure/engineering/atmos

/datum/supply_pack/engineering/portascrubber
	name = "Ящик с портативными очистителями воздуха"
	desc = "Устраните досадную утечку плазмы с помощью вашего собственного набора из двух портативных скрубберов."
	cost = CARGO_CRATE_VALUE * 4.5
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/scrubber = 2)
	crate_name = "ящик с портативными очистителями воздуха"
	crate_type = /obj/structure/closet/crate/secure/engineering/atmos

/datum/supply_pack/engineering/hugescrubber
	name = "Ящик с крупным портативным очистителем воздуха"
	desc = "Большой переносной очиститель, для больших атмосферных проблем."
	cost = CARGO_CRATE_VALUE * 7.5
	access_view = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/scrubber/huge/movable/cargo)
	crate_name = "ящик с крупным портативным очистителем воздуха"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/space_heater
	name = "Ящик обогревателей"
	desc = "Обогреватель/охладитель двойного назначения, для прохладных ситуаций или когда вы превращаетесь в тост."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/machinery/space_heater)
	crate_name = "ящик обогревателей"
	crate_type = /obj/structure/closet/crate/secure/engineering/atmos

/datum/supply_pack/engineering/bsa
	name = "Компоненты блюспейс артиллерии"
	desc = "Гордость военно-космического командования Нанотрейзен. Легендарное артиллерийское блюспейс-орудие является \
		разрушительным подвигом человеческой инженерии и свидетельством решимости военного времени. \
		Для постройки необходимы наиболее передовые технологии."
	cost = CARGO_CRATE_VALUE * 30
	highlight_in_console = TRUE
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/paper/guides/jobs/engineering/bsa,
					/obj/item/circuitboard/machine/bsa/front,
					/obj/item/circuitboard/machine/bsa/middle,
					/obj/item/circuitboard/machine/bsa/back,
					/obj/item/circuitboard/computer/bsa_control,
				)
	crate_name= "ящик с деталями блюспейс артилерии"

/datum/supply_pack/engineering/dna_vault
	name = "Компоненты ДНК хранилища"
	desc = "Обеспечьте долговечность текущего состояния человечества в этой огромной \
		библиотеке научных знаний, способной даровать сверхчеловеческие силы и способности. \
		Для постройки необходимы наиболее передовые технологии. Также содержит пять ДНК сэмплеров."
	cost = CARGO_CRATE_VALUE * 24
	highlight_in_console = TRUE
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/circuitboard/machine/dna_vault,
					/obj/item/dna_probe = 5,
				)
	crate_name= "ящик с деталями ДНК хранилища"

/datum/supply_pack/engineering/dna_probes
	name = "Сэмплеры ДНК хранилища"
	desc = "Содержит 5 ДНК сэмплеров, используемых для заполнения хранилища ДНК."
	cost = CARGO_CRATE_VALUE * 6
	order_flags = ORDER_SPECIAL
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/dna_probe = 5)
	crate_name= "ящик ДНК сэмплеров"


/datum/supply_pack/engineering/shield_sat
	name = "Спутники метеоритного щита"
	desc = "Защитите существование этой станции с помощью системы противометеорной защиты. \
		Содержит три спутника метеоритного щита."
	cost = CARGO_CRATE_VALUE * 6
	highlight_in_console = TRUE
	access_view = ACCESS_COMMAND
	contains = list(/obj/machinery/satellite/meteor_shield = 3)
	crate_name= "ящик спутников метеоритного щита"


/datum/supply_pack/engineering/shield_sat_control
	name = "Плата управления системой защиты"
	desc = "Система управления системой спутников противометеорной защиты."
	cost = CARGO_CRATE_VALUE * 10
	highlight_in_console = TRUE
	access_view = ACCESS_COMMAND
	contains = list(/obj/item/circuitboard/computer/sat_control)
	crate_name= "ящик с платой управления системы противометеорной защиты"

/datum/supply_pack/engineering/ceturtlenecks
	name = "Водолазка главного инженера"
	desc = "Содержит водолазку и юбку-водолазку главного инженера."
	cost = CARGO_CRATE_VALUE * 2
	access = ACCESS_CE
	contains = list(/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck,
					/obj/item/clothing/under/rank/engineering/chief_engineer/turtleneck/skirt,
				)
	crate_name= "ящик с водолазкой главного инженера"

/// Engine Construction

/datum/supply_pack/engine
	group = "Engine Construction"
	access_view = ACCESS_ENGINEERING
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engine/emitter
	name = "Ящик эмиттеров"
	desc = "Одинаково полезны для активации генераторов силового поля, уничтожения ящиков и злоумышленников. \
		Содержит два высокомощных эмиттера."
	cost = CARGO_CRATE_VALUE * 7
	access = ACCESS_CE
	contains = list(/obj/machinery/power/emitter = 2)
	crate_name = "ящик эмиттеров"
	crate_type = /obj/structure/closet/crate/secure/engineering
	order_flags = ORDER_DANGEROUS

/datum/supply_pack/engine/field_gen
	name = "Ящик генераторов поля"
	desc = "Обычно единственный барьер, стоящий между станцией и абсурдной смертью. \
		Запитывается эммитерами. Содержит два генератора поля."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/machinery/field/generator = 2)
	crate_name = "ящик генераторов поля"

/datum/supply_pack/engine/grounding_rods
	name = "Ящик заземлителей"
	desc = "Четыре заземлителя гарантированно удержат любую шальную молнию, созданную теслой, под контролем."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/machinery/power/energy_accumulator/grounding_rod = 4)
	crate_name = "ящик заземлителей"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/solar
	name = "Ящик солнечных панелей"
	desc = "Станьте экоактивистом с помощью самодельных усовершенствованных солнечных панелей для самостоятельной установки. В комплекте содержится двадцать одна солнечная панель, \
		плата для управления солнечными панелями и трекер. Если у вас остались вопросы, \
		пожалуйста, ознакомьтесь с прилагаемой инструкцией."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/solar_assembly = 21,
					/obj/item/circuitboard/computer/solar_control,
					/obj/item/electronics/tracker,
					/obj/item/paper/guides/jobs/engi/solars,
				)
	crate_name = "ящик солнечных панелей"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/supermatter_shard
	name = "Ящик с осколком суперматерии"
	desc = "Сила небес, сконцентрированная в одном кристалле."
	cost = CARGO_CRATE_VALUE * 20
	access = ACCESS_CE
	contains = list(/obj/machinery/power/supermatter_crystal/shard)
	crate_name = "ящик с осколком суперматерии"
	crate_type = /obj/structure/closet/crate/secure/radiation
	order_flags = ORDER_DANGEROUS
	discountable = SUPPLY_PACK_RARE_DISCOUNTABLE

/datum/supply_pack/engine/tesla_coils
	name = "Ящик с катушками Теслы"
	desc = "Будь то казнь электричесвом, генерация очков исследований, или спланированная \
		старая добрая электрификация ассистентов: этот набор из четырёх катушек Теслы может всё!"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/machinery/power/energy_accumulator/tesla_coil = 4)
	crate_name = "ящик с катушками Теслы"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/hypertorus_fusion_reactor
	name = "Ящик с ТРГ"
	desc = "Новый улучшенный термоядерный реактор."
	cost = CARGO_CRATE_VALUE * 23
	access = ACCESS_CE
	contains = list(/obj/item/hfr_box/corner = 4,
					/obj/item/hfr_box/body/fuel_input,
					/obj/item/hfr_box/body/moderator_input,
					/obj/item/hfr_box/body/waste_output,
					/obj/item/hfr_box/body/interface,
					/obj/item/hfr_box/core,
				)
	crate_name = "ящик с ТРГ"
	crate_type = /obj/structure/closet/crate/secure/engineering/atmos
	order_flags = ORDER_DANGEROUS

/datum/supply_pack/engineering/rad_protection_modules
	name = "Модули радиационной защиты"
	desc = "Содержит несколько модулей противорадиационной защиты для МОДов."
	order_flags = ORDER_INVISIBLE
	contains = list(/obj/item/mod/module/rad_protection = 3)
	crate_name = "ящик модулей радиационной защиты"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/rad_nebula_shielding_kit
	name = "Радиоактивный щит «Небула»"
	desc = "Содержит печатные платы и радиационные модули для создания радиоактивной защиты «Небула»."
	cost = CARGO_CRATE_VALUE * 2

	order_flags = ORDER_SPECIAL
	contains = list(
		/obj/item/mod/module/rad_protection = 5,
		/obj/item/circuitboard/machine/radioactive_nebula_shielding = 5,
		/obj/item/paper/fluff/radiation_nebula = 1,
	)
	crate_name = "ящик с радиоактивным щитом «Небула» (ВАЖНОЕ)"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/portagrav
	name = "Ящик с переносным гравитационным блоком"
	desc = "Содержит переносной гравитационный блок, позволяющий клоуну свободно парить под потолком."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/machinery/power/portagrav = 1)
	crate_name = "ящик с переносным гравитационным блоком"
	crate_type = /obj/structure/closet/crate/engineering

/datum/supply_pack/engineering/golfcart
	name = "Ящик с комплектом запчастей для гольф кара"
	desc = "Содержит детали для сборки карта, предназначенного для перемещения тяжелой техники и грузов по станции. \
		Нанотрейзен не несет ответственности за карты работающие 'станционными маршрутками'."
	cost = CARGO_CRATE_VALUE * 11
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/item/golfcart_kit = 1, /obj/item/key/golfcart = 2, /obj/item/stock_parts/power_store/cell/lead = 1)
	crate_name = "ящик с комплектом запчастей для гольф кара"
	crate_type = /obj/structure/closet/crate/engineering
