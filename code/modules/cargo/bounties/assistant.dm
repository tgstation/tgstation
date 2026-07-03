/datum/bounty/item/assistant/strange_object
	name = "Странный объект"
	description = "Нанотрейзен интересуется странными объектами. Найдите один в технических туннелях и отправьте сразу же на ЦК."
	reward = CARGO_CRATE_VALUE * 2.4
	wanted_types = list(/obj/item/relic = TRUE)

/datum/bounty/item/assistant/scooter
	name = "Scooter"
	description = "Нанотрейзен установило, что ходьба расточительна. Отправьте скутер на ЦК для ускорения операций."
	reward = CARGO_CRATE_VALUE * 2.16 // the mat hoffman
	wanted_types = list(/obj/vehicle/ridden/scooter = TRUE)
	include_subtypes = FALSE

/datum/bounty/item/assistant/skateboard
	name = "Skateboard"
	description = "Нанотрейзен установило, что ходьба расточительна. Отправьте скейтборд на ЦК для ускорения операций."
	reward = CARGO_CRATE_VALUE * 1.8 // the tony hawk
	wanted_types = list(
		/obj/vehicle/ridden/scooter/skateboard = TRUE,
		/obj/item/melee/skateboard = TRUE,
	)

/datum/bounty/item/assistant/stunprod
	name = "Оглушающий прут"
	description = "ЦК требуется оглушающий прут против диссидентов. Создайте одну, затем отправьте."
	reward = CARGO_CRATE_VALUE * 2.6
	wanted_types = list(/obj/item/melee/baton/security/cattleprod = TRUE)

/datum/bounty/item/assistant/soap
	name = "Мыло"
	description = "Мыло пропало из всех ванных на ЦК, и никто не знает кто его взял. Замените его и станьте героем, что нужен ЦК."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 3
	wanted_types = list(/obj/item/soap = TRUE)

/datum/bounty/item/assistant/spear
	name = "Копья"
	description = "Силы безопасности на ЦК проходят через сокращение бюджета. Вам заплатят, если вы отправите набор копей."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 5
	wanted_types = list(/obj/item/spear = TRUE)

/datum/bounty/item/assistant/toolbox
	name = "Заполненные ящики для инструментов"
	description = "Сотрудники ЦК недостаточно робастны. Поторопитесь и отправьте несколько полных тулбоксов (отвертка, гаечный ключ, сварка, лом, анализатор и кусачки) для решения проблемы."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/item/storage/toolbox = TRUE)
	/// List of tools that we want to see sorted into a toolbox
	var/static/list/static_packing_list = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/analyzer,
		/obj/item/wirecutters,
	)

/datum/bounty/item/assistant/toolbox/applies_to(obj/shipped)
	var/list/packing_list = static_packing_list.Copy()
	for(var/obj/item_contents as anything in shipped.contents)
		for(var/match_type in packing_list)
			if(istype(item_contents, match_type))
				packing_list -= match_type
				break
		if(!length(packing_list))
			return ..()
	return FALSE

/datum/bounty/item/assistant/toolbox/ship(obj/shipped)
	. = ..()
	for(var/obj/object as anything in shipped.contents)
		if(!is_type_in_list(object, static_packing_list))
			object.forceMove(shipped.drop_location())

/datum/bounty/item/assistant/statue
	name = "Статуя"
	description = "Центральное Командование хотело бы вычурную статую для лобби. Отправьте одну, когда это будет возможно."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/structure/statue = TRUE)

/datum/bounty/item/assistant/clown_box
	name = "Коробка клоуна"
	description = "Вселенная нуждается в смехе. Поставьте штамп на картонке при помощи печати клоуна и отправьте."
	reward = CARGO_CRATE_VALUE * 3
	wanted_types = list(/obj/item/storage/box/clown = TRUE)

/datum/bounty/item/assistant/cheesiehonkers
	name = "Сырные хонкеры"
	description = "Видимо, компания, что производит сырные хонкеры скоро разорится. ЦК хочет запастись ими, пока это не случилось!"
	reward = CARGO_CRATE_VALUE * 2.4
	required_count = 3
	wanted_types = list(/obj/item/food/cheesiehonkers = TRUE)

/datum/bounty/item/assistant/baseball_bat
	name = "Бейсбольная бита"
	description = "Бейсбольная лихорадка происходит на ЦК! Будьте добры отправить нам несколько бейсбольных бит, чтобы начальство смогло осуществить их детскую мечту."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 5
	wanted_types = list(/obj/item/melee/baseball_bat = TRUE)

/datum/bounty/item/assistant/extendohand
	name = "Extendo-Hand"
	description = "Коммандор Бетси уже стара и теперь не может дотянуться до пульта телевизора. Командование запросило перчатку на пружине для помощи ей."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/item/extendohand = TRUE)

/datum/bounty/item/assistant/donut
	name = "Пончики"
	description = "Служба безопасности на ЦК терпит сильные потери от синдиката. Отправьте пончики, чтобы поднять мораль."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 6
	wanted_types = list(/obj/item/food/donut = TRUE)

/datum/bounty/item/assistant/donkpocket
	name = "Донк-покеты"
	description = "Памятка безопасности потребителя: Внимание. Донк-покеты, созданные в прошлом году, содержат опасную биоматерию ящеров. Верните вещество на ЦК немедленно."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 10
	wanted_types = list(/obj/item/food/donkpocket = TRUE)

/datum/bounty/item/assistant/monkey_hide
	name = "Шкура обезьяны"
	description = "Один из учёных на ЦК заинтересован в тестировании продуктов на шкуре обезьян. Ваша задача состоит в том, чтобы получить шкуру и отправить её."
	reward = CARGO_CRATE_VALUE * 3
	wanted_types = list(/obj/item/stack/sheet/animalhide/carbon/monkey = TRUE)

/datum/bounty/item/assistant/dead_mice
	name = "Мёртвые мыши"
	description = "На станции 14 закончились сухо-замороженные мыши. Отправьте свежих, иначе их уборщик устроит забастовку."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 5
	wanted_types = list(/obj/item/food/deadmouse = TRUE)

/datum/bounty/item/assistant/comfy_chair
	name = "Удобные стулья"
	description = "Коммандор Пат недоволен своим стулом. Он утверждает, что стул приносит боль его спине. Отправьте несколько альтернатив для его спины."
	reward = CARGO_CRATE_VALUE * 3
	required_count = 5
	wanted_types = list(/obj/structure/chair/comfy = TRUE)

/datum/bounty/item/assistant/geranium
	name = "Герании"
	description = "Коммандор Зот страстно влюблён в Коммандора Зену. Отправьте поставкой герании - её любимые цветы, и он с радостью вас вознаградит."
	reward = CARGO_CRATE_VALUE * 8
	required_count = 3
	wanted_types = list(/obj/item/food/grown/poppy/geranium = TRUE)
	include_subtypes = FALSE

/datum/bounty/item/assistant/poppy
	name = "Маки"
	description = "Коммандор Зот очень хочет свести с ума офицера безопасности Оливию. Отправьте поставку маков - её любимых цветов, и он вас с радостью вознаградит."
	reward = CARGO_CRATE_VALUE * 2
	required_count = 3
	wanted_types = list(/obj/item/food/grown/poppy = TRUE)
	include_subtypes = FALSE

/datum/bounty/item/assistant/potted_plants
	name = "Комнатные растения"
	description = "Центральное Командование хочет укомплектовать новую станцию класса BirdBoat. Вам был дан заказ на снабжение станции комнатными растениями."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 3
	wanted_types = list(
		/obj/item/kirbyplants = TRUE,
		/obj/item/kirbyplants/synthetic = FALSE
		)

/datum/bounty/item/assistant/monkey_cubes
	name = "Кубы обезьян"
	description = "В связи с недавним инцидентом в генетике, Центральное Командование остро нуждается в обезьянах. Ваша задача отправить кубы обезьян."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 3
	wanted_types = list(/obj/item/food/monkeycube = TRUE)

/datum/bounty/item/assistant/ied
	name = "СВУ"
	description = "В тюрьме строго режима Нанотрейзен, находящейся на ЦК, проходит обучение персонала. Отправьте несколько СВУ для обучения."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 3
	wanted_types = list(/obj/item/grenade/iedcasing = TRUE)

/datum/bounty/item/assistant/corgimeat
	name = "Сырое мясо корги"
	description = "Синдикат недавно украл всё мясо корги с ЦК. Отправьте замену немедленно."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/item/food/meat/slab/corgi = TRUE)

/datum/bounty/item/assistant/toys
	name = "Игрушки"
	description = "Сын вице-президента, увидев рекламу новых игрушек по телевизору, стал выпрашивать их. Отправьте несколько игрушек из аркадного автомата чтобы угомонить его."
	reward = CARGO_CRATE_VALUE * 8
	required_count = 5
	wanted_types = list(/obj/item/toy = TRUE)

/datum/bounty/item/assistant/paper_bin
	name = "Корзины для бумаг"
	description = "У нашего бухгалтерского отдела кончилась бумага. Нам нужна поставка бумаги немедленно."
	reward = CARGO_CRATE_VALUE * 5
	required_count = 5
	wanted_types = list(/obj/item/paper_bin = TRUE)

/datum/bounty/item/assistant/crayons
	name = "Мелки"
	description = "Дети доктора Джонса снова съели все наши мелки. Пожалуйста, отправьте нам свои."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 8
	wanted_types = list(/obj/item/toy/crayon = TRUE)

/datum/bounty/item/assistant/water_tank
	name = "Бак с водой"
	description = "Нам нужно больше воды для нашей гидропоники. Найдите бак с водой и отправьте его нам."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/structure/reagent_dispensers/watertank = TRUE)

/datum/bounty/item/assistant/pneumatic_cannon
	name = "Пневматическая пушка"
	description = "Мы выясняем, как сильно мы можем запускать осколки суперматерии из пневматической пушки. Отправьте нам одну как можно скорее."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/item/pneumatic_cannon/ghetto = TRUE)

/datum/bounty/item/assistant/improvised_shells
	name = "Самодельные патроны для дробовика"
	description = "Сокращение бюджета бьёт очень сильно по службе безопасности. Отправьте несколько самодельных патрон для дробовика как сможете."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 5
	wanted_types = list(/obj/item/ammo_casing/junk = TRUE)

/datum/bounty/item/assistant/flamethrower
	name = "Огнемёт"
	description = "У нас происходит нашествие молей, отправьте нам огнемёт для помощи в урегулировании ситуации."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/item/flamethrower = TRUE)

/datum/bounty/item/assistant/fish
	name = "Рыба"
	description = "Нам нужна рыба для заполнения наших аквариумов. Мёртвые или купленные из отдела поставок рыбы будут оплачены лишь наполовину."
	reward = CARGO_CRATE_VALUE * 9.5
	required_count = 4
	wanted_types = list(/obj/item/fish = TRUE, /obj/item/storage/fish_case = TRUE)
	///the penalty for shipping dead/bought fish, which can subtract up to half the reward in total.
	var/shipping_penalty

/datum/bounty/item/assistant/fish/New()
	..()
	shipping_penalty = reward * 0.5 / required_count

/datum/bounty/item/assistant/fish/applies_to(obj/shipped)
	. = ..()
	if(!.)
		return
	var/obj/item/fish/fishie = shipped
	if(istype(shipped, /obj/item/storage/fish_case))
		fishie = locate() in shipped
		if(!fishie || !is_type_in_typecache(fishie, wanted_types))
			return FALSE
	return can_ship_fish(fishie)

/datum/bounty/item/assistant/fish/proc/can_ship_fish(obj/item/fish/fishie)
	return TRUE

/datum/bounty/item/assistant/fish/ship(obj/shipped)
	. = ..()
	if(!.)
		return
	var/obj/item/fish/fishie = shipped
	if(istype(shipped, /obj/item/storage/fish_case))
		fishie = locate() in shipped
	if(fishie.status == FISH_DEAD || HAS_TRAIT(fishie, TRAIT_FISH_LOW_PRICE))
		reward -= shipping_penalty

///A subtype of the fish bounty that requires fish with a specific fluid type
/datum/bounty/item/assistant/fish/fluid
	reward = CARGO_CRATE_VALUE * 12
	///The required fluid type of the fish for it to be shipped
	var/fluid_type

/datum/bounty/item/assistant/fish/fluid/New()
	..()
	fluid_type = pick(AQUARIUM_FLUID_FRESHWATER, AQUARIUM_FLUID_SALTWATER, AQUARIUM_FLUID_SULPHWATEVER)
	name = "Рыба из [fluid_type]"
	description = "Нам нужна рыба из [LOWER_TEXT(fluid_type)] для заселения наших аквариумов. Мёртвые или купленные в отделе снабжения рыбы будут оплачены лишь наполовину."

/datum/bounty/item/assistant/fish/fluid/can_ship_fish(obj/item/fish/fishie)
	return (fluid_type in GLOB.fish_compatible_fluid_types[fishie.required_fluid_type])
