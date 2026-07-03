/*!
 * Tier 2 knowledge: Defensive tools and curses
 */

/**
 * Codex Morbus, an upgrade to the base codex
 * Functionally an upgraded version of the codex, but it also has the ability to cast curses by right clicking at a rune.
 * Requires you to have the blood of your victim in your off-hand
 */
/datum/heretic_knowledge/codex_morbus
	name = "Кодекс Морбус"
	desc = "Позволяет трансмутировать кодекс Цикатрикс и тело, в кодекс Морбус. \
		Кодекс позволяет быстрее рисовать руны и поглощать разломы. \
		Щелкните правой кнопкой мыши на руну, чтобы наложить проклятие на члена экипажа, вам потребуется кровь цели, чтобы проклятие вступило в силу (лучше всего сочетать с Филактерием Проклятия)."
	gain_text = "Корешок этого тома в кожаном переплете скрипит с жутким, страдальческим вздохом. \
		Перелистывание страниц требует значительных усилий, и я не осмеливаюсь задерживать взгляд на предложениях, содержащихся в книге, дольше, чем это необходимо. \
		Оно вещает о надвигающихся морях скверны, о безмолвных молельщиках у престолов мёртвых и забытых богов, а также о гибели рода смертных. \
		Оно вещает об иглах, что пронзают кожу мироздания, обнажая его и оставляя гнить. И оно зовёт меня по имени."
	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
		/mob/living/carbon/human = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix/morbus)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book_morbus"
	drafting_tier = 2

/datum/heretic_knowledge/codex_morbus/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/carbon/human/to_fuck_up = locate() in selected_atoms
	for(var/_limb in to_fuck_up.get_bodyparts())
		var/obj/item/bodypart/limb = _limb
		limb.force_wound_upwards(/datum/wound/slash/flesh/critical)
	for(var/obj/item/bodypart/limb as anything in to_fuck_up.get_bodyparts())
		to_fuck_up.cause_wound_of_type_and_severity(WOUND_BLUNT, limb, WOUND_SEVERITY_CRITICAL)
	return TRUE

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Поножи Пророка"
	desc = "Позволяет объединить пару ботинок с двумя листами титана или серебра, чтобы получить пару бронированных понож, обеспечивающих полную защиту от подскальзывания."
	gain_text = " \
		Жилистая плоть сбивается в сустав - хлопок, и глупец вырывает почерневшую ступню из \
		челюстей другого. В своей игре, длящейся веками, это искалеченное древо конечностей \
		извивается, расставляя ловушки, спрятанные в оскаленных деснах, стремясь избавиться \
		от веса трансплантированных соседей. Отягчённый изрезанными ногами, этот полог прогнивших глупцов непрестанно ищет \
		разрушения собственных уз. Мне страшно думать, что пойду по их следу, но \
		я всё равно должен продолжать. Их ритмы удерживают распрю живой, равнодушной к преградам и границам, \
		увлекая всё новых в суматоху, пока они кружатся в своём вальсе."
	required_atoms = list(
		/obj/item/clothing/shoes = 1,
		list(/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/mineral/silver) = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
	drafting_tier = 2

/datum/heretic_knowledge/spell/opening_blast
	name = "Волна отчаяния"
	desc = "Дарует вам «Волну отчаяния», заклинание, которое можно применить только будучи скованным. \
		При активации, оно освобождает вас, отталкивает и сбивает с ног окружающих, а также применяет «Хватку Мансуса» ко всем, кто находится поблизости."
	gain_text = "Мои путы разорваны в темной ярости, их ничтожные оковы рушатся перед моей силой."

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2

/datum/heretic_knowledge/rune_carver
	name = "Резной нож"
	desc = "Позволяет трансмутировать нож, осколок стекла, и лист бумаги, чтобы создать Резной нож. \
		Резной нож позволяет вам вырезать еле заметные ловушки, которые срабатывают на язычников, ступивших на них. \
		Также является весьма удобным метательным оружием."
	gain_text = "Выгравированная, высеченная на камне... вечная. Во всем скрыта сила. Я могу раскрыть ее! \
		Я могу вырезать монолит, чтобы показать цепи!"
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "rune_carver"
	drafting_tier = 2

/datum/heretic_knowledge/ether
	name = "Эфир новорождённого"
	desc = "Позволяет трансмутировать лужу рвоты, и осколок стекла, чтобы получить одноразовое зелье, выпив которое вы избавитесь от всех неестественных вещей в вашем организме, включая любые болезни, травмы или импланты, \
		помимо этого вы будете полностью исцелены, ценой этому будет потеря сознания на одну минуту."
	gain_text = "Зрение и мысли затуманиваются, когда я вдыхаю пары этого ихора. \
		Сквозь марево я обнаруживаю, что смотрю назад с облегчением - или на нечто, грубо напоминающее мой облик. \
		Это жалкое создание, вырванное из тумана снов, я преподношу своей судьбе. Каковы же мы глупцы."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "poison_flask"
	drafting_tier = 2

/datum/heretic_knowledge/painting
	name = "Незапечатанная картина"
	desc = "Позволяет трансмутировать холст и дополнительный предмет, чтобы создать произведение искусства. \
			Эти картины имеют разные эффекты в зависимости от добавленного предмета. Можно создать следующие картины: \
			Сестра и тот, кто плакал: Глаза. Очищает ваш разум, но проклинает не-еретиков галлюцинациями. \
			\
			Первое Желание: Любая часть тела. Предоставляет вам случайные органы, но проклинает не-еретиков жаждой плоти. \
			\
			Великий чапараль над холмами: Любая выращенная еда. Распространяет кудзу при установке и осмотре не-еретиками. Также дает вам маки и колокольчики. \
			\
			Дама за воротами: Перчатки. Очищает ваши мутации, но мутирует всех не-еретиков и проклинает их чесоткой. \
			\
			Подъем на ржавые горы: Мусло. Проклинает всех не-еретиков, заставляя их оставлять ржавчину на своем пути."
	gain_text = "Ветер вдохновения дует через меня; за стенами и за вратами лежит вдохновение, которое еще предстоит изобразить \
				Они снова жаждут взгляда смертных, и я исполню это желание."
	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 2
	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"
	drafting_tier = 2

/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(locate(/obj/item/organ/eyes) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/weeping)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/eyes = 1,
		)
		return TRUE

	if(locate(/obj/item/bodypart) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/desire)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/bodypart = 1,
		)
		return TRUE

	if(locate(/obj/item/food/grown) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/vines)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/food/grown = 1,
		)
		return TRUE

	if(locate(/obj/item/clothing/gloves) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/beauty)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/clothing/gloves = 1,
		)
		return TRUE

	if(locate(/obj/item/trash) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/rust)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/trash = 1,
		)
		return TRUE

	user.balloon_alert(user, "no additional atom present!")
	return FALSE
