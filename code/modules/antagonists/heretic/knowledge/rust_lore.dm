/datum/heretic_knowledge_tree_column/rust
	route = PATH_RUST
	ui_bgr = "node_rust"
	complexity = "Умеренная"
	complexity_color = COLOR_YELLOW
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "rust_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Ржавчины посвящен стойкости, разложению и преодолению препятствий с помощью грубой силы.",
		"Выбирайте этот путь, если вам нравится находиться на своей территории и позволять сражению прийти к вам самим.",
	)
	pros = list(
		"Стоя на ржавом полу, вы становитесь очень стойким, заживляете раны и снимаете оглушение.",
		"Ржавый пол наносит урон вашим врагам и замедляют их.",
		"Вы можете с легкостью разрушать стены, предметы, мехов, сооружения и шлюзы.",
		"Вы можете мгновенно уничтожить силиконов или синтетических членов экипажа с помощью «Хватка Мансуса».",
		"У вас есть множество способностей, позволяющих с легкостью сражаться на своей территории.",
	)
	cons = list(
		"Чрезвычайно открытый; полностью исключает возможность скрытности.",
		"Если вы не стоите на ржавых плитках, вы становитесь гораздо более уязвимыми.",
		"Будучи запертым в рамках своей территории, против вас гораздо проще использовать разрушительные средства (такие как бомбы).",
		"Ваша высокая защита достигается за счет снижения атакующей силы.",
	)
	tips = list(
		"Ваша «Хватка Мансуса» мгновенно уничтожает мехов, силиконов и андроидов. Попадание вашим клинком по помеченной цели вызывает сильное отвращение и рвоту, на короткое время сбивая её с ног.",
		"Ваша «Хватка Мансуса» и ваши заклинания способны вызывать ржавчину на стенах и полах, что приносит вам пользу и наносит вред экипажу и силиконам. Распространяйте ржавчину как можно больше.",
		"Ржавые покрытия исцеляют вас, регулируют температуру крови, делают вас устойчивыми к сбиванию с ног дубинкой, восстанавливают вашу выносливость и кровь, а также исцеляют ваши раны и конечности, как только вы повысите уровень своей пассивной способности.",
		"Всегда сражайтесь на своей территории. Ваш противник, вторгшийся на вашу территорию, находится в крайне невыгодном положении.",
		"«Восстановленные Обноски» получают усиление только тогда, когда вы находитесь на ржавых плитах. Если вы хотите максимально использовать его силу, оставайтесь на ржавых плитах.",
		"Ваша способность разрушать объекты и стены улучшается по мере улучшения вашей пассивной способности; в конечном итоге вы сможете расплавлять шлюзы, укрепленные и даже титановые стены.",
		"Распространение ржавчины может быть довольно медленным, особенно на ранних этапах. Подумайте о том, чтобы вызвать несколько ржавых ходоков, которые помогут вам расширить ваши владения.",
		"«Возведение Ржавчины» позволяет создавать барьеры для укрытия или побега, а в крайнем случае даже блокировать путь к спасению для других. Используйте эту возможность, чтобы манипулировать окружающей средой в своих интересах.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_rust
	knowledge_tier1 = /datum/heretic_knowledge/spell/area_conversion
	guaranteed_side_tier1 = /datum/heretic_knowledge/rust_sower
	knowledge_tier2 = /datum/heretic_knowledge/spell/rust_construction
	guaranteed_side_tier2 = /datum/heretic_knowledge/summon/rusty
	robes = /datum/heretic_knowledge/armor/rust
	knowledge_tier3 = /datum/heretic_knowledge/spell/entropic_plume
	guaranteed_side_tier3 = /datum/heretic_knowledge/crucible
	blade = /datum/heretic_knowledge/blade_upgrade/rust
	knowledge_tier4 = /datum/heretic_knowledge/spell/rust_charge
	ascension = /datum/heretic_knowledge/ultimate/rust_final

/datum/heretic_knowledge/limited_amount/starting/base_rust
	name = "«Сказание Кузнеца»"
	desc = "Открывает перед вами Путь Ржавчины. \
		Позволяет трансмутировать нож с любым мусором в Ржавый клинок. \
		Одновременно можно создать только два."
	gain_text = "\"Позвольте мне рассказать вам историю\", сказал Кузнец, вглядываясь в глубину своего ржавого клинка."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rust_blade"
	mark_type = /datum/status_effect/eldritch/rust
	eldritch_passive = /datum/status_effect/heretic_passive/rust

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	user.RemoveElement(/datum/element/rust_healing, FALSE, 1.5, 5)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY)
	user.AddElement(/datum/element/rust_healing, FALSE, 1.5, 5)

/datum/heretic_knowledge/limited_amount/starting/base_rust/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		for(var/obj/item/bodypart/robotic_limb as anything in carbon_target.get_bodyparts())
			if(IS_ROBOTIC_LIMB(robotic_limb))
				robotic_limb.receive_damage(500)

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	source.do_rust_heretic_act(target)

/datum/heretic_knowledge/limited_amount/starting/base_rust/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// Rusting an airlock causes it to lose power, mostly to prevent the airlock from shocking you.
	// This is a bit of a hack, but fixing this would require the entire wire cut/pulse system to be reworked.
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		airlock.loseMainPower()

	source.do_rust_heretic_act(target)
	return COMPONENT_USE_HAND

/datum/heretic_knowledge/spell/rust_charge
	name = "Ржавый рывок"
	desc = "Рывок, который необходимо начать на ржавой поверхности и который уничтожит все ржавые объекты, с которыми вы соприкоснетесь, нанесет большой урон другим и разносит ржавчину вокруг вас на время действия."
	gain_text = "Холмы сверкали, и по мере того, как я приближался к ним, мои мысли начали блуждать. Я быстро собрался с духом и двинулся вперёд. Этот последний отрезок пути будет самым опасным."

	action_to_add = /datum/action/cooldown/mob_cooldown/charge/rust
	cost = 2
	is_final_knowledge = TRUE

/datum/heretic_knowledge/spell/rust_construction
	name = "Возведение ржавчины"
	desc = "Дарует вам «Возведение ржавчины» - заклинание, позволяющее возвести стену из ржавого пола. \
		Любой человек, находящийся над стеной, будет отброшен в сторону (или вверх) и получит урон."
	gain_text = "В моем сознании начали плясать образы иноземных и зловещих сооружений. Покрытые с ног до головы толстым слоем ржавчины, \
		они больше не выглядели рукотворными. А может быть, они вообще никогда и не существовали."
	action_to_add = /datum/action/cooldown/spell/pointed/rust_construction
	cost = 2

/datum/heretic_knowledge/armor/rust
	name = "Уцелевшие обломки"
	desc = "Позволяет трансмутировать стол (или костюм), маску и любой мусор, чтобы создать Уцелевшие обломки. \
			Дает дополнительную броню, сопротивление захвату и невосприимчивость к шприцам, когда находится на ржавчине. \
			Действует как фокусировка, пока надет капюшон."
	gain_text = "Из-под искореженного металлолома кузнец извлекает древнюю ткань. \
				\"Все, что она когда-то символизировала — утрачено. Поэтому сейчас мы придаем ей новое предназначение.\""
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust)
	research_tree_icon_state = "rust_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/trash = 1,
	)

/datum/heretic_knowledge/spell/area_conversion
	name = "Агрессивное распространение"
	desc = "Дарует вам заклинание «Агрессивное распространение», которое распространяет ржавчину на близлежащие поверхности. \
		Уже заржавевшие поверхности разрушаются. \ Также улучшает способности ржавчины еретиков не Пути ржавчины."
	gain_text = "Мудрецы знают, что не стоит посещать Ржавые холмы... Но рассказ Кузнеца был вдохновляющим."
	action_to_add = /datum/action/cooldown/spell/aoe/rust_conversion
	cost = 2
	research_tree_icon_frame = 5

/datum/heretic_knowledge/blade_upgrade/rust
	name = "Токсичный клинок"
	desc = "Ваш Ржавый клинок теперь отвращает врагов при атаке. \ Позволяет заставить ржаветь титаниум и пластитаниум."
	gain_text = "Кузнец протягивает вам свой клинок. \"Клинок проведет тебя через плоть, если ты позволишь ему.\" \
		Тяжелая ржавчина утяжеляет клинок. Вы пристально вглядываетесь в него. Ржавые холмы зовут тебя."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rust"

/datum/heretic_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.adjust_disgust(50)

/datum/heretic_knowledge/spell/area_conversion/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

/datum/heretic_knowledge/spell/entropic_plume
	name = "Шлейф энтропии"
	desc = "Дарует вам «Шлейф энтропии», заклинание, выпускающее досаждающую волну ржавчины. \
		Ослепляет, отравляет и накладывает «Амок» на любого язычника, по которому попадаёт, заставляя его в безумии атаковать \
		и друзей, и врагов. Также ржавеет и разрушает поверхности, на которые попадает. Улучшает способности ржавчины еретиков не Пути ржавчины."
	gain_text = "Коррозия была неостановима. Ржавчина была неприятной. \
		Кузнец ушел, ты держишь его клинок. Чемпионы надежды, Повелитель ржавчины близок!"

	action_to_add = /datum/action/cooldown/spell/cone/staggered/entropic_plume
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/ultimate/rust_final
	name = "Клятва Несущего Ржавчину"
	desc = "Ритуал вознесения Пути ржавчины. \
		Принесите 3 трупа к руне трансмутации на мостик станции, чтобы завершить ритуал. \
		После завершения, ритуальное место будет бесконечно распространять ржавчину на любую поверхность, не останавливаясь ни перед чем. \
		Кроме того, вы станете чрезвычайно стойкими на ржавчине, исцеляясь втрое быстрее \
		и приобретая иммунитет ко многим эффектам и опасностям. Вы сможете заставлять ржаветь почти всё."
	gain_text = "Чемпион ржавчины. Разлагатель стали. Бойся темноты, ибо пришел ПОВЕЛИТЕЛЬ РЖАВЧИНЫ! \
		Работа Кузнеца продолжается! Ржавые холмы, УСЛЫШЬТЕ МОЕ ИМЯ! УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/rust_ascension
	announcement_text = "%SPOOKY% Бойтесь разложения, ибо Предводитель Ржавчины, %NAME%, вознесся! Никто не уйдет от коррозии! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_rust.ogg'
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/station/command/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)

/datum/heretic_knowledge/ultimate/rust_final/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null

/datum/heretic_knowledge/ultimate/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(ritual_location)
		var/area/our_area = get_area(loc)
		if(!istype(our_area, ritual_location))
			loc.balloon_alert(user, "ритуал провален, нужно быть в [initial(ritual_location.name)]!") // "must be in bridge"
			return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	trigger(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)
	var/datum/action/cooldown/spell/aoe/rust_conversion/rust_spread_spell = locate() in user.actions
	rust_spread_spell?.cooldown_time /= 2

// I sure hope this doesn't have performance implications
/datum/heretic_knowledge/ultimate/rust_final/proc/trigger(turf/center)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (transform_turf.turf_flags & NO_RUST)
			continue
		var/dist = get_dist(center, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (2 SECONDS) * iterator)

/datum/heretic_knowledge/ultimate/rust_final/proc/transform_area(list/turfs)
	turfs = shuffle(turfs)
	var/numturfs = length(turfs)
	var/first_third = turfs.Copy(1, round(numturfs * 0.33))
	var/second_third = turfs.Copy(round(numturfs * 0.33), round(numturfs * 0.66))
	var/third_third = turfs.Copy(round(numturfs * 0.66), numturfs)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), first_third), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), second_third), 5 SECONDS * 0.33)
	addtimer(CALLBACK(src, PROC_REF(delay_transform_turfs), third_third), 5 SECONDS * 0.66)

/datum/heretic_knowledge/ultimate/rust_final/proc/delay_transform_turfs(list/turfs)
	for(var/turf/turf as anything in turfs)
		turf.rust_heretic_act(RUST_RESISTANCE_ORGANIC)
		CHECK_TICK

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_move(mob/living/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(source.is_touching_rust())
		if(!immunities_active)
			source.add_traits(conditional_immunities, type)
			source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = TRUE
	else // If we're not on a rust turf, and we have given out our traits, nerf our guy
		if(immunities_active)
			source.remove_traits(conditional_immunities, type)
			source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/ultimate/rust_final/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER

	if(!source.is_touching_rust())
		return

	var/need_mob_update = FALSE
	var/base_heal_amt = 1 * DELTA_WORLD_TIME(SSmobs)
	need_mob_update += source.adjust_brute_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-base_heal_amt, updating_health = FALSE, forced = TRUE)
	need_mob_update += source.adjust_oxy_loss(-base_heal_amt, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-base_heal_amt * 4, updating_stamina = FALSE)

	source.adjust_blood_volume(base_heal_amt, maximum = BLOOD_VOLUME_NORMAL)

	if(need_mob_update)
		source.updatehealth()
