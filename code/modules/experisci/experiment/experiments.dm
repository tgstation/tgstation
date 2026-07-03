/datum/experiment/scanning/points/slime
	name = "Эксперимент со слизью"
	required_points = 1

/datum/experiment/scanning/points/slime/hard
	name = "Сложное исследование слизи"
	description = "Другая станция поставила перед вашей командой задачу собрать несколько сложных ядер слизи, \
		справитесь ли вы с этим?"
	required_points = 10
	required_atoms = list(/obj/item/slime_extract/bluespace = 1,
		/obj/item/slime_extract/sepia = 1,
		/obj/item/slime_extract/cerulean = 1,
		/obj/item/slime_extract/pyrite = 1,
		/obj/item/slime_extract/red = 2,
		/obj/item/slime_extract/green = 2,
		/obj/item/slime_extract/pink = 2,
		/obj/item/slime_extract/gold = 2)

/datum/experiment/scanning/points/slime/expert
	name = "Экспертное исследование слизи"
	description = "Межгалактическое общество ксенобиологов в настоящее время ищет образцы самых сложных \
		ядер слаймов, мы поручаем вашей станции обеспечить их всем необходимым."
	required_points = 10
	required_atoms = list(/obj/item/slime_extract/adamantine = 1,
		/obj/item/slime_extract/oil = 1,
		/obj/item/slime_extract/black = 1,
		/obj/item/slime_extract/lightpink = 1,
		/obj/item/slime_extract/rainbow = 10)

/datum/experiment/scanning/random/cytology/easy
	name = "Эксперимент по скану цитологии"
	description = "Ученым нужны паразиты для опытов, используйте цитологическое оборудование, чтобы вырастить этих простых тварей!"
	total_requirement = 3
	max_requirement_per_type = 2
	possible_types = list(/mob/living/basic/cockroach, /mob/living/basic/mouse, /mob/living/basic/snail)

/datum/experiment/scanning/random/cytology/medium
	name = "Усоверш. эксперимент по изучению цитологии"
	description = "Нам нужно увидеть, как функционирует организм с самых ранних моментов. Несколько цитологических экспериментов помогут нам понять это."
	total_requirement = 3
	max_requirement_per_type = 2
	possible_types = list(
		/mob/living/basic/pet/cat,
		/mob/living/basic/carp,
		/mob/living/basic/chicken,
		/mob/living/basic/cow,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/snake,
	)

/datum/experiment/scanning/random/cytology/medium/one
	name = "Продв. цитологическое изучение (1)"

/datum/experiment/scanning/random/cytology/medium/two
	name = "Продв. цитологическое изучение (2)"

/datum/experiment/scanning/random/janitor_trash
	name = "Гигиеническая проверка станции"
	description = "Чтобы научиться чистить, мы должны сначала узнать, что такое грязь. Нам нужно, чтобы вы просканировали несколько загрязнений на станции."
	possible_types = list(/obj/effect/decal/cleanable/vomit,
	/obj/effect/decal/cleanable/blood)
	total_requirement = 3

/datum/experiment/ordnance/explosive/lowyieldbomb
	name = "Маломощная взрывчатка"
	description = "Маломощные взрывчатые вещества могут оказаться полезными для наших групп по защите активов. Зафиксируйте небольшой взрыв с помощью доплеровской матрицы и опубликуйте данные в отчёте."
	gain = list(10,15,20)
	target_amount = list(5,10,20)
	experiment_proper = TRUE
	sanitized_misc = FALSE
	sanitized_reactions = FALSE
	allow_any_source = TRUE

/datum/experiment/ordnance/explosive/highyieldbomb
	name = "Высокомощная взрывчатка"
	description =  "Некоторые реакции протекают очень энергично и могут быть использованы для создания более мощных взрывчатых веществ. Зафиксируйте взрыв любой канистры с помощью доплеровской матрицы и опубликуйте данные в отчёте. Допускается любая газовая реакция."
	gain = list(10,50,100)
	target_amount = list(50,100,300)
	experiment_proper = TRUE
	sanitized_misc = FALSE
	sanitized_reactions = FALSE

/datum/experiment/ordnance/explosive/hydrogenbomb
	name = "Водородная взрывчатка"
	description = "Горение водорода и его производных может быть очень мощным. Зафиксируйте любой взрыв канистры с помощью доплеровской матрицы и опубликуйте данные в отчёте. Разрешены только водородные или тритиевые взрывы."
	gain = list(15,40,60)
	target_amount = list(50,75,150)
	experiment_proper = TRUE
	sanitized_misc = TRUE
	sanitized_reactions = TRUE
	require_all = FALSE
	required_reactions = list(/datum/gas_reaction/h2fire, /datum/gas_reaction/tritfire)

/datum/experiment/ordnance/explosive/nobliumbomb
	name = "Ноблиевая взрывчатка"
	description = "Гиперноблиум образуется очень энергично, и его можно использовать для изготовления взрывчатых веществ. Зафиксируйте взрыв любой канистры с помощью доплеровской матрицы и опубликуйте данные в отчёте. Разрешена только конденсация гиперноблия."
	gain = list(15,60,120)
	target_amount = list(50,100,300)
	experiment_proper = TRUE
	sanitized_misc = TRUE
	sanitized_reactions = TRUE
	required_reactions = list(/datum/gas_reaction/nobliumformation)

/datum/experiment/ordnance/explosive/pressurebomb
	name = "Безреакционная взрывчатка"
	description = "Газы с высокой удельной теплоемкостью могут нагревать газы с низкой и создавать большое давление. Зафиксируйте взрыв любой канистры с помощью доплеровской матрицы и опубликуйте данные в отчёте. Никаких газовых реакций не допускается."
	gain = list(10,50,100)
	target_amount = list(20,50,100)
	experiment_proper = TRUE
	sanitized_misc = FALSE
	sanitized_reactions = TRUE

/datum/experiment/ordnance/gaseous/nitrous_oxide
	name = "Газовые баллоны с закисью азота"
	description = "Доставка N2O в район проведения операции может оказаться полезной. Упакуйте указанный газ в канистру и взорвите его с помощью компрессора для канистр. Опубликуйте данные в отчёте."
	gain = list(10,40)
	target_amount = list(200,600)
	experiment_proper = TRUE
	required_gas = /datum/gas/nitrous_oxide

/datum/experiment/ordnance/gaseous/plasma
	name = "Плазменные снаряды"
	description = "Доставка плазмы в район проведения операции может оказаться полезной. Упакуйте указанный газ в канистру и взорвите его с помощью компрессора для канистр. Опубликуйте данные в отчёте."
	gain = list(10,40)
	target_amount = list(200,600)
	experiment_proper = TRUE
	required_gas = /datum/gas/plasma

/datum/experiment/ordnance/gaseous/bz
	name = "BZ-снаряды"
	description = "Доставка газа BZ в район проведения операции может оказаться полезной. Упакуйте указанный газ в канистру и взорвите его с помощью компрессора для канистр. Опубликуйте данные в отчёте."
	gain = list(10,30,60)
	target_amount = list(50,125,400)
	experiment_proper = TRUE
	required_gas = /datum/gas/bz

/datum/experiment/ordnance/gaseous/noblium
	name = "Гиперноблиевые снаряды"
	description = "Доставка гиперноблиума в район проведения операции может оказаться полезной. Упакуйте указанный газ в канистру и взорвите его с помощью компрессора для канистр. Опубликуйте данные в отчёте."
	gain = list(10,40,80)
	target_amount = list(15,55,250)
	experiment_proper = TRUE
	required_gas = /datum/gas/hypernoblium

/datum/experiment/scanning/random/material/meat
	name = "Эксперимент по скану биологических материалов"
	description = "Нам говорили, что нельзя сделать стулья из любого материала в мире. Вы здесь, чтобы доказать, что эти скептики ошибались."
	possible_material_types = list(/datum/material/meat)

/datum/experiment/scanning/random/material/easy
	name = "Эксперимент по скану низкосортных материалов"
	description = "Материаловедение - это базовое понимание Вселенной и того, как она устроена. Чтобы объяснить это, постройте что-нибудь элементарное, и мы покажем вам, как это сломать."
	total_requirement = 6
	possible_types = list(/obj/structure/chair, /obj/structure/toilet, /obj/structure/table)
	possible_material_types = list(/datum/material/iron, /datum/material/glass)

/datum/experiment/scanning/random/material/medium
	name = "Эксперимент по скану материалов среднего класса"
	description = "Не все материалы достаточно прочны, чтобы удержать космическую станцию. Посмотрите, например, на эти материалы и определите, что делает их полезными для нашей электроники и оборудования."
	possible_material_types = list(/datum/material/silver, /datum/material/gold, /datum/material/plastic, /datum/material/titanium)

/datum/experiment/scanning/random/material/medium/one
	name = "Эксперимент по скану материалов среднего класса (1)"

/datum/experiment/scanning/random/material/medium/two
	name = "Эксперимент по скану материалов среднего класса (2)"

/datum/experiment/scanning/random/material/medium/three
	name = "Эксперимент по скану материалов среднего класса (3)"

/datum/experiment/scanning/random/material/hard
	name = "Эксперимент по скану материалов высокого класса"
	description = "НТ не жалеет средств, чтобы проверить даже самые ценные материалы на их строительные качества. Постройте нам несколько таких экзотических творений и соберите данные."
	possible_material_types = list(/datum/material/diamond, /datum/material/plasma, /datum/material/uranium)

/datum/experiment/scanning/random/material/hard/one
	name = "Эксперимент по скану высококлассных материалов (1)"

/datum/experiment/scanning/random/material/hard/two
	name = "Эксперимент по скану высококлассных материалов (2)"

/datum/experiment/scanning/random/material/hard/three
	name = "Эксперимент по скану высококлассных материалов (3)"

/datum/experiment/scanning/random/plants/wild
	name = "Образец мутации дикой биоматерии"
	description = "По ряду причин (солнечные лучи, диета, состоящая только из мутагена, энтропия) растения с низким уровнем нестабильности могут иногда мутировать при сборе урожая. Просканируйте для нас один из этих образцов."
	performance_hint = "\"Дикие\" мутации происходят при более 30 пунктах нестабильности, а видовые мутации - более 60 пунктов."
	total_requirement = 1

/datum/experiment/scanning/random/plants/traits
	name = "Уникальный образец мутации биоматерии"
	description = "Мы на ЦК ищем редкие и экзотические растения с уникальными свойствами, чтобы похвастаться перед акционерами. Сейчас мы ищем образец с очень специфическими генами."
	performance_hint = "Все растения, представленные на станции, обладают различными признаками, некоторые из них уникальны. Ищите растения, которые могут мутировать в то, что мы ищем."
	total_requirement = 3
	possible_plant_genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/cell_charge, /datum/plant_gene/trait/glow/shadow, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/brewing, /datum/plant_gene/trait/juicing, /datum/plant_gene/trait/eyes, /datum/plant_gene/trait/sticky)

/datum/experiment/scanning/points/machinery_tiered_scan/tier2_lathes
	name = "Эталон улучшенных деталей"
	description = "Наши недавно разработанные улучшенные детали машин требуют испытаний для получения подсказок о возможных будущих улучшениях, а также подтверждения того, что мы не разработали мусор."
	required_points = 6
	required_atoms = list(
		/obj/machinery/rnd/production/protolathe/department/science = 1,
		/obj/machinery/rnd/production/protolathe/department/engineering = 1,
		/obj/machinery/rnd/production/techfab/department/cargo = 1,
		/obj/machinery/rnd/production/techfab/department/medical = 1,
		/obj/machinery/rnd/production/techfab/department/security = 1,
		/obj/machinery/rnd/production/techfab/department/service = 1
	)
	required_tier = 2

/datum/experiment/scanning/points/machinery_tiered_scan/tier3_bluespacemachines
	name = "Настройка блюспейс машин"
	description = "Технология телепортации благодаря возможностям блюспейса - одно из главных преимуществ нашей компании, но угроза сбоя в процедурах калибровки - это не то, что мы предсказываем. Так как наш НИО начал бунт из-за мухолюдей, возможно, ваши достижения в области деталей спасут нас, пока всё не пошло по жужжде."
	required_points = 4
	required_atoms = list(
		/obj/machinery/teleport/hub = 1,
		/obj/machinery/teleport/station = 1
	)
	required_tier = 3

/datum/experiment/scanning/points/machinery_tiered_scan/tier3_variety
	name = "Испытание высокоэффективных деталей"
	description = "Нам требуется дальнейшее тестирование деталей, чтобы еще больше повысить их эффективность и рыночную цену."
	required_points = 15
	required_atoms = list(
		/obj/machinery/autolathe = 1,
		/obj/machinery/rnd/production/circuit_imprinter/department/science = 1,
		/obj/machinery/monkey_recycler = 1,
		/obj/machinery/processor/slime = 1,
		/obj/machinery/processor = 2,
		/obj/machinery/reagentgrinder = 2,
		/obj/machinery/hydroponics = 2,
		/obj/machinery/biogenerator = 3,
		/obj/machinery/gibber = 3,
		/obj/machinery/chem_master = 3,
		/obj/machinery/cryo_cell = 3,
		/obj/machinery/harvester = 5,
		/obj/machinery/quantumpad = 5
	)
	required_tier = 3

/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay
	name = "Установка мех-отсека военного класса"
	description = "Создание боевых мехов - дорогое удовольствие. Убедитесь, что у вас есть эффективная установка для производства, и мы пришлем несколько наших конструкторских документов."
	required_points = 6
	required_atoms = list(
		/obj/machinery/mecha_part_fabricator = 1,
		/obj/machinery/mech_bay_recharge_port = 1,
		/obj/machinery/recharge_station = 1
	)
	required_tier = 3

/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_microlaser
	name = "Калибровка мощных микролазеров"
	description = "Наша Лазерная Указка Нанотрейзен Высокомощная Офиснопредназначенная™ пока недостаточно мощная, чтобы сбивать с неба синдидронов. Найдите нам применение диодам и подскажите, как их улучшить!"
	required_points = 10
	required_atoms = list(
		/obj/machinery/mecha_part_fabricator = 1,
		/obj/machinery/rnd/experimentor = 1,
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/microwave = 2,
		/obj/machinery/deepfryer = 2,
		/obj/machinery/chem_heater = 3,
		/obj/machinery/power/emitter = 3
	)
	required_stock_part = /obj/item/stock_parts/micro_laser/high

/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_capacitors
	name = "Эталон улучшенных конденсаторов"
	description = "Дальнейшее повышение мощности устройств по всей станции - следующий шаг на пути к важному проекту, обозначенному как ВАЖНЫЙ: инвалидные коляски с мотором, работающие на блюспейс-концентрированной ядерной энергии."
	required_points = 12
	required_atoms = list(
		/obj/machinery/recharge_station = 1,
		/obj/machinery/cell_charger = 1,
		/obj/machinery/mech_bay_recharge_port = 1,
		/obj/machinery/recharger = 2,
		/obj/machinery/power/smes = 2,
		/obj/machinery/chem_dispenser = 3,
		/obj/machinery/chem_dispenser/drinks = 3, /*actually having only the chem dispenser works for scanning soda/booze dispensers but im not quite sure how would i go about actually pointing that out w/o these two lines*/
		/obj/machinery/chem_dispenser/drinks/beer = 3
	)
	required_stock_part = /obj/item/stock_parts/capacitor/adv

/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_scanmodules
	name = "Калибровка улучшенных сканирующих модулей"
	description = "Несмотря на очевидную невостребованность сканирующих модулей на наших станциях, мы все равно ждем от вас тестов на их производительность - на случай, если мы придумаем революционный способ вместить 6 сканирующих модулей в мех."
	required_points = 6
	required_atoms = list(
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/rnd/experimentor = 1,
		/obj/machinery/medical_kiosk = 2,
		/obj/machinery/piratepad/civilian = 2,
	)
	required_stock_part = /obj/item/stock_parts/scanning_module/adv

/datum/experiment/scanning/points/machinery_pinpoint_scan/tier3_cells
	name = "Тест на емкость батарей"
	description = "У Нанотрейзен две основные проблемы с их новым генератором, работающим на хомяках: избыток вырабатываемой энергии и бурные протесты активистов Консорциума по защите прав животных из-за генетической модификации хомяков с геном Халка. Мы берем на себя решение последней проблемы!"
	required_points = 8
	required_atoms = list(
		/obj/machinery/recharge_station = 1,
		/obj/machinery/chem_dispenser = 1,
		/obj/machinery/chem_dispenser/drinks = 1,
		/obj/machinery/chem_dispenser/drinks/beer = 1,
		/obj/machinery/power/smes = 2
	)
	required_stock_part = /obj/item/stock_parts/power_store/cell/hyper

/datum/experiment/scanning/points/machinery_pinpoint_scan/tier3_microlaser
	name = "Калибровка сверхмощных микролазеров"
	description = "Мы очень близки к тому, чтобы превзойти хирургов прошлого и изобрести лазерные инструменты, достаточно точные для проведения операций на винограде. Помогите нам довести диоды до совершенства!"
	required_points = 10
	required_atoms = list(
		/obj/machinery/mecha_part_fabricator = 1,
		/obj/machinery/microwave = 1,
		/obj/machinery/rnd/experimentor = 1,
		/obj/machinery/atmospherics/components/unary/thermomachine/freezer = 2,
		/obj/machinery/power/emitter = 2,
		/obj/machinery/chem_heater = 2,
		/obj/machinery/chem_mass_spec = 3
	)
	required_stock_part = /obj/item/stock_parts/micro_laser/ultra

/datum/experiment/scanning/random/mecha_damage_scan
	name = "Материалы для экзокостюмов: стресс-тест"
	description = "Ваши устройства для изготовления экзокостюмов позволяют быстро производить их в небольших масштабах, но структурная целостность созданных деталей уступает более традиционным средствам."
	exp_tag = "Скан"
	total_requirement = 2
	possible_types = list(/obj/vehicle/sealed/mecha)
	///Damage percent that each mech needs to be at for a scan to work.
	var/damage_percent

/datum/experiment/scanning/random/mecha_equipped_scan
	name = "Материалы для экзокостюмов: испытание на нагрузку"
	description = "Экзокостюмы создают уникальную нагрузку на конструкцию транспортного средства. Сканируйте экзокостюмы, собранные на ваших фабрикаторах экзосьютов и полностью оснащенные, чтобы ускорить моделирование структурных нагрузок."
	possible_types = list(/obj/vehicle/sealed/mecha)
	total_requirement = 1

/// Scan a person with any mutation
/datum/experiment/scanning/people/mutant
	name = "Исследование человеческого тела: генетические мутации"
	description = "Наши новые научные ассистенты пили случайные химикаты для науки, когда один из них овладел телекинезом, а другой начал стрелять лазерами из глаз. Это может быть полезно для наших исследований. Повторите эксперимент, заставив ассистентов выпить нестабильный мутаген, просканируйте их и сообщите о результатах."
	performance_hint = "Просканируйте кого-то со случайной мутацией."
	required_traits_desc = " со случайной мутацией"

/datum/experiment/scanning/people/mutant/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	. = ..()
	if (!.)
		return
	if(!LAZYLEN(check.dna.mutations))
		return FALSE
	return TRUE

/// Scan for organs you didn't start the round with
/datum/experiment/scanning/people/novel_organs
	name = "Исследование человеческого тела: дивергентная биология"
	description = "Нам нужны данные об органической совместимости между видами. Отсканируйте несколько образцов гуманоидных организмов с органами, которых у них обычно нет. \
		Данные о механических органах нам ни к чему."
	performance_hint = "Необычные органы могут быть введены вручную путем пересадки, генетической инфузии или очень быстро с помощью эффекта аномалии Биоскрэмблэр."
	required_traits_desc = " с несинтетическими органами, не характерных для её вида"
	/// Disallow prosthetic organs
	var/organic_only = TRUE

/datum/experiment/scanning/people/novel_organs/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if (!.)
		return
	// Organs which are valid for get_mutant_organ_type_for_slot
	var/static/list/vital_organ_slots = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)

	for (var/obj/item/organ/organ as anything in check.organs)
		if (organic_only && !IS_ORGANIC_ORGAN(organ))
			continue
		var/datum/species/target_species = check.dna.species
		if (organ.slot in vital_organ_slots)
			if (organ.type == target_species.get_mutant_organ_type_for_slot(organ.slot))
				continue
		else
			if ((organ.type in target_species.mutant_organs))
				continue
		return TRUE
	return FALSE

/// Scan for cybernetic organs
/datum/experiment/scanning/people/augmented_organs
	name = "Исследование человеческого тела: аугментированные органы"
	description = "Нам нужно собрать данные о том, как кибернетические жизненно важные органы сочетаются с биологией человека. Проведите сканирование человека с такими имплантами, чтобы понять их совместимость."
	performance_hint = "Проведите хирургическую операцию по манипуляцией органами, чтобы заменить один из жизненно важных органов на кибернетическую альтернативу."
	required_traits_desc = " с аугментированными жизненно важными органами"
	required_count = 1

/datum/experiment/scanning/people/augmented_organs/is_valid_scan_target(mob/living/carbon/human/check)
	. = ..()
	if (!.)
		return
	var/static/list/vital_organ_slots = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)

	for (var/obj/item/organ/organ as anything in check.organs)
		if ((organ.slot in vital_organ_slots) && IS_ROBOTIC_ORGAN(organ))
			return TRUE
	return FALSE

/// Scan for skillchips
/datum/experiment/scanning/people/skillchip
	name = "Исследование человеческого тела: импланты скилл-чипы"
	description = "Прежде чем внедрять программируемые схемы в человеческий мозг, нам нужно узнать, как он справляется с простыми. Просканируйте живую особь с имплантированным скилл-чипом в мозге."
	performance_hint = "Проведите имплантирование скилл-чипа с помощью Skill Station."
	required_traits_desc = " с импантированным скилл-чипом"

/datum/experiment/scanning/people/skillchip/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	. = ..()
	if (!.)
		return
	var/obj/item/organ/brain/scanned_brain = check.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (isnull(scanned_brain))
		experiment_handler.announce_message("Субъект не имеет мозга!")
		return FALSE
	if (scanned_brain.get_used_skillchip_slots() == 0)
		experiment_handler.announce_message("Не найдены скилл-чипы!")
		return FALSE
	return TRUE

/// Scan an android
/datum/experiment/scanning/people/android
	name = "Исследование человеческого тела: полная аугментация"
	description = "Проведите полную кибернетическую аугментацию члена экипажа, а затем просканируйте его, чтобы проверить у них новые возможности и новые сенсорные и когнитивные функции."
	performance_hint = "Проведите хирургические операции, чтобы полностью аугментировать тело."
	required_traits_desc = ", полностью аугментированную в андроида"
	required_count = 1

/datum/experiment/scanning/people/android/is_valid_scan_target(mob/living/carbon/human/check, datum/component/experiment_handler/experiment_handler)
	. = ..()
	if (!.)
		return
	if (isandroid(check))
		return TRUE
	if (length(check.organs) < 6 || length(check.get_missing_limbs()) > 1)
		return FALSE

	var/static/list/augmented_organ_slots = list(
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)
	for (var/obj/item/organ/organ as anything in check.organs)
		if (!(organ.slot in augmented_organ_slots))
			continue
		if (!IS_ROBOTIC_ORGAN(organ))
			return FALSE
	for (var/obj/item/bodypart/bodypart as anything in check.get_bodyparts())
		if (!IS_ROBOTIC_LIMB(bodypart))
			return FALSE
	return TRUE

/datum/experiment/scanning/reagent/cryostylane
	name = "Сканирование чистого Cryostylane"
	description = "Оказывается, реагент Cryostylane способен остановить все физиологические процессы в человеческом организме. Произведите Cryostylane чистотой не менее 99% и просканируйте контейнер с ним."
	performance_hint = "Keep the temperature as high as possible during the reaction."
	required_reagent = /datum/reagent/cryostylane
	min_purity = 0.99

/datum/experiment/scanning/reagent/haloperidol
	name = "Сканирование чистого Haloperidol"
	description = "Нам требуются испытания, связанные с длительным лечением хронических психических расстройств. Произведите Haloperidol с чистотой не менее 98% и просканируйте контейнер с ним."
	performance_hint = "Экзотермичен и потребляет водород во время реакции."
	required_reagent = /datum/reagent/medicine/haloperidol
	min_purity = 0.98

/datum/experiment/scanning/points/bluespace_crystal
	name = "Изучение блюспейс кристаллов"
	description = "Исследуйте свойства блюспейс кристаллов путём сканирования искусственных или естественных вариантов. Это поможет нам глубже понять феномен блюспейса."
	required_points = 1
	required_atoms = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/sheet/bluespace_crystal = 1
	)

/datum/experiment/scanning/points/anomalies
	name = "Анализ нейтрализованных аномалий"
	description = "Теперь у нас есть возможность справиться с аномалиями. Нейтрализуйте их с помощью нейтрализатора аномалий или зарядите необработанные ядра и просканируйте результаты."
	required_points = 4
	required_atoms = list(/obj/item/assembly/signaler/anomaly = 1)

/datum/experiment/scanning/points/machinery_tiered_scan/tier2_any
	name = "Проверка улучшенных деталей"
	description = "Наши новые детали машин нуждаются в практических испытаниях, чтобы получить подсказки о возможных дальнейших усовершенствованиях, а также общее подтверждение того, что мы действительно не разработали детали хуже. Просканируйте любую машину с улучшенными деталями и сообщите о результатах."
	required_points = 6
	required_atoms = list(
		/obj/machinery = 1
	)
	required_tier = 2

/datum/experiment/scanning/points/machinery_tiered_scan/tier3_any
	name = "Проверка продвинутых деталей"
	description = "Наши новые детали машин нуждаются в практических испытаниях, чтобы получить подсказки о возможных дальнейших усовершенствованиях, а также общее подтверждение того, что мы действительно не разработали детали хуже. Просканируйте любую машину с продвинутыми деталями и сообщите о результатах."
	required_points = 6
	required_atoms = list(
		/obj/machinery = 1
	)
	required_tier = 3
