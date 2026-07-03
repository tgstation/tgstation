
#define AGE_STAGE_1 "baby"
#define AGE_STAGE_2 "teen"
#define AGE_STAGE_3 "young"
#define AGE_STAGE_4 null // Так как нам не нужен icon_state под него
#define AGE_STAGE_5 "adult"
#define AGE_STAGE_6 "old"
#define AGE_STAGE_7 "ancient"
#define AGE_STAGE_DEFAULT null // Аналогично

// Базовый класс для запоминания возраста
/mob/living/basic/pig/named
	gold_core_spawnable = NO_SPAWN
	need_recolor = null // чтобы не перекрасил
	/// Отслеживает, сколько раундов выжила
	var/age = 0
	/// Вызов callback, выполняемый по завершении раунда, чтобы проверить, выжила ли свинья в раунде или нет
	var/datum/callback/i_will_survive

	/// Наивысшее количество раундов, в которых свинья выжила
	var/record_age = 1
	/// Сколько за каждый раунд будет добавляться "лет"
	var/addition_age = 1
	/// Со скольки лет начинает свою "новую жизнь"
	var/null_age = 0
	/// Словарь стадий: каждая стадия содержит имя, описание и дополнительный лут. Формат: "name", "desc", "loot" (добавочный лут к butcher_results)
	var/list/age_stage_data

	/// Записали ли мы уже достижения этой свиньи в базу данных?
	var/memory_saved = FALSE
	/// Имя с которым будет записываться в .json файл
	var/json_name = "pig"

// =================================
// Именованные хрюшки
// =================================

// Саня
/mob/living/basic/pig/named/Sanya
	gender = MALE
	json_name = "pig_sanya"
	age_stage_data = list(
		AGE_STAGE_1 = list("name" = "Саня", "desc" = "Маленький поросёнок, ест больше чем весит. \
			В его глазах мелькает доброта.", "loot" = null),
		AGE_STAGE_2 = list("name" = "Саня", "desc" = "Подросшее хрюкало, поевшая всё до чего дотянулось его хрюкало. \
			Мечтает стать как его дедушка.", "loot" = null),
		AGE_STAGE_3 = list("name" = "Саня", "desc" = "Весёлый подсвинок, любимец не только повара, но и всей станции. \
			Местает попасть как его дедушка на обед.", "loot" = null),
		AGE_STAGE_4 = list("name" = "Саня", "desc" = "Зрелая свинья, которую обожает весь персонал. \
			Увидеть его живым вне загона - уже и не редкость!", "loot" = null),
		AGE_STAGE_5 = list("name" = "Александр", "desc" = "Упитанный харизматичный хряк в самом расцвете сил. \
			Чудом не пущен на мясо и разожрался до состояния неприкосновенного запаса на черный день.", "loot" = null),
		AGE_STAGE_6 = list("name" = "Александр", "desc" = "Разожравшийся гордый хряк. \
			Его массивные бока так и норовят попасть на стол.", "loot" = null),
		AGE_STAGE_7 = list("name" = "Александр", "desc" = "Старый добрый хряк с сединой. Слегка подслеповат, но нюх и харизма \
			по прежнему с ним. Чудом не пущен на мясо и дожил до почтенного возраста.", "loot" = null)
	)


// Янас - инвертация Сани в виде черного хряка
/mob/living/basic/pig/named/Yanas
	gender = MALE
	icon_state = "pig_black" // для иконки
	icon_living = "pig_black"
	json_name = "pig_yanas"
	age_stage_data = list(
		AGE_STAGE_1 = list("name" = "Ян", "desc" = "Мелкий поросёнок-клептоман с наглым взглядом. Утащит всё, что блестит.",
			"loot" = list(/obj/item/stack/spacecash/c10 = 1)),
		AGE_STAGE_2 = list("name" = "Янс", "desc" = "Подросший воришка, уже пробует грызть купюры и монеты.",
			"loot" = list(/obj/item/stack/spacecash/c20 = 1)),
		AGE_STAGE_3 = list("name" = "Янас", "desc" = "Молодой хряк с повадками гангстера. \
			Любит хрюкать под музыку и рыться в чужих карманах.",
			"loot" = list(/obj/item/stack/spacecash/c50 = 1)),
		AGE_STAGE_4 = list("name" = "Янас", "desc" = "Авторитет в загоне. Находит бабки даже там, где их быть не должно.",
			"loot" = list(/obj/item/stack/spacecash/c100 = 1, /obj/item/ammo_casing/c10mm = 1)),
		AGE_STAGE_5 = list("name" = "Янас Старший", "desc" = "Опытный гангстер-хряк. Шрамы и запах пороха выдают его бурное прошлое.",
			"loot" = list(/obj/item/stack/spacecash/c200 = 1, /obj/item/ammo_casing/c10mm = 2)),
		AGE_STAGE_6 = list("name" = "Старый Янас", "desc" = "Старый мафиози загона. В его брюхе слышно позвякивание монет и гильз.",
			"loot" = list(/obj/item/stack/spacecash/c500 = 1, /obj/item/ammo_casing/c10mm = 4, /obj/item/ammo_casing/a50ae = 1)),
		AGE_STAGE_7 = list("name" = "Старый Янас", "desc" = "Пахан хрюшек. Подслеповат, но по прежнему способен выдержать \
			пару пуль за загон. Даже повара боятся его.",
			"loot" = list(/obj/item/stack/spacecash/c1000 = 1, /obj/item/ammo_casing/c10mm = 5, /obj/item/ammo_casing/a50ae = 3))
	)

// Марина - Snake Eater в Маринаде
/mob/living/basic/pig/named/Marina
	gender = FEMALE
	icon_state = "pig_mar" // для иконки
	icon_living = "pig_mar"
	json_name = "pig_marina"
	age_stage_data = list(
		AGE_STAGE_1 = list("name" = "Маринка", "desc" = "Маленькая свинка с характером.", "loot" = null),
		AGE_STAGE_2 = list("name" = "Маринка", "desc" = "Бойкая маленькая хрюшка, любящая коробки и маринад.", "loot" = null),
		AGE_STAGE_3 = list("name" = "Марина", "desc" = "Молодая хрюшка со смелым взглядом и татуировкой в виде сердца на плече. \
			Она готова бороться!", "loot" = null),
		AGE_STAGE_4 = list("name" = "Марина", "desc" = "Хрюшка способная постоять за себя, о чем свидетельствуют шрамы от когтей \
			на спине. На плечах татуировки в виде сердца и корпуса морской пехоты.",
			"loot" = list(/obj/item/ammo_casing/a40mm/rubber = 1)),
		AGE_STAGE_5 = list("name" = "Маринада", "desc" = "Боевая хрюшка, готовая на всё и постоять за свои права, о чем \
			свидетельствуют многочисленные шрамы. На плечах татуировки в виде сердца и корпуса морской пехоты. \
			На спине красуется надпись 3.10 и 33 ярких звезды.",
			"loot" = list(/obj/item/knife/combat = 1)),
		AGE_STAGE_6 = list("name" = "Маринадовна", "desc" = "Боевой хряк, прошедший множество сражений. \
			На плечах татуировки в виде сердца и корпуса морской пехоты. На спине надпись 3.10 и 33 звезды, \
			из которых 30 уже потускнели.",
			"loot" = list(/obj/item/knife/combat = 1, /obj/item/xenos_claw = 1)),
		AGE_STAGE_7 = list("name" = "Маринадовна", "desc" = "Престарелая матрона, повидавшая слишком многое. \
			Старые шрамы и татуировки заполонили всё её тело.",
			"loot" = list(/obj/item/knife/combat = 1, /obj/item/xenos_claw = 2))
	)

// поедатель змей в маринаде

// =================================
// Функции
// =================================

/mob/living/basic/pig/named/Initialize(mapload)
	. = ..()
	//parent call must happen first to ensure pig
	//is not in nullspace when child puppies spawn
	Read_Memory()

	Setup_Memory()

	//setup roundend check for pig's whereabouts
	i_will_survive = CALLBACK(src, PROC_REF(check_survival))
	SSticker.OnRoundend(i_will_survive)

// Удаляем - выпиливаем callback чтобы не записало в память
/mob/living/basic/pig/named/Destroy()
	LAZYREMOVE(SSticker.round_end_events, i_will_survive) //cleanup the survival callback
	i_will_survive = null
	return ..()

// Записываем память только при смерти гиббом (мясо выпало - значит увыргск)
/mob/living/basic/pig/named/death(gibbed)
	if(!memory_saved && gibbed)
		Write_Memory(TRUE, gibbed)
	. = ..()

/mob/living/basic/pig/named/gib()
	if(!memory_saved)
		Write_Memory(TRUE, TRUE)
	. = ..()

/mob/living/basic/pig/named/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
	memory_saved = TRUE
	var/json_file = file("data/npc_saves/[json_name].json")
	var/list/file_data = list()
	if(!gibbed)
		file_data["age"] = age + addition_age
		if((age + addition_age) > record_age)
			file_data["record_age"] = record_age + addition_age
		else
			file_data["record_age"] = record_age
	else
		file_data["age"] = null_age
		file_data["record_age"] = record_age
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/// Считывает файл сохранения .JSON и устанавливает age, record_age.
/mob/living/basic/pig/named/proc/Read_Memory()
	var/json_file = file("data/npc_saves/[json_name].json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	age = json["age"]
	record_age = json["record_age"]
	if(isnull(age))
		age = null_age
	if(isnull(record_age))
		record_age = addition_age

/// Проверяет, выжил ли в раунде или нет.
/mob/living/basic/pig/named/proc/check_survival()
	if(!stat && !memory_saved)
		Write_Memory(FALSE)

// =================================
// Загрузка характеристик из памяти
// =================================

/// Устанавливаем характеристики хрюшки после загрузки "памяти".
/mob/living/basic/pig/named/proc/Setup_Memory()
	var/stage = get_age_stage()
	var/suffix = get_suffix()

	// применяем характеристики
	switch(stage)
		if(AGE_STAGE_1) apply_stats_from(/mob/living/basic/pig/baby)
		if(AGE_STAGE_2) apply_stats_from(/mob/living/basic/pig/baby/teen)
		if(AGE_STAGE_3) apply_stats_from(/mob/living/basic/pig/baby/young)
		if(AGE_STAGE_4) apply_stats_from(/mob/living/basic/pig)
		if(AGE_STAGE_5) apply_stats_from(/mob/living/basic/pig/adult)
		if(AGE_STAGE_6) apply_stats_from(/mob/living/basic/pig/old)
		if(AGE_STAGE_7) apply_stats_from(/mob/living/basic/pig/old/ancient)

	// собираем финальный спрайт
	var/final_icon = "[body_icon_state]"
	if(!isnull(stage))
		final_icon = "[final_icon]_[stage]"
	if(suffix)
		final_icon += suffix

	icon_state = final_icon
	icon_living = final_icon
	icon_resting = "[final_icon]_rest"
	icon_dead = "[final_icon]_dead"

	// подгружаем имя и описание из age_stage_data
	if(islist(age_stage_data) && (stage in age_stage_data))
		var/list/data = age_stage_data[stage]
		if(islist(data))
			name = data["name"] || name
			desc = data["desc"] || desc
			try_add_loot(data["loot"])

/mob/living/basic/pig/named/proc/try_add_loot(list/additional_butcher_results)
	if(isnull(additional_butcher_results) || !length(additional_butcher_results))
		return
	butcher_results += additional_butcher_results

/mob/living/basic/pig/named/proc/get_age_stage()
	switch(age)
		if(0 to 1)
			return AGE_STAGE_1
		if(2 to 3)
			return AGE_STAGE_2
		if(4 to 7)
			return AGE_STAGE_3
		if(8 to 12)
			return AGE_STAGE_4
		if(13 to 19)
			return AGE_STAGE_5
		if(20 to 49)
			return AGE_STAGE_6
		if(50 to INFINITY)
			return AGE_STAGE_7
	return AGE_STAGE_DEFAULT

/mob/living/basic/pig/named/proc/get_suffix()
	if(istype(src, /mob/living/basic/pig/named/Yanas))
		return "_black"
	if(istype(src, /mob/living/basic/pig/named/Marina))
		return "_mar"
	return ""

/// Копирование характеристик из шаблона
/mob/living/basic/pig/named/proc/apply_stats_from(mob/living/basic/pig/new_pig_path)
	if(!ispath(new_pig_path))
		CRASH("Failed to apply stats to [src]: [new_pig_path] is not a path!")
	var/mob/living/basic/pig/alive_piggy = new new_pig_path(get_turf(loc)) // Need to create to copy lists
	speed = alive_piggy.speed
	maxHealth = alive_piggy.maxHealth
	health = alive_piggy.health
	butcher_results = alive_piggy.butcher_results
	if(alive_piggy.ai_controller)
		var/datum/ai_controller/pig_controller_path = alive_piggy.ai_controller.type
		ai_controller = new pig_controller_path(src)
	melee_damage_lower = alive_piggy.melee_damage_lower
	melee_damage_upper = alive_piggy.melee_damage_upper
	obj_damage = alive_piggy.obj_damage
	qdel(alive_piggy)

#undef AGE_STAGE_1 // baby
#undef AGE_STAGE_2 // teen
#undef AGE_STAGE_3 // young
#undef AGE_STAGE_4 // null
#undef AGE_STAGE_5 // adult
#undef AGE_STAGE_6 // old
#undef AGE_STAGE_7 // ancient
#undef AGE_STAGE_DEFAULT
