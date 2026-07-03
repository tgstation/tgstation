
/obj/item/melee/sickly_blade
	name = "\improper sickly blade"
	desc = "Болезненно-зеленый полумесячный клинок, украшенный декоративным глазом. Вы чувствуете, что за вами наблюдают..."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"
	inhand_icon_state = "eldritch_blade"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	throwforce = 10
	wound_bonus = 5
	exposed_wound_bonus = 15
	toolspeed = 0.375
	demolition_mod = 0.8
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	armour_penetration = 35
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/after_use_message = ""
	/// Tracks how many times attack_self() is called so that breaking a blade while in an arena has to be intentional
	var/escape_attempts = 0
	/// Timer that resets your escape_attempts back to 0
	var/escape_timer

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!check_usability(user))
		return

	. += span_notice("Ты можешь разбить клинок, чтобы телепортироваться в случайное (в основном) безопасное место, <b>активировав его в руке</b>.")

/// Checks if the passed mob can use this blade without being stunned
/obj/item/melee/sickly_blade/proc/check_usability(mob/living/user)
	return IS_HERETIC_OR_MONSTER(user)

/obj/item/melee/sickly_blade/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(.)
		return .
	if(!check_usability(user))
		to_chat(user, span_danger("Ты чувствуешь, как импульс чужого интеллекта бьет по твоему разуму!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalyzed(5 SECONDS)
		return TRUE

	return .

/obj/item/melee/sickly_blade/attack_self(mob/user)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(heretic_datum?.unlimited_blades)
		return
	if(HAS_TRAIT(user, TRAIT_ELDRITCH_ARENA_PARTICIPANT))
		user.balloon_alert(user, "невозможно сбежать!")
		if(escape_attempts > 2)
			to_chat(user, span_hypnophrase(span_big("Трусливые овцы будут зарезаны!")))
			playsound(src, SFX_SHATTER, 70, TRUE)
			var/obj/item/bodypart/to_remove = user.get_active_hand()
			to_remove.dismember()
			deltimer(escape_timer)
			qdel(src)
			return
		escape_attempts++
		escape_timer = addtimer(CALLBACK(src, PROC_REF(reset_attempts)), 2 SECONDS, TIMER_STOPPABLE)
		return
	if(HAS_TRAIT(user, TRAIT_NO_TELEPORT))
		user.balloon_alert(user, "невозможно сломать!")
		return
	seek_safety(user)

/obj/item/melee/sickly_blade/proc/reset_attempts()
	escape_attempts = 0
	deltimer(escape_timer)

/// Attempts to teleport the passed mob to somewhere safe on the station, if they can use the blade.
/obj/item/melee/sickly_blade/proc/seek_safety(mob/user)
	var/turf/safe_turf = find_safe_turf(z, extended_safety_checks = TRUE)
	if(check_usability(user))
		if(do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user, span_warning("Когда вы разбиваете [declent_ru(ACCUSATIVE)], вы чувствуете, как порыв энергии проходит через ваше тело. [after_use_message]"))
		else
			to_chat(user, span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)], но ваша мольба остается без ответа."))
	else
		to_chat(user,span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)]."))
	playsound(src, SFX_SHATTER, 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)

/obj/item/melee/sickly_blade/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, interacting_with, src)
	return ITEM_INTERACT_BLOCKING

// Path of Rust's blade
/obj/item/melee/sickly_blade/rust
	name = "\improper rusted blade"
	desc = "Этот полумесячный клинок обветшал и заржавел. \
		И все же он кусается, разрывая плоть и кости зазубренными гнилыми зубами."
	icon_state = "rust_blade"
	inhand_icon_state = "rust_blade"
	after_use_message = "Ржавые холмы слышат ваш зов..."

// Path of Ash's blade
/obj/item/melee/sickly_blade/ash
	name = "\improper ashen blade"
	desc = "Расплавленный и необработанный кусок металла, искореженный в труху и шлак. \
		Несделанный, он стремится быть большим, чем он является, и срезает тупым краем раны, заполняя их сажей."
	icon_state = "ash_blade"
	inhand_icon_state = "ash_blade"
	after_use_message = "Ночной дозорный слышит ваш зов..."
	resistance_flags = FIRE_PROOF

// Path of Flesh's blade
/obj/item/melee/sickly_blade/flesh
	name = "\improper bloody blade"
	desc = "Полумесячный клинок, рожденный из искореженного существа. \
		Он стремится передать другим те страдания, которые он пережил от своего ужасного происхождения."
	icon_state = "flesh_blade"
	inhand_icon_state = "flesh_blade"
	after_use_message = "Маршал слышит ваш зов..."

/obj/item/melee/sickly_blade/flesh/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)

	AddComponent(
		/datum/component/bloody_spreader,\
		blood_dna = list("Alien DNA" = get_blood_type(BLOOD_TYPE_XENO)),\
	)

// Path of Void's blade
/obj/item/melee/sickly_blade/void
	name = "\improper void blade"
	desc = "Лишенный всякой субстанции, этот клинок отражает небытие. \
		Это настоящее отображение чистоты, и хаоса, который наступает после его применения."
	icon_state = "void_blade"
	inhand_icon_state = "void_blade"
	after_use_message = "Аристократ слышит ваш зов..."

// Path of the Blade's... blade.
// Opting for /dark instead of /blade to avoid "sickly_blade/blade".
/obj/item/melee/sickly_blade/dark
	name = "\improper sundered blade"
	desc = "Галантный клинок, раздробленный и разорванный. \
		Клинок режет яростно. Серебряные шрамы навечно связывают его с темной целью."
	icon_state = "dark_blade"
	base_icon_state = "dark_blade"
	inhand_icon_state = "dark_blade"
	after_use_message = "Разорванный чемпион слышит ваш зов..."
	///If our blade is currently infused with the mansus grasp
	var/infused = FALSE

/obj/item/melee/sickly_blade/dark/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!infused || target == user || !isliving(target) || QDELETED(target))
		return
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/mob/living/living_target = target
	if(!heretic_datum)
		return

	// Apply our heretic mark
	var/datum/heretic_knowledge/limited_amount/starting/base_blade/mark_to_apply = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_blade)
	if(!mark_to_apply)
		return
	mark_to_apply.create_mark(user, living_target)
	infused = FALSE
	update_appearance(UPDATE_ICON)
	user.update_held_items()

	if(!check_behind(user, living_target))
		return
	// We're officially behind them, apply effects
	living_target.AdjustParalyzed(1.5 SECONDS)
	living_target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	living_target.balloon_alert(user, "backstab!")
	playsound(living_target, 'sound/items/weapons/guillotine.ogg', 100, TRUE)

/obj/item/melee/sickly_blade/dark/dropped(mob/user, silent)
	. = ..()
	if(infused)
		infused = FALSE
		update_appearance(UPDATE_ICON)

/obj/item/melee/sickly_blade/dark/update_icon_state()
	. = ..()
	if(infused)
		icon_state = base_icon_state + "_infused"
		inhand_icon_state = base_icon_state + "_infused"
	else
		icon_state = base_icon_state
		inhand_icon_state = base_icon_state

// Path of Cosmos's blade
/obj/item/melee/sickly_blade/cosmic
	name = "\improper cosmic blade"
	desc = "Соринка небесного резонанса, сформированная в клинок, сотканный из звезд. \
		Радужный изгнанник, прокладывающий лучистые тропы, отчаянно стремящихся к объединению."
	icon_state = "cosmic_blade"
	inhand_icon_state = "cosmic_blade"
	after_use_message = "Звездочет слышит ваш зов..."

// Path of Knock's blade
/obj/item/melee/sickly_blade/lock
	name = "\improper key blade"
	desc = "Клинок и ключ, ключ к чему? \
		Какие великие врата он открывает?"
	icon_state = "key_blade"
	inhand_icon_state = "key_blade"
	after_use_message = "Управляющий слышит ваш зов..."
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1.3

// Path of Moon's blade
/obj/item/melee/sickly_blade/moon
	name = "\improper moon blade"
	desc = "Клинок из железа, отражающий правду земли: Все однажды присоединятся к труппе. \
		Труппе приносящей радость, вырезающая улыбки на их лицах, хотят они того или нет."
	icon_state = "moon_blade"
	inhand_icon_state = "moon_blade"
	after_use_message = "Луна слышит твой зов..."

// Path of Nar'Sie's blade
// What!? This blade is given to cultists as an altar item when they sacrifice a heretic.
// It is also given to the heretic themself if they sacrifice a cultist.
/obj/item/melee/sickly_blade/cursed
	name = "\improper cursed blade"
	desc = "Тёмный клинок, проклятый пускать кровь вечность. В постоянной борьбе между потусторонним и тьмой, он вынужден признавать своим хозяином любого, кто им владеет. \
		С роговицы его глаза на землю бесконечно капает кровь, но его пронзительный взгляд остается прикованным к вам."
	force = 25
	throwforce = 15
	block_chance = 35
	wound_bonus = 25
	exposed_wound_bonus = 15
	armour_penetration = 35
	icon_state = "cursed_blade"
	inhand_icon_state = "cursed_blade"

/obj/item/melee/sickly_blade/cursed/Initialize(mapload)
	. = ..()

	var/examine_text = {"«Позволяет начертать кровавые руны культа Нар'Си».
	Сочетание потусторонней силы и могущества Нар'Си значительно увеличивает скорость начертания рун,
	а жестокая мощь клинка делает его удары сильнее обычного.\n
	<b>Культисты могут разбить его прямо в руке (ПКМ), мгновенно переместившись в относительно безопасное место.<b>"}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text), turfs_that_boost_us = /turf) // Always fast to draw!

/obj/item/melee/sickly_blade/cursed/attack_self_secondary(mob/user)
	seek_safety(user, TRUE)

/obj/item/melee/sickly_blade/cursed/seek_safety(mob/user, secondary_attack = FALSE)
	if(IS_CULTIST(user) && !secondary_attack)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/cursed/check_usability(mob/living/user)
	if(IS_HERETIC_OR_MONSTER(user) || IS_CULTIST(user))
		return TRUE
	if(prob(15))
		to_chat(user, span_cult_large(pick("\"Нетронутый разум? Забавно.\"", "\" Я думаю, что не стоит прилагать усилий, чтобы остановить тебя.\"", "\"Продолжай. Мне всё равно.\"", "\"Скоро, ты будешь принадлежать мне.\"")))
		user.apply_damage(5, BURN, user.get_active_hand())
		playsound(src, SFX_SEAR, 25, TRUE)
		to_chat(user, span_danger("Ваша рука обжигается.")) // Nar nar might not care but their essence still doesn't like you
	else if(prob(15))
		to_chat(user, span_big(span_hypnophrase("LW'NAFH'NAHOR UH'ENAH'YMG EPGOKA AH NAFL MGEMPGAH'EHYE")))
		to_chat(user, span_danger("Ужасные, неразборчивые выкрики переполняют ваш разум!"))
		user.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15) // This can kill you if you ignore it
	return TRUE

/obj/item/melee/sickly_blade/cursed/equipped(mob/user, slot)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		after_use_message = "Мансус услышал твой зов..."
	else if(IS_CULTIST(user))
		after_use_message = "Нар'Си услышал твой зов..."
	else
		after_use_message = null

/obj/item/melee/sickly_blade/cursed/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return NONE

	// Can only carve runes with it if off combat mode.
	if(isopenturf(target) && !user.combat_mode)
		heretic_datum.try_draw_rune(user, target, drawing_time = 14 SECONDS) // Faster than pen, slower than cicatrix
		return ITEM_INTERACT_BLOCKING
	return NONE

/obj/item/melee/sickly_blade/cursed/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(attack_type == OVERWHELMING_ATTACK)
		return FALSE
	return ..()

// Weaker blade variant given to people so they can participate in the heretic arena spell
/obj/item/melee/sickly_blade/training
	name = "\improper imperfect blade"
	desc = "A blade given to those who cannot accept the truth, out of pity. \
		May it act as a blessing in the short time it remains alongside you."
	force = 17
	armour_penetration = 0

/obj/item/melee/sickly_blade/training/check_usability(mob/living/user)
	return TRUE // If you can hold this, you can use it
