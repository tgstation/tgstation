/datum/heretic_knowledge_tree_column/void
	route = PATH_VOID
	ui_bgr = "node_void"
	complexity = "Низкая"
	complexity_color = COLOR_GREEN
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "void_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Пустоты фокусируется на скрытности, леденящем холоде, подвижности и разгерметизациях.",
		"Выберите этот путь, если вам нравится быть проворным убийцей, который не дает своим врагам возможности догнать его.",
	)
	pros = list(
		"Защита от космического пространства.",
		"Ваши заклинания накладывают суммирующийся отрицательный эффект, который охлаждает и замедляет цели.",
		"Большое количество заклинаний подвижности.",
		"Высокая скрытность.",
	)
	cons = list(
		"Несмотря на то, что вы защищены от космического пространства, в нем вы далеко не так подвижны, как пешком.",
		"Имеет затруднения в борьбе с противниками, устойчивых к холоду.",
		"Испытывает сложности в борьбе синтетиками.",
	)
	tips = list(
		"«Хватка Мансуса» лишает противника дара речи, делая её идеальным инструментом для тихого убийства (Держите в уме, что датчики она не выключает, и вам придется это делать самостоятельно). Хватка накладывает метку, срабатывающую при ударе клинком Пустоты, активация метки наложит экстремальное переохлаждение, значительно замедляя цель.",
		"Накидка Пустоты может быть использована для сокрытия клинка Пустоты и кодекса Цикатрикс при опущенном капюшоне, и для фокусировки заклинаний при поднятом.",
		"«Холод Пустоты» - это отрицательный эффект, накладываемый вашими заклинаниями, вашей Хваткой, вашими метками и вашим клинком, когда вы откроете его улучшения. Каждый раз, накладывая эффект, вы будете замедлять противника на 10%, вплоть до 50%.",
		"При накоплении 5 стаков «Холода Пустоты», цель теряет возможность согреться.",
		"Вы невосприимчивы к низким температурам и низкому давлению с начала смены. Поднимите свой пассивный навык до второго уровня и у вас пропадет потребность в дыхании. Используйте это себе на пользу.",
		"«Пустотная тюрьма» может ввести цель в стазис на 10 секунд. Идеально, если вы сражаетесь с несколькими противниками, и вам нужно изолировать одну цель за раз.",
		"«Поток Пустоты» - ваша сигнатурная способность. Она медленно разрушает окна и воздушные шлюзы в зоне своего действия. Используйте это для создания разгерметизаций и расширения своей зоны контроля.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	knowledge_tier1 = /datum/heretic_knowledge/spell/void_phase
	guaranteed_side_tier1 = /datum/heretic_knowledge/void_cloak
	knowledge_tier2 = /datum/heretic_knowledge/spell/void_prison
	guaranteed_side_tier2 = /datum/heretic_knowledge/ether
	robes = /datum/heretic_knowledge/armor/void
	knowledge_tier3 = /datum/heretic_knowledge/spell/void_pull
	guaranteed_side_tier3 = /datum/heretic_knowledge/summon/maid_in_mirror
	blade = /datum/heretic_knowledge/blade_upgrade/void
	knowledge_tier4 = /datum/heretic_knowledge/spell/void_conduit
	ascension = /datum/heretic_knowledge/ultimate/void_final

/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Проблеск Зимы"
	desc = "Открывает перед вами Путь Пустоты. \
		Позволяет трансмутировать нож при отрицательных температурах в Пустотный клинок. \
		Одновременно можно иметь только два."
	gain_text = "Я чувствую мерцание в воздухе, воздух вокруг меня становится холоднее. \
		Я начинаю осознавать пустоту существования. Что-то наблюдает за мной."
	required_atoms = list(/obj/item/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "void_blade"
	mark_type = /datum/status_effect/eldritch/void
	eldritch_passive = /datum/status_effect/heretic_passive/void

/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ритуал провален, неподходящая локация!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ритуал провален, не достаточно холодно!")
		return FALSE

	return ..()

/datum/heretic_knowledge/limited_amount/starting/base_void/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.adjust_silence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/spell/void_phase
	name = "Фаза Пустоты"
	desc = "Дарует вам «Фазу Пустоты» - заклинание телепортации дальнего действия. \
		Дополнительно наносит урон язычникам около места входа и места выхода из фазы."
	gain_text = "Сущность называет себя Аристократом. Он легко проходит сквозь воздух, \
		оставляя за собой резкий холодный ветер. Он исчезает, а я остаюсь в метели."
	action_to_add = /datum/action/cooldown/spell/pointed/void_phase
	cost = 2
	research_tree_icon_frame = 7

/datum/heretic_knowledge/spell/void_prison
	name = "Пустотная тюрьма"
	desc = "Дарует вам «Пустотную тюрьму» - заклинание помещающее вашего противника в шар, лишая его способности говорить и делать что-либо. \
		Накладывает Холод Пустоты после окончания эффекта."
	gain_text = "В начале я видел себя, танцующим на заснеженной улице. \
		Я пытаюсь закричать, схватить этого дурака и сказать им, чтобы они бежали. \
		Но рубцы остались только на моём избивающем кулаке. \
		Мое улыбающееся лицо поворачивается ко мне, и в остекленевших глазах отражается тот пустой путь, на который меня завели."

	action_to_add = /datum/action/cooldown/spell/pointed/void_prison
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/armor/void
	name = "Сплетение Пустоты"
	desc = "Позволяет трансформировать стол (или костюм) и маску при минусовых температурах для создания Сплетения Пустоты, это броня будет время от времени нейтрализовывать атаки по вам и ненадолго маскировать вас, давая сменить позицию. \
			Действует как фокусировка, пока надет капюшон."
	gain_text = "Ступая сквозь холодный воздух, я был шокирован новыми ощущениями. \
				Тысячи почти неуловимых нитей цепляются за мою фигуру. \
				С каждым шагом я теряюсь в догадках. \
				Даже когда я слышу хруст снега, когда ставлю ногу на землю, я не чувствую ничего."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/void)
	research_tree_icon_state = "void_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
	)

/datum/heretic_knowledge/armor/void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ритуал провален, неподходящее место!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ритуал провален, недостаточно холодно!")
		return FALSE

	return ..()

/datum/heretic_knowledge/spell/void_pull
	name = "Притяжение Пустоты"
	desc = "Дарует вам «Притяжение Пустоты» - заклинание, притягивающее к вам всех близлежащих язычников, ненадолго оглушая их."
	gain_text = "Всё мимолетно, но что ещё остаётся? Я близок к завершению того, что было начато. \
		Аристократ снова раскрывает себя мне. Они говорят мне, что я опоздал. Их притяжение огромно, я не могу повернуть назад."

	action_to_add = /datum/action/cooldown/spell/aoe/void_pull
	cost = 2
	research_tree_icon_frame = 6

/datum/heretic_knowledge/blade_upgrade/void
	name = "Ищущий клинок"
	desc = "Ваш клинок теперь замораживает врагов. К тому же, теперь вы можете атаковать отмеченные цели на расстоянии Пустотным клинком, телепортируясь прямо к ним. "
	gain_text = "Мимолетные воспоминания, мимолетные ноги. Я отмечаю свой путь застывшей кровью на снегу. Покрытый и забытый."


	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_void"

/datum/heretic_knowledge/blade_upgrade/void/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)

/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)

/datum/heretic_knowledge/spell/void_conduit
	name = "Поток Пустоты"
	desc = "Дарует вам «Поток Пустоты» - заклинание, вызывающее пульсирующие врата в саму Пустоту. Каждый импульс разбивает окна и воздушные шлюзы, поражая язычников жутким холодом и защищая еретика от низкого давления."
	gain_text = "Гул в неподвижном, холодном воздухе превращается в какофонию грохотов. \
		За этим шумом невозможно различить стук оконных стекол и зияющее знание, которое рикошетом отдается в моем черепе. \
		Врата не затворятся. Я не могу сдержать этот холод."
	action_to_add = /datum/action/cooldown/spell/conjure/void_conduit
	cost = 2
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/void_final
	name = "Вальс Конца Времен"
	desc = "Ритуал вознесения Пути Пустоты. \
		Принесите 3 трупа к руне трансмутации при отрицательных температурах, чтобы завершить ритуал. \
		После завершения вызывает сильный шторм пустотного снега, \
		который обрушивается на станцию, замораживая и повреждая язычников. Те, кто находится поблизости, замолчат и замерзнут еще быстрее. \
		Кроме того, у вас появится иммунитет к воздействию космоса."
	gain_text = "Мир погружается во тьму. Я стою в пустом мире, с неба падают мелкие хлопья льда. \
		Аристократ стоит передо мной, призывая. Мы будем играть вальс под шепот умирающей реальности, \
		пока мир разрушается на наших глазах. Пустота вернет все в ничто, УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/void_ascension
	announcement_text = "%SPOOKY% Аристократ пустоты %NAME% ступил в Вальс, завершающий миры! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_void.ogg'
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/proximity_monitor/advanced/void_storm/heavy_storm

/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ритуал провален, неподходящее место!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ритуал провален, не достаточно холодно!")
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), type)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	heavy_storm = new(user, 10)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.get_organ_slot(ORGAN_SLOT_EYES)
		heretic_eyes?.color_cutoffs = list(30, 30, 30)
		ascended_human.update_sight()

/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death() // Losing is pretty much dying. I think

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER

	for(var/atom/thing_in_range as anything in range(10, source))
		if(iscarbon(thing_in_range))
			var/mob/living/carbon/close_carbon = thing_in_range
			if(close_carbon.can_block_magic())
				continue
			if(IS_HERETIC_OR_MONSTER(close_carbon))
				close_carbon.apply_status_effect(/datum/status_effect/void_conduit)
				continue
			close_carbon.adjust_silence_up_to(2 SECONDS, 20 SECONDS)
			close_carbon.apply_status_effect(/datum/status_effect/void_chill, 1)
			close_carbon.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))
			close_carbon.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(istype(thing_in_range, /obj/machinery/door) || istype(thing_in_range, /obj/structure/door_assembly))
			var/obj/affected_door = thing_in_range
			affected_door.take_damage(rand(60, 80))

		if(istype(thing_in_range, /obj/structure/window) || istype(thing_in_range, /obj/structure/grille))
			var/obj/structure/affected_structure = thing_in_range
			affected_structure.take_damage(rand(20, 40))

		if(isturf(thing_in_range))
			var/turf/affected_turf = thing_in_range
			var/datum/gas_mixture/environment = affected_turf.return_air()
			environment.temperature *= 0.9

	// Telegraph the storm in every area on the station.
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!storm)
		storm = new /datum/weather/void_storm(station_levels)
		storm.telegraph()

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_death(datum/source)
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)
	if(heavy_storm)
		QDEL_NULL(heavy_storm)
	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_LIVING_DEATH, COMSIG_QDELETING))

///Few checks to determine if we can deflect bullets
/datum/heretic_knowledge/ultimate/void_final/proc/can_deflect(mob/living/ascended_heretic)
	if(!(ascended_heretic.mobility_flags & MOBILITY_USE))
		return FALSE
	if(!isturf(ascended_heretic.loc))
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/void_final/proc/hit_by_projectile(mob/living/ascended_heretic, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(ascended_heretic))
		return NONE

	ascended_heretic.visible_message(
		span_danger("Буря Пустоты, окружающая [ascended_heretic.declent_ru(GENITIVE)] отклоняет [hitting_projectile.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("Буря Пустоты защитила вас от [hitting_projectile.declent_ru(ACCUSATIVE)]!"),
	)
	playsound(ascended_heretic, SFX_VOID_DEFLECT, 75, TRUE)
	hitting_projectile.firer = ascended_heretic
	if(prob(75))
		hitting_projectile.set_angle(get_angle(hitting_projectile.firer, hitting_projectile.fired_from))
	else
		hitting_projectile.set_angle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED
