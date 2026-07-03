/datum/heretic_knowledge_tree_column/blade
	route = PATH_BLADE
	ui_bgr = "node_blade"
	complexity = "Высокая"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Клинка, как следует из названия.",
		"Вы очень компетентны в разрезании своих противников на кусочки.",
		"Выбирайте этот путь, если хотите сражаться и быть лучшим в этом деле.",
	)
	pros = list(
		"Способен блокировать атаки противника и наносить ответные удары.",
		"Быстро наносит урон с помощью пары клинков и направленных ударов.",
		"Высокая устойчивость к оглушению и сбиванию с ног.",
		"Особо смертоносный боец в прямом бою с одиночным противником.",
	)
	cons = list(
		"Требует высокого уровня мастерства.",
		"Без клинков путь теряет большую часть своей боевой мощи.",
		"Недостаточно возможностей для передвижения.",
		"Отсутствие защиты от воздействия окружающей среды.",
	)
	tips = list(
		"Ваша «Хватка Мансуса» оглушит противника, если он будет атакован сзади или в положении лежа. Это также заблокирует его в комнате, в которой он находится, до тех пор, пока метка не будет взорвана. Активация метки даст вам вращающийся вокруг вас нож, который защитит вас от одной рукопашной или дальней атаки.",
		"У вас самый высокий лимит лезвий из всех путей (всего 4). Но поскольку для их изготовления требуется серебро или титан, у вас может возникнуть нехватка ингредиентов, если шахтёры не выполняют свою работу. Если вам нужны материалы - стены и сиденья шаттлов являются источником титана, а операционные столы - источником серебра.",
		"Вы в значительной степени полагаетесь на ближний бой с противниками. Скользкий пол, метательные болы и медвежьи капканы — ваши злейшие враги. Вы можете противодействовать подскальзыванию, сделав «Поножи Пророка», или снять оковы с помощью «Пепельного прохода».",
		"«Реорганизация» снимет с вас оглушение и сбитие с ног, но не позволит вести себя агрессивно на время действия.",
		"С усиленными клинками ваша атакующая сила значительно возрастает. Вы сможете сражаться с клинками в обеих руках и усиливать их, активируя «Хватка Мансуса», держа их в руках. Ваши клинки также наносят дополнительный урон объектам, силиконам и мехам.",
		"Поддержание хорошего нападения также создает хорошую защиту. С помощью вращающихся лезвий вы можете дополнительно блокировать атаки противника.",
		"С помощью «Ярость Стали» вы можете не только изготовить несколько ножей для защиты, но и бросать их, щелкнув пустой рукой. Это даст вам силу в дальнем бою в случае необходимости.",
		"Используйте «Волк Среди Овец» с осторожностью. У этой способности не только значительное время восстановления, но она также вооружает всех, кто попал под её действие, собственными клинками. Используйте её либо в качестве защиты последнего шанса, либо когда вы знаете, что у вас преимущество и вам нужно его усилить. Только не пытайтесь бежать из зоны действия арены, не уронив в критическое состояние кого-нибудь.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	knowledge_tier1 = /datum/heretic_knowledge/spell/realignment
	guaranteed_side_tier1 = /datum/heretic_knowledge/greaves_of_the_prophet
	knowledge_tier2 = /datum/heretic_knowledge/duel_stance
	guaranteed_side_tier2 = /datum/heretic_knowledge/essence
	robes = /datum/heretic_knowledge/armor/blade
	knowledge_tier3 = /datum/heretic_knowledge/spell/furious_steel
	guaranteed_side_tier3 = /datum/heretic_knowledge/rune_carver
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	knowledge_tier4 = /datum/heretic_knowledge/spell/wolves_among_sheep
	ascension = /datum/heretic_knowledge/ultimate/blade_final

/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "Совершенство Остроты"
	desc = "Открывает перед вами Путь клинков. \
		Позволяет трансмутировать нож с одним слитком серебра или титаниума для создания Закалённого клинка. \
		Одновременно можно иметь не более четырех."
	gain_text = "Наши великие предки ковали мечи и практиковали спарринги накануне великих сражений."
	required_atoms = list(
		/obj/item/knife = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	limit = 4 // It's the blade path, it's a given
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"
	mark_type = /datum/status_effect/eldritch/blade
	eldritch_passive = /datum/status_effect/heretic_passive/blade

/datum/heretic_knowledge/limited_amount/starting/base_blade/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	target.balloon_alert(source, "удар в спину!")
	playsound(target, 'sound/items/weapons/guillotine.ogg', 100, TRUE)

/datum/heretic_knowledge/limited_amount/starting/base_blade/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(istype(blade_mark))
		var/area/to_lock_to = get_area(target)
		blade_mark.locked_to = to_lock_to
		to_chat(target, span_hypnophrase("Потусторонняя сила заставляет вас оставаться в [get_area_name(to_lock_to)]!"))
	return blade_mark

/datum/heretic_knowledge/limited_amount/starting/base_blade/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return
	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)

/datum/heretic_knowledge/spell/realignment
	name = "Реорганизация"
	desc = "Дарует вам заклинание «Реорганизация», которое быстро и на короткое время перестраивает ваше тело. \
		Во время этого процесса вы будете быстро восстанавливать стамину и быстро восстанавливаться после оглушения, однако вы не сможете атаковать. \
		Это заклинание можно применять подряд, но при этом увеличивается время его перезарядки."
	gain_text = "В шквале смертей он обрел мир внутри себя. Несмотря на неодолимые шансы, он ступал вперед."
	action_to_add = /datum/action/cooldown/spell/realignment
	cost = 2

/// The amount of blood flow reduced per level of severity of gained bleeding wounds for Stance of the Torn Champion.
#define BLOOD_FLOW_PER_SEVEIRTY -1

/datum/heretic_knowledge/duel_stance
	name = "Стойка истерзанного чемпиона"
	desc = "Повышает устойчивость к потере крови при ранениях и даёт иммунитет к расчленению ваших конечностей. \
		Кроме того, при уровне здоровья ниже 50% от максимального, \
		вы становитесь более устойчивыми к получению ранений и замедлению."
	gain_text = "Однажды, он остался один среди тел своих бывших товарищей, залитый чужой кровью. \
		У него не было ни соперников, ни равных, ни цели."
	cost = 2
	research_tree_icon_path = 'icons/effects/blood.dmi'
	research_tree_icon_state = "suitblood"
	research_tree_icon_dir = SOUTH
	drafting_tier = 5
	/// Whether we're currently in duelist stance, gaining certain buffs (low health)
	var/in_duelist_stance = FALSE

/datum/heretic_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	ADD_TRAIT(user, TRAIT_NODISMEMBER, type)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_CARBON_GAIN_WOUND, PROC_REF(on_wound_gain))
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

	on_health_update(user) // Run this once, so if the knowledge is learned while hurt it activates properly

/datum/heretic_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, type)
	if(in_duelist_stance)
		user.remove_traits(list(TRAIT_HARDLY_WOUNDED), type)
		if(isliving(user))
			var/mob/living/living_mob = user
			living_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)

	UnregisterSignal(user, list(COMSIG_ATOM_EXAMINE, COMSIG_CARBON_GAIN_WOUND, COMSIG_LIVING_HEALTH_UPDATE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/held_item = source.get_active_held_item()
	if(in_duelist_stance)
		examine_list += span_warning("[source] looks unnaturally poised[held_item?.force >= 15 ? " and ready to strike out":""].")

/datum/heretic_knowledge/duel_stance/proc/on_wound_gain(mob/living/source, datum/wound/gained_wound, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(gained_wound.blood_flow <= 0)
		return

	gained_wound.adjust_blood_flow(gained_wound.severity * BLOOD_FLOW_PER_SEVEIRTY)

/datum/heretic_knowledge/duel_stance/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		source.balloon_alert(source, "exited duelist stance")
		in_duelist_stance = FALSE
		source.remove_traits(list(TRAIT_HARDLY_WOUNDED), type)
		source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)
		return

	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		source.balloon_alert(source, "entered duelist stance")
		in_duelist_stance = TRUE
		ADD_TRAIT(source, TRAIT_HARDLY_WOUNDED, type)
		source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)
		return

#undef BLOOD_FLOW_PER_SEVEIRTY

/datum/heretic_knowledge/armor/blade
	name = "Разбитые доспехи"
	desc = "Позволяет трансмутировать стол (или костюм), маску и лист титана или серебра для создания Разбитых доспехов. \
			Обеспечивает устойчивость к ударам дубинкой и изоляцию от электричества при ношении. \
			Выступает в роли фокуса, находясь в капюшоне."
	gain_text = "Разносящаяся эхом во все стороны какофония насилия окружает меня. \
				Даже после того, как стальной панцирь Чемпиона был разорван, каждая его часть по-прежнему жаждет предназначения, стремясь перехватить невидимых или воображаемых нападающих."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade)
	research_tree_icon_state = "blade_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)

/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Волк среди овец"
	desc = "Изменяет материю реальности, создавая магическую арену, недоступную для посторонних, \
		все участники находятся в ловушке и защищены от любых форм контроля толпы или опасностей окружающей среды; \
		попавшим в ловушку участникам выдается клинок, и они не могут выйти или телепортироваться, пока не нанесут критический удар. \
		Критические удары частично восстанавливают здоровье еретика."
	gain_text = "Тени расползаются по комнате, отбрасывая силуэты на каждый стул, стол \
		и вырисовываются в фигуру еще одной предательской руки. \
		Я стал всеобщим врагом, и мне никогда не обрести покоя. \
		Я разрушил все связи и разорвал все союзы. В этой истине \
		теперь я знаю, как непрочно товарищество. Враги мои будут повсюду, каждый по частям."
	cost = 2
	action_to_add = /datum/action/cooldown/spell/wolves_among_sheep
	is_final_knowledge = TRUE

/datum/heretic_knowledge/blade_upgrade/blade
	name = "Усиление клинков"
	desc = "Атакуя кого-либо с услиленными клинками в обеих руках, \
		теперь вы будете наносить удар обоими клинками сразу, нанося две атаки в быстрой последовательности. \
		Второй удар будет немного слабее. \
		Ваша «Хватка Мансуса» может слиться с клинком, а сами клинки более эффективны против структур."
	gain_text = "Я нашел его рассеченным на две части, половинки сцепились в дуэли без конца; \
		шквал клинков, но ни один из них не попал в цель, ибо Чемпион был неукротим."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1

/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_blade_equipped))

/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST, COMSIG_MOB_EQUIPPED_ITEM))

///Tries to infuse our held blade with our mansus grasp
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_grasp_cast(mob/living/carbon/cast_on)
	SIGNAL_HANDLER

	var/held_item = cast_on.get_active_held_item()
	if(!istype(held_item, /obj/item/melee/sickly_blade/dark))
		return NONE
	var/obj/item/melee/sickly_blade/dark/held_blade = held_item
	if(held_blade.infused)
		return NONE
	held_blade.infused = TRUE
	held_blade.update_appearance(UPDATE_ICON)

	//Infuse our off-hand blade just so it's nicer visually
	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_held_item()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)
	cast_on.update_held_items()

	return COMPONENT_CAST_HANDLESS

/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_held_item()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return
	// If our off-hand is the blade that's attacking,
	// quit out now to avoid an infinite stab combo
	if(off_hand == blade)
		return

	// Give it a short delay (for style, also lets people dodge it I guess)
	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)

/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return
	// Sanity to ensure that the blade we're delivering an offhand attack with is ACTUALLY our offhand
	if(blade != source.get_inactive_held_item())
		return
	// And we easily could've moved away
	if(!source.Adjacent(target))
		return

	// Check if we need to recaclulate our offhand force
	// This is just so we don't run this block every attack, that's wasteful
	if(last_weapon_force != blade.force)
		offand_force_decrement = 0
		// We want to make sure that the offhand blade increases their hits to crit by one, just about
		// So, let's do some quick math. Yes this'll be inaccurate if their mainhand blade is modified (whetstone), no I don't care
		// Find how much force we need to detract from the second blade
		var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
		while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
			if(offand_force_decrement + 2 > blade.force * 0.5) // But also cutting the force beyond half is absurd
				break

			offand_force_decrement += 2
			hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	// Perform the offhand attack
	blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))

///Modifies our blade demolition modifier so we can take down doors with it
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_equipped(mob/user, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(istype(equipped, /obj/item/melee/sickly_blade/dark))
		equipped.demolition_mod = 2.5

/datum/heretic_knowledge/spell/furious_steel
	name = "Ярость Стали"
	desc = "Дарует вам «Ярость Стали», заклинание с выбором цели. При его использовании вокруг вас появятся три \
		вращающихся клинка. Эти клинки защищают вас от всех атак, \
		но при использовании расходуются. Кроме того, вы можете использовать кнопку, чтобы выстрелить лезвиями \
		в цель, нанося урон и вызывая кровотечение."
	gain_text = "Не раздумывая, я взял нож павшего солдата и со всей силы метнул. Моя меткость оказалась верна! \
		Чемпион Растерзаний улыбнулся их первому вкусу агонии, и кивнув, их клинки стали моими собственными."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/furious_steel
	cost = 2

/datum/heretic_knowledge/ultimate/blade_final
	name = "Серебряный Вихрь"
	desc = "Ритуал вознесения Пути клинков. \
		Принесите 3 безголовых или со сломанным черепом трупа к руне трансмутации, чтобы завершить ритуал. \
		После завершения вы будете окружены постоянно восстанавливающимися вращающимися лезвиями. \
		Эти клинки защищают вас от всех атак, но расходуются при использовании. \
		Ваше заклинание «Ярость Стали» также будет перезаряжаться быстрее. \
		Кроме того, вы становитесь мастером боя, получая полный иммунитет к ранам и возможность снимать короткие оглушения. \
		Ваши Закаленные клинки наносят бонусный урон и исцеляют вас при атаке на часть нанесенного урона."
	gain_text = "Чемпион Растерзаний освобожден! Я стану воссоединенным клинком, и с моими более великими амбициями, \
		МНЕ НЕТ РАВНЫХ! ВИХРЬ ИЗ СТАЛИ И СЕРЕБРА НАДВИГАЕТСЯ НА НАС! УЗРИТЕ МОЁ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/blade_ascension
	announcement_text = "%SPOOKY% Мастер клинков %NAME%, ученик Чемпиона Растерзаний, вознесся! Их сталь — та, что рассечет реальность в серебряном шторме! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_blade.ogg'

/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return !sacrifice.get_bodypart(BODY_ZONE_HEAD) || HAS_TRAIT(sacrifice, TRAIT_HAS_CRANIAL_FISSURE)

/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	ADD_TRAIT(user, TRAIT_NEVER_WOUNDED, type)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, STATUS_EFFECT_PERMANENT, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 60 SECONDS)
	user.add_stun_absorption(
		source = name,
		message = span_warning("%EFFECT_OWNER throws off the stun!"),
		self_message = span_warning("You throw off the stun!"),
		examine_message = span_hypnophrase("%EFFECT_OWNER_THEYRE standing stalwartly."),
		// flashbangs are like 5-10 seoncds,
		// a banana peel is ~5 seconds, depending on botany
		// body throws and tackles are less than 5 seconds,
		// stun baton / stamcrit detracts no time,
		// and worst case: beepsky / tasers are 10 seconds.
		max_seconds_of_stuns_blocked = 45 SECONDS,
		delete_after_passing_max = FALSE,
		recharge_time = 2 MINUTES,
	)
	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.actions
	steel_spell?.cooldown_time /= 2

	var/mob/living/carbon/human/heretic = user
	heretic.physiology.knockdown_mod = 0.75 // Otherwise knockdowns would probably overpower the stun absorption effect.

/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(target == source)
		return

	// Turns your heretic blades into eswords, pretty much.
	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(
		damage = bonus_damage,
		damagetype = BRUTE,
		spread_damage = TRUE,
		wound_bonus = 5,
		sharpness = SHARP_EDGED,
		attack_direction = get_dir(source, target),
	)

	if(target.stat != DEAD)
		// And! Get some free healing for a portion of the bonus damage dealt.
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)
