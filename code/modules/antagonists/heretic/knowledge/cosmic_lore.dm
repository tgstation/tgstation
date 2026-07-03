/datum/heretic_knowledge_tree_column/cosmic
	route = PATH_COSMIC
	ui_bgr = "node_cosmos"
	complexity = "Высокая"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "cosmic_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Космоса фокусируется на ограничении передвижений, телепортациях, и контроле пространства.",
		"Выбирайте этот путь, если вам нравится приспосабливаться к окружающей среде, и мыслить вне рамок (или внутри них).",
	)
	pros = list(
		"Ограничивайте передвижения противника при помощи космических полей.",
		"С лёгкостью выходите в космос, и возвращайтесь обратно.",
		"Быстро телепортируйтесь по всей станции.",
		"Ставьте противников в тупик, воздвигая барьер за барьером.",
	)
	cons = list(
		"Требуется распространять «Звездные Метки», чтобы влиять на противника космическими полями.",
		"Относительно низкий урон.",
		"Относительно низкая выживаемость, с сильной зависимостью от правильного использования способностей.",
	)
	tips = list(
		"«Хватка Мансуса» помечает вашего противника «Звездной Меткой», а также запоминает место, где он её получил. При активации, помеченый враг перемещается в место, где метка была нанесена и ненадолго лишается способности двигаться.",
		"«Космические руны» позволяют мгновенно переноситься между ними. Однако стоит быть осторожным, так как ими могут воспользоваться и неверные. Будьте креативны, заставьте своих противников перенестись прямо в ловушку. После перемещения, они также получат «Звездную Метку»!",
		"Когда вы стоите на «Космической руне», вы можете нажать на себя пустой рукой и активировать её.",
		"Противники помеченные Звездой не могут самостоятельно пересечь границу звездного поля. Однако, ничто не помешает их оттуда вытащить!",
		"«Звёздный взрыв» одновременно является способностью повышающей вашу подвижность, а также неплохим способом выйти или вывести кого-то из боя. Используйте её, чтобы поймать в своё звездное поле сразу несколько человек.",
		"«Касание Звезды» не даст цели телепортироваться от вас. Если они не смогут разорвать связь, то будут усыплены, а после телепортируются к вашим ногам.",
		"Всегда полезно оставить одну «Космическую руну» рядом с вашей ритуальной руной, это позволит вам быстро похищать свои цели, чтобы принести их в жертву.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	knowledge_tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	knowledge_tier2 = /datum/heretic_knowledge/spell/star_blast
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/space_phase
	robes = /datum/heretic_knowledge/armor/cosmic
	knowledge_tier3 = /datum/heretic_knowledge/spell/star_touch
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	knowledge_tier4 = /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final

/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Вечные врата"
	desc = "Открывает перед вами Путь Космоса. \
		Позволяет трансмутировать лист плазмы и нож в Космический клинок. \
		Одновременно можно иметь только два."
	gain_text = "Туманность появилась в небе, ее пламенное рождение озарило меня. Это было начало великой трансценденции"
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"
	mark_type = /datum/status_effect/eldritch/cosmic
	eldritch_passive = /datum/status_effect/heretic_passive/cosmic

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/limited_amount/starting/base_cosmic/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	to_chat(target, span_danger("Над вашей головой появилось космическое кольцо!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	create_cosmic_field(get_turf(source), source)

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Космические руны"
	desc = "Дарует вам «Космические руны» - заклинание, создающее две руны, связанные друг с другом, позволяющие легко переноситься между ними. \
		Только сущность активировавшая руну будет перенесена, использование руну доступно любому созданию, не обладающий «Меткой Звезды». \
		Однако люди с «Звездной Меткой» будут перенесены вместе с тем, кто использует руну."
	gain_text = "Далекие звезды закрались в мои сны, беспричинно ревя и крича. \
		Я заговорил и услышал, как мои же слова отозвались эхом."
	action_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/spell/star_blast
	name = "Звёздный взрыв"
	desc = "Дарует вам «Звёздный взрыв» - заклинание, пускающее медленно движущийся снаряд, создающий космические поля на своем пути. \
		Любой, пораженный снарядом, получит урон от огня, потеряет сознание и распространит на людей в радиусе трёх клеток от себя Звёздную Метку."
	gain_text = "С каждой новой жертвой, как никогда ранее четко, слышу я слова Зверя, стоящего за мной."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 2

/datum/heretic_knowledge/armor/cosmic
	name = "Плащ сотканный из звёзд"
	desc = "Позволяет трансмутировать стол (или костюм), маску и лист плазмы в Сотканный из звёзд плащ, дающий защиту от космического пространства, а также способность левитировать по желанию. \
			Действует как фокусировка, пока надет капюшон."
	gain_text = "Подобно сияющим нитям, сияли звезды, соединяясь в шелковистую форму развевающегося плаща, который одновременно окутывает и обнажает мои плечи. \
				Глаза Зверя смотрят на меня и сквозь меня."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic)
	research_tree_icon_state = "cosmic_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)

/datum/heretic_knowledge/spell/star_touch
	name = "Касание Звезды"
	desc = "Дарует вам «Касание Звезды» - заклинание, ставящее «Метку Звезды» на вашу цель \
		и создающее космическое поле у ваших ног и на тайлах рядом с вами. Цели, которые уже имеют «Метку Звезды» \
		будут усыплены на 4 секунды. Когда жертва получает удар, она также создает обжигающий луч. \
		Луч действует в течение минуты, пока луч не будет прегражден или пока не будет найдена новая цель."
	gain_text = "Проснувшись в холодном поту, я почувствовал ладонь на своем скальпе, сигил был выжжен на мне. \
		Теперь мои вены изучали странное фиолетовое сияние: Зверь знает, что я превзойду их ожидания."
	action_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 2

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Космический клинок"
	desc = "Теперь ваш клинок своими ударами наносит «Метку Звезды» своим жертвам, позволяя атаковать язычников с меткой на расстоянии. \
		Ваши атаки также наносят бонусный урон к двум предыдущим жертвам.\
		Комбо сбрасывается после двух секунд без атаки, или если вы атакуете кого-то уже отмеченного. \
		При комбинировании трёх атак вы получите космический след и увеличите таймер вашего комбо до 10 секунд."
	gain_text = "Когда Зверь взял мои клинки в свою руку, я упал на колени и почувствовал острую боль \
		Клинки теперь сверкали раздробленной силой. Я упал на землю и зарыдал у ног Зверя."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/datum/weakref/second_target
	/// Storage for the third target.
	var/datum/weakref/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0
	/// How much further we can hit people, modified by ascension
	var/max_attack_range = 2

/datum/heretic_knowledge/blade_upgrade/cosmic/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	. = ..()
	if(!isliving(target) || get_dist(source, target) > max_attack_range || !target.has_status_effect(/datum/status_effect/star_mark))
		return
	source.changeNext_move(blade.attack_speed)
	return blade.attack(target, source)

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjust_fire_loss(5, updating_health = FALSE)
	if(need_mob_update)
		target.updatehealth()
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjust_fire_loss(14, updating_health = FALSE)
		if(need_mob_update)
			second_target_resolved.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjust_fire_loss(28, updating_health = FALSE)
			if(need_mob_update)
				third_target_resolved.updatehealth()
			if(combo_counter == 3)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					source.AddElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = WEAKREF(target)

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	source.RemoveElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)
	combo_duration = combo_duration_amount
	combo_counter = 0
	new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(combo_timer)
		deltimer(combo_timer)

/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration < max_combo_duration)
		combo_duration += increase_amount

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Космическая экспансия"
	desc = "Дарует вам «Космическая экспансия» - заклинание, создающее вокруг вас область космических полей размером 5x5. \
		Ближайшие существа также будут отмечены «Меткой Звезды»."
	gain_text = "Теперь земля содрогалась подо мной. Зверь вселился во меня, и голос его опьянял меня."
	action_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 2
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Дар Создателей"
	desc = "Ритуал вознесения Пути Космоса. \
		Для завершения ритуала принесите 3 трупа с «Меткой звезды» к руне трансмутации. \
		После завершения вы станете обладателем Звездочета. \
		Вы сможете управлять Звездочетом с помощью Альт-Клик. \
		Вы также можете отдавать ему команды с помощью речи. \
		Звездочет - сильный союзник, который может даже разрушить укрепленные стены. \
		Звездочет обладает аурой, которая исцеляет вас и наносит урон противникам. \
		«Касание Звезды» теперь может телепортировать вас к Звездочету, когда активируется в вашей руке. \
		Заклинание «Космическая экспансия» и ваши клинки также значительно усилены."
	gain_text = "Зверь протянул руку, я ухватился за нее, и он притянул меня к себе. Их тело возвышалось надо моим, но также казалось настолько крохотными и слабым после всех их историй в моей голове. \
		Я прижался к ним, они защитят меня, и я защищаю их. \
		Я закрыл глаза, прижавшись головой к их телу. Я был в безопасности. \
		УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/cosmic_ascension
	announcement_text = "%SPOOKY% Звездочет прибыл на станцию, %NAME% вознесся! Эта станция - владения Космоса! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_cosmic.ogg'
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/star_gazer
	)
	/// List of traits given once ascended
	var/static/list/ascended_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_XRAY_VISION)
	/// List of traits given to our cute lil guy
	var/static/list/stargazer_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_BOMBIMMUNE, TRAIT_XRAY_VISION)

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_status_effect(/datum/status_effect/star_mark)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(ascended_traits, type)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.get_organ_slot(ORGAN_SLOT_EYES)
		ascended_human.update_sight()
		heretic_eyes?.color_cutoffs = list(30, 30, 30)
		ascended_human.update_sight()

	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(loc, user)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands, radial_menu_offset = list(30,0), radial_menu_lifetime = 15 SECONDS, radial_relative_to_user = TRUE)
	star_gazer_mob.befriend(user)
	var/datum/action/cooldown/open_mob_commands/commands_action = new /datum/action/cooldown/open_mob_commands()
	commands_action.Grant(user, star_gazer_mob)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = locate() in user.actions
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE
	star_gazer_mob.add_traits(stargazer_traits, type)
	star_gazer_mob.leash_to(star_gazer_mob, user)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS
	blade_upgrade.max_attack_range = 3

	var/datum/action/cooldown/spell/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.actions
	cosmic_expansion_spell?.ascended = TRUE

	var/datum/action/cooldown/mob_cooldown/replace_star_gazer/replace_gazer = new(src)
	replace_gazer.Grant(user)
	replace_gazer.bad_dog = WEAKREF(star_gazer_mob)

/// Replace an annoying griefer you were paired up to with a different but probably no less annoying player.
/datum/action/cooldown/mob_cooldown/replace_star_gazer
	name = "Перезагрузка сознания Звездочета"
	desc = "Заменяет разум вызванного вами призрака разумом другого призрака."
	button_icon = 'icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	check_flags = NONE
	click_to_activate = FALSE
	cooldown_time = 5 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Weakref to the stargazer we care about
	var/datum/weakref/bad_dog

/datum/action/cooldown/mob_cooldown/replace_star_gazer/Activate(atom/target)
	StartCooldown(5 MINUTES)

	var/mob/living/to_reset = bad_dog.resolve()

	to_chat(owner, span_hierophant("Вы предлагаете изменить личность [to_reset]..."))
	var/mob/chosen_one = SSpolling.poll_ghost_candidates("Хотите ли вы играть за [span_danger("[owner.real_name]")] [span_notice(to_reset.name)]?", check_jobban = ROLE_PAI, poll_time = 10 SECONDS, alert_pic = to_reset, jump_target = owner, role_name_text = to_reset.name, amount_to_pick = 1)
	if(isnull(chosen_one))
		to_chat(owner, span_hierophant("Ваш запрос о смене личности [to_reset], судя по всему, был отклонён... Похоже пока придётся мириться с этим."))
		StartCooldown()
		return FALSE
	to_chat(to_reset, span_hierophant("Ваш призыватель перезагрузил вас, и вашим телом завладел призрак. Похоже, он был не очень доволен вашими действиями."))
	to_chat(owner, span_hierophant("Разум [to_reset] изменился, чтобы лучше подходить вам."))
	message_admins("[key_name_admin(chosen_one)] взял контроль над ([ADMIN_LOOKUPFLW(to_reset)])")
	to_reset.ghostize(FALSE)
	to_reset.PossessByPlayer(chosen_one.key)
	StartCooldown()
	return TRUE
