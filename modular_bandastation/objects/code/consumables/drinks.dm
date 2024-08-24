/obj/machinery/chem_dispenser/drinks/beer/Initialize(mapload)
	. = ..()
	dispensable_reagents |= /datum/reagent/consumable/ethanol/sambuka
	dispensable_reagents |= /datum/reagent/consumable/ethanol/jagermeister
	dispensable_reagents |= /datum/reagent/consumable/ethanol/bluecuracao

/obj/item/reagent_containers/borghypo/borgshaker/Initialize(mapload)
	default_reagent_types |= /datum/reagent/consumable/ethanol/sambuka
	default_reagent_types |= /datum/reagent/consumable/ethanol/jagermeister
	default_reagent_types |= /datum/reagent/consumable/ethanol/bluecuracao
	. = ..()

/datum/reagent/consumable/kvass
	name = "Квас"
	description = "Напиток, приготовленный путем брожения хлеба, ржи или ячменя, который обладает освежающим и слегка кисловатым вкусом."
	color = "#351300"
	nutriment_factor = 1
	taste_description = "приятная терпкость с оттенком сладости и хлебоподобным послевкусием."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_FANTASTIC

/datum/glass_style/drinking_glass/kvass
	required_drink_type = /datum/reagent/consumable/kvass
	name = "стакан кваса"
	desc = "В стакане кристально чистая жидкость насыщенного темно-коричневого цвета, которая кажется почти янтарной при определенном угле освещения."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "kvass"

/datum/export/large/reagent_dispenser/kvass
	unit_name = "kvasstank"
	export_types = list(/obj/structure/reagent_dispensers/kvasstank)

/obj/structure/reagent_dispensers/kvasstank
	name = "бочка кваса"
	desc = "Ярко-желтая бочка с квасом, которая сразу привлекает внимание своим насыщенным цветом. Она выполнена в классическом стиле, из толстого, прочного металла с гладкой, блестящей поверхностью. Бочка имеет цилиндрическую форму, слегка расширяясь к середине и снова сужаясь к краям."
	icon = 'modular_bandastation/objects/icons/chemical_tanks.dmi'
	icon_state = "kvass"
	reagent_id = /datum/reagent/consumable/kvass
	openable = TRUE

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuka"
	description = "Flying into space, many thought that they had grasped fate."
	color = "#e0e0e0"
	boozepwr = 45
	taste_description = "вихревой огонь"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/sambuka
	required_drink_type = /datum/reagent/consumable/ethanol/sambuka
	name = "Glass of Sambuka"
	desc = "Flying into space, many thought that they had grasped fate."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "sambuka"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	description = "Remember that big brother sees everything."
	color = "#746463"
	boozepwr = 50
	taste_description = "потеря кокетливости"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_NICE

/datum/glass_style/drinking_glass/innocent_erp
	required_drink_type = /datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	desc = "Remember that big brother sees everything."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "innocent_erp"

/datum/chemical_reaction/drink/innocent_erp
	results = list(/datum/reagent/consumable/ethanol/innocent_erp = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/sambuka = 3,
		/datum/reagent/consumable/triple_citrus = 1,
		/datum/reagent/consumable/ethanol/irish_cream = 1,
	)

/datum/reagent/consumable/ethanol/soundhand
	name = "Soundhand"
	description = "Коктейль из нескольких алкогольных напитков с запахом ягод и легким слоем перца на стакане."
	color = "#C18A7B"
	boozepwr = 50
	taste_description = "дребезжащие в ритме металлические струны."
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/soundhand/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(10, seconds_per_tick))
		drinker.emote("airguitar")

/datum/glass_style/drinking_glass/soundhand
	required_drink_type = /datum/reagent/consumable/ethanol/soundhand
	name = "Саундхэнд"
	desc = "Коктейль из нескольких алкогольных напитков с запахом ягод и легким слоем перца на стакане."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "soundhand"

/datum/chemical_reaction/drink/soundhand
	results = list(/datum/reagent/consumable/ethanol/soundhand = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/vodka = 2,
		/datum/reagent/consumable/ethanol/whiskey = 1,
		/datum/reagent/consumable/berryjuice = 1,
		/datum/reagent/consumable/blackpepper = 1,
	)

/datum/reagent/consumable/ethanol/jagermeister
	name = "Jagermeister"
	description = "Пьяный охотник прилетел из глубокого космоса и, похоже, нашел жертву."
	color = "#200b0b"
	boozepwr = 40
	taste_description = "радость охоты"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/jagermeister
	required_drink_type = /datum/reagent/consumable/ethanol/jagermeister
	name = "Стакан Егермейстра"
	desc = "Пьяный охотник прилетел из глубокого космоса и, похоже, нашел жертву."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "jagermeister"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	description = "Предохранитель готов, синева уже загорелась."
	color = "#16c9ff"
	boozepwr = 35
	taste_description = "взрывная синева"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/bluecuracao
	required_drink_type = /datum/reagent/consumable/ethanol/bluecuracao
	name = "Стакан Блю Кюрасао"
	desc = "Предохранитель готов, синева уже загорелась."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "bluecuracao"

/datum/reagent/consumable/ethanol/black_blood
	name = "Black Blood"
	description = "Нужно пить быстрее, пока оно не начало сворачиваться."
	color = "#252521"
	boozepwr = 45
	taste_description = "кровавая тьма"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_NICE

/datum/reagent/consumable/ethanol/black_blood/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(25, seconds_per_tick))
		drinker.say(pick("Fuu ma'jin!", "Sas'so c'arta forbici!", "Ta'gh fara'qha fel d'amar det!", "Kla'atu barada nikt'o!", "Fel'th Dol Ab'orod!", "In'totum Lig'abis!", "Ethra p'ni dedol!", "Ditans Gut'ura Inpulsa!", "O bidai nabora se'sma!"))

/datum/glass_style/drinking_glass/black_blood
	required_drink_type = /datum/reagent/consumable/ethanol/black_blood
	name = "Черная Кровь"
	desc = "Нужно пить быстрее, пока оно не начало сворачиваться."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "black_blood"

/datum/chemical_reaction/drink/black_blood
	results = list(/datum/reagent/consumable/ethanol/black_blood = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/bluecuracao = 2,
		/datum/reagent/consumable/ethanol/jagermeister = 1,
		/datum/reagent/consumable/sodawater = 1,
		/datum/reagent/consumable/ice = 1,
	)

/datum/reagent/consumable/ethanol/pegu_club
	name = "Pegu Club"
	description = "Это похоже на то, как группа джентльменов колонизирует ваш язык."
	color = "#a5702b"
	boozepwr = 50
	taste_description = "грузовой канал"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/pegu_club
	required_drink_type = /datum/reagent/consumable/ethanol/pegu_club
	name = "Клуб Пегу"
	desc = "Это похоже на то, как группа джентльменов колонизирует ваш язык."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "pegu_club"

/datum/chemical_reaction/drink/pegu_club
	results = list(/datum/reagent/consumable/ethanol/pegu_club = 6)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/gin = 2,
		/datum/reagent/consumable/orangejuice = 1,
		/datum/reagent/consumable/limejuice = 1,
		/datum/reagent/consumable/ethanol/bitters = 2,
	)

/datum/reagent/consumable/ethanol/amnesia
	name = "Star Amnesia"
	description = "Это просто бутылка медицинского спирта?"
	color = "#6b0059"
	boozepwr = 75
	taste_description = "диско амнезия"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/amnesia
	required_drink_type = /datum/reagent/consumable/ethanol/amnesia
	name = "Звездная амнезия"
	desc = "Это просто бутылка медицинского спирта?"
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "amnesia"

/datum/chemical_reaction/drink/amnesia
	results = list(/datum/reagent/consumable/ethanol/amnesia = 2)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/hooch = 1,
		/datum/reagent/consumable/ethanol/vodka = 1,
	)

/datum/reagent/consumable/ethanol/silverhand
	name = "Silverhand"
	description = "Wake the heck up, samurai. We have a station to burn."
	color = "#c41414"
	boozepwr = 60
	taste_description = "увядание суперзвезды"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/silverhand
	required_drink_type = /datum/reagent/consumable/ethanol/silverhand
	name = "Silverhand"
	desc = "Wake the heck up, samurai. We have a station to burn."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "silverhand"

/datum/chemical_reaction/drink/silverhand
	results = list(/datum/reagent/consumable/ethanol/silverhand = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/tequila = 2,
		/datum/reagent/consumable/ethanol/bitters = 1,
		/datum/reagent/consumable/ethanol/beer = 1,
		/datum/reagent/consumable/berryjuice = 1,
	)

/datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashion"
	description = "Ходят слухи, что этот коктейль самый старый, но, однако, это совсем другая история."
	color = "#6b4017"
	boozepwr = 60
	taste_description = "старые времена"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_VERYGOOD

/datum/glass_style/drinking_glass/oldfashion
	required_drink_type = /datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashion"
	desc = "Ходят слухи, что этот коктейль самый старый, но, однако, это совсем другая история."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "oldfashion"

/datum/chemical_reaction/drink/oldfashion
	results = list(/datum/reagent/consumable/ethanol/oldfashion = 10)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/whiskey = 5,
		/datum/reagent/consumable/ethanol/bitters = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/orangejuice = 1,
	)

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	description = "Сахарная корочка может оказаться совсем не сладкой."
	color = "#754609"
	boozepwr = 40
	taste_description = "солено-сладкий"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/brandy_crusta
	required_drink_type = /datum/reagent/consumable/ethanol/brandy_crusta
	name = "Брэнди Круста"
	desc = "Сахарная корочка может оказаться совсем не сладкой."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "brandy_crusta"

/datum/chemical_reaction/drink/brandy_crusta
	results = list(/datum/reagent/consumable/ethanol/brandy_crusta = 4)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/whiskey = 2,
		/datum/reagent/consumable/berryjuice = 1,
		/datum/reagent/consumable/lemonjuice = 1,
		/datum/reagent/consumable/ethanol/bitters = 1,
	)

/datum/reagent/consumable/ethanol/telegol
	name = "Telegol"
	description = "Многие до сих пор ломают голову над вопросом об этом коктейле. В любом случае, оно все еще существует... Или нет."
	color = "#4218a3"
	boozepwr = 50
	taste_description = "четвертое измерение"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_VERYGOOD

/datum/glass_style/drinking_glass/telegol
	required_drink_type = /datum/reagent/consumable/ethanol/telegol
	name = "Телеголь"
	desc = "Многие до сих пор ломают голову над вопросом об этом коктейле. В любом случае, оно все еще существует... Или нет."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "telegol"

/datum/chemical_reaction/drink/telegol
	results = list(/datum/reagent/consumable/ethanol/telegol = 6)
	required_reagents = list(
		/datum/reagent/teslium = 2,
		/datum/reagent/consumable/ethanol/vodka = 2,
		/datum/reagent/consumable/dr_gibb = 1,
	)

/datum/reagent/consumable/ethanol/horse_neck
	name = "Horse Neck"
	description = "Будьте осторожны с вашими подковами."
	color = "#c45d09"
	boozepwr = 50
	taste_description = "лошадиная сила"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/horse_neck/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(prob(50))
		affected_mob.say(pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!"))

/datum/glass_style/drinking_glass/horse_neck
	required_drink_type = /datum/reagent/consumable/ethanol/horse_neck
	name = "Лошадиная Шея"
	desc = "Будьте осторожны с вашими подковами."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "horse_neck"

/datum/chemical_reaction/drink/horse_neck
	results = list(/datum/reagent/consumable/ethanol/horse_neck = 6)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/whiskey = 2,
		/datum/reagent/consumable/ethanol/ale = 3,
		/datum/reagent/consumable/ethanol/bitters = 1,
	)

/datum/reagent/consumable/ethanol/vampiro
	name = "Vampiro"
	description = "Ничего общего с вампирами не имеет, кроме цвета."
	color = "#8d0000"
	boozepwr = 45
	taste_description = "истощение"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/vampiro/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(volume > 20 && SPT_PROB(50, seconds_per_tick))
		drinker.visible_message(span_warning("Глаза [drinker] ослепительно вспыхивают!"))

/datum/glass_style/drinking_glass/vampiro
	required_drink_type = /datum/reagent/consumable/ethanol/vampiro
	name = "Вампиро"
	desc = "Ничего общего с вампирами не имеет, кроме цвета."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "vampiro"

/datum/chemical_reaction/drink/vampiro
	results = list(/datum/reagent/consumable/ethanol/vampiro = 4)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/tequila = 2,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/consumable/berryjuice = 1,
	)

/datum/reagent/consumable/ethanol/inabox
	name = "Box"
	description = "Это... Просто коробка?"
	color = "#5a3e0b"
	boozepwr = 40
	taste_description = "стелс"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_NICE

/datum/glass_style/drinking_glass/inabox
	required_drink_type = /datum/reagent/consumable/ethanol/inabox
	name = "Коробка"
	desc = "Это... Просто коробка?"
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "inabox"

/datum/chemical_reaction/drink/inabox
	results = list(/datum/reagent/consumable/ethanol/inabox = 3)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/gin = 2,
		/datum/reagent/consumable/potato_juice = 1,
	)

/datum/reagent/consumable/ethanol/green_fairy
	name = "Green Fairy"
	description = "Какой-то ненормальный зеленый цвет."
	color = "#54dd1e"
	boozepwr = 60
	taste_description = "вера в фей"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/reagent/consumable/ethanol/green_fairy/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	drinker.set_drugginess(20 SECONDS * REM * seconds_per_tick)

/datum/glass_style/drinking_glass/green_fairy
	required_drink_type = /datum/reagent/consumable/ethanol/green_fairy
	name = "Зеленая Фея"
	desc = "Какой-то ненормальный зеленый цвет."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "green_fairy"

/datum/chemical_reaction/drink/green_fairy
	results = list(/datum/reagent/consumable/ethanol/green_fairy = 5)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/tequila = 1,
		/datum/reagent/consumable/ethanol/absinthe = 1,
		/datum/reagent/consumable/ethanol/vodka = 1,
		/datum/reagent/consumable/ethanol/bluecuracao = 1,
		/datum/reagent/consumable/lemonjuice = 1,
	)

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Trans-Siberian Express"
	description = "От Владивостока до белой горячки за один день."
	color = "#e2a600"
	boozepwr = 50
	taste_description = "ужасная инфраструктура"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_GOOD

/datum/glass_style/drinking_glass/trans_siberian_express
	required_drink_type = /datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Транс-Сибирский Экспресс"
	desc = "От Владивостока до белой горячки за один день."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "trans_siberian_express"

/datum/chemical_reaction/drink/trans_siberian_express
	results = list(/datum/reagent/consumable/ethanol/trans_siberian_express = 8)
	required_reagents = list(
		/datum/reagent/consumable/ethanol/vodka = 3,
		/datum/reagent/consumable/limejuice = 2,
		/datum/reagent/consumable/carrotjuice = 2,
		/datum/reagent/consumable/ice = 1,
	)

/datum/reagent/consumable/ethanol/rainbow_sky
	name = "Rainbow Sky"
	description = "Напиток, переливающийся всеми цветами радуги с нотками галактики."
	color = "#ffffff"
	boozepwr = 80
	taste_description = "радуга"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_FANTASTIC

/datum/reagent/consumable/ethanol/rainbow_sky/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = drinker.adjustBruteLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update |= drinker.adjustFireLoss(-1 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	drinker.set_drugginess(30 SECONDS * REM * seconds_per_tick)
	drinker.adjust_hallucinations(10 SECONDS * REM * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/glass_style/drinking_glass/rainbow_sky
	required_drink_type = /datum/reagent/consumable/ethanol/rainbow_sky
	name = "Радужное Небо"
	desc = "Напиток, переливающийся всеми цветами радуги с нотками галактики."
	icon = 'modular_bandastation/objects/icons/drinks.dmi'
	icon_state = "rainbow_sky"

/datum/chemical_reaction/drink/rainbow_sky
	results = list(/datum/reagent/consumable/ethanol/rainbow_sky = 5)
	required_reagents = list(
		/datum/reagent/consumable/doctor_delight = 1,
		/datum/reagent/consumable/ethanol/bananahonk = 1,
		/datum/reagent/consumable/ethanol/erikasurprise = 1,
		/datum/reagent/consumable/ethanol/screwdrivercocktail = 1,
		/datum/reagent/consumable/ethanol/gargle_blaster = 1,
	)
