/datum/species/tajaran
	name = "\improper Таяран"
	plural_form = "Таяры"
	id = SPECIES_TAJARAN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_CATLIKE_GRACE,
		TRAIT_HATED_BY_DOGS,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/tajaran
	digitigrade_customization = DIGITIGRADE_FORCED

	mutantbrain = /obj/item/organ/brain/tajaran
	mutantheart = /obj/item/organ/heart/tajaran
	mutantlungs = /obj/item/organ/lungs/tajaran
	mutanteyes = /obj/item/organ/eyes/tajaran
	mutantears = /obj/item/organ/ears/tajaran
	mutanttongue = /obj/item/organ/tongue/tajaran
	mutantliver = /obj/item/organ/liver/tajaran
	mutantstomach = /obj/item/organ/stomach/tajaran
	mutant_organs = list(
		/obj/item/organ/tail/tajaran = /datum/sprite_accessory/tails/tajaran/wingertail::name,
	)

	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/tajaran_head = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/tajaran_chest = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/tajaran_limb = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/tajaran_facial_hair = SPRITE_ACCESSORY_NONE,
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/tajaran,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/tajaran,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/tajaran,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/tajaran,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/tajaran,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/tajaran,
	)

	coldmod = 0.7
	heatmod = 1.3
	payday_modifier = 0.9
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT + 15
	bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT - 30

/datum/species/tajaran/prepare_human_for_preview(mob/living/carbon/human/human)
	human.set_hairstyle(SPRITE_ACCESSORY_NONE, update = TRUE)
	human.dna.features[FEATURE_TAJARAN_FACIAL_HAIR] = SPRITE_ACCESSORY_NONE
	human.dna.features[FEATURE_MUTANT_COLOR] = "#e5b380"
	human.dna.features[FEATURE_TAJARAN_TAIL_MARKINGS] = "Muzzle and Inner ears"
	human.update_body(is_creating = TRUE)

/datum/species/tajaran/randomize_features()
	var/list/features = ..()
	features[FEATURE_TAJARAN_CHEST_MARKINGS] = prob(50) ? pick(SSaccessories.feature_list[FEATURE_TAJARAN_CHEST_MARKINGS]) : SPRITE_ACCESSORY_NONE
	features[FEATURE_TAJARAN_HEAD_MARKINGS] = prob(50) ? pick(SSaccessories.feature_list[FEATURE_TAJARAN_HEAD_MARKINGS]) : SPRITE_ACCESSORY_NONE
	features[FEATURE_TAJARAN_TAIL_MARKINGS] = prob(50) ? pick(SSaccessories.feature_list[FEATURE_TAJARAN_TAIL_MARKINGS]) : SPRITE_ACCESSORY_NONE
	features[FEATURE_TAJARAN_FACIAL_HAIR] = prob(50) ? pick(SSaccessories.feature_list[FEATURE_TAJARAN_FACIAL_HAIR]) : SPRITE_ACCESSORY_NONE

	var/furcolor = "#[random_color()]"
	features[FEATURE_TAJARAN_BODY_MARKINGS_COLOR] = furcolor
	features[FEATURE_TAJARAN_HEAD_MARKINGS_COLOR] = furcolor
	features[FEATURE_TAJARAN_TAIL_MARKINGS_COLOR] = furcolor
	features[FEATURE_TAJARAN_FACIAL_HAIR_COLOR] = furcolor
	return features

/datum/species/tajaran/get_physical_attributes()
	return "Таяран — разновидность преимущественно плотоядных антропоморфных гуманоидов. \
	Существует заметный половой диморфизм между женскими и мужскими особями в пользу мужских и, в зависимости от подрасы, рост взрослых таяран, за исключением подрасы Жан-Хазан. \
	В ходе взросления не выходит за пределы от 135 до 170 см, а вес варьируется в передах от 30 до 65 кг.  \
	Длинный хвост, составляющий 4/5 от роста, выполняет функцию балансира при передвижениях. \
	Тело почти полностью покрыто густой шерстью, некоторые особи имеют заметную гриву вдоль затылка и височных областей головы."

/datum/species/tajaran/get_species_description()
	return "Вид гуманоидных всеядных млекопитающих, имеющих внешнее сходство с земными кошачьими. Таяры происходят с Адомая, планеты с разнообразным климатом, \
	одной из пары землеподобных планет (вторая, более крупная, именуется Илук), вращающихся на орбите парных звёзд С’рандарр и Месса в секторе HD 4391."

/datum/species/tajaran/get_species_lore()
	return list(
		"Сотни лет таяры находились в рабстве у другой расы технологически развитых пришельцев, называемых таярами «Рабовладельцами», \
		которые жестоко эксплуатировали коренное население, заставляя его добывать для них ресурсы на многочисленных шахтах богатого полезными ископаемыми Адомая. \
		Принудительное служение «Рабовладельцам» подавило культурное и технологическое развитие таяр, что привело их к стагнации. \
		Ввиду отсутствия сохранившихся записей на момент первого контакта, точные даты событий не удалось установить, однако, изучив устные предания народа таяр, \
		учёным историкам удалось выяснить, что примерно в начале XXII века по земному летоисчислению «Рабовладельцы» создали контролирующий орган власти под названием «Совет Алхимиков», который существует и по сей день.",

		"Желание таяр свободы, подстегиваемое природным любопытством о получении новых знаний, а также осознание того факта, \
		что именно сейчас лучший момент для начала восстания из-за прибывших космических сил унатхов, устроивших шумиху в космическом пространстве планеты в 2485 году, \
		привело к восстанию в экваториальных регионах Адомая с целью обретения независимости. «Рабовладельцы», ввиду самоуверенности местных администраций и развитой за годы спокойной жизни бюрократии, \
		оказались к этому не готовы, в ряде регионов восстания неожиданно достигли успеха, что привело к ещё большему количеству восстаний. В 2486 году раса таяран попыталась связаться с прибывшим флотом унатхов и запросили поддержки в наземном сопротивлении для укрепления своих позиций, эта попытка увенчалась успехом.",

		"Силы унатхов помогали таярам в борьбе с Советом Алхимиков на планете с 2486 года. И если первую просьбу о помощи повстанцы таяран передали «на удачу», \
		просто обнаружив неизвестные сигналы в космосе у планеты, то совместные наземные операции были невозможны без понимания друг друга обеими расами. \
		Корабельные ИИ унатхов кое-как справлялись с дешифровкой сообщений от таяран и передачей обратно сообщений от унатхов, \
		но даже мощностей всех ИИ не хватило бы для координации наземных операций. Получив подтверждение о том, что сухопутная поддержка будет оказана — самые гибкие умы с обеих сторон принялись разрабатывать специфичный, унитарный язык. \
		В дальнейшем Сик’Унати как язык эволюционировал в Синта’Тайр, став основным способом общения между таярами и унатхами, преподавание этого языка до сих пор ведётся у обеих рас.",

		"Освободившись от гнета захватчиков, но потеряв подавляющее большинство образованных членов общества, таяры, \
		были неспособны организовать своё общество из-за столетий пребывания в рабстве и почти полностью остановились в освоении технологий, которые остались им в наследство после «Рабовладельцев», \
		к которым у них ранее не было доступа. После некоторого замешательства, дом Хадии выступил с предложением возглавить таяр. \
		Все прочие представители расы, ввиду отсутствия руководства, приняли предложение повсеместно. Вместе с домом Сэндай, дом Хадии восстановил «Совет Алхимиков» в новом виде для развития науки всего народа таяр, а не только правящей верхушки, они, к сожалению, \
		не уделили столько же внимания технологиям, сколько уделили культуре, поэтому, на момент первого контакта с людьми, \
		эта цивилизация только начала попытки создать первые двигатели для космических кораблей. Как единственная на тот момент правящая ячейка, \
		дом Хадии выступил как принимающая сторона для императрицы с целью заключения союза в 2493 году. Первый контакт с Человеко-Скреллианским Альянсом В 2511 году малый экспедиционный флот проекта «Новые Горизонты» \
		(на 61 % профинансированный корпорацией Nanotrasen) с его флагманами ИКН «Хокинг» и МИК «Академик Старобинский» во главе, призванный объединить усилия по освоению галактики и, благодаря этому, \
		снизить напряженность в отношениях между крупнейшими политическими структурами обитаемого космоса, сблизился с Адомаем и Илук. Первый контакт с людьми прошел не очень гладко — таяры, недавно добившиеся свободы, \
		еще слишком хорошо помнили своих угнетателей и отнеслись к новым пришельцам достаточно настороженно, однако не встретив агрессивных действий от представителей человечества, согласились на переговоры, \
		которые продлились почти 4 года, после чего было заключено соглашение о вступлении таяр в галактическое сообщество на равных правах с остальными его участниками. В 2515 году таяры были внесены в реестр младших рас галактического сообщества, а корпорация Nanotrasen победила в тендере на подъём технологического уровня Адомая.",
	)

/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Чувствительный слух",
			SPECIES_PERK_DESC = "[plural_form] лучше слышат, но более чувствительны к громким звукам, например, светошумовым гранатам.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Ночное зрение",
			SPECIES_PERK_DESC = "[plural_form] немного лучше видят в темноте, однако их глаза более чувствительны к ярким вспышкам.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dog",
			SPECIES_PERK_NAME = "Нелюбимы собаками",
			SPECIES_PERK_DESC = "Собаки, по какой-то причине, проявляют повышенный интерес в сторону таяр.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Таярская грация",
			SPECIES_PERK_DESC = "[plural_form] обладают схожими с кошачьими инстинктами, позволяющими им приземляться вертикально на ноги.  \
				Вместо того чтобы быть сбитым с ног при падении, вы получаете лишь короткое замедление. \
				Однако однако никто не гарантирует безопасность подобных действий, и падение может нанести дополнительный урон.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Внимательный уход",
			SPECIES_PERK_DESC = "[plural_form] могут зализывать раны, чтобы уменьшить кровотечение.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire-alt",
			SPECIES_PERK_NAME = "Быстрый метаболизм",
			SPECIES_PERK_DESC = "[plural_form] быстрее тратят полезные вещества, потому чаще хотят есть.",
		),
	)

	return to_add
