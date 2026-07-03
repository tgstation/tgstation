#define SLAM_COMBO "GH"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "DDH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = "Remember The Basics"
	smashes_tables = TRUE
	display_combos = TRUE
	/// Weakref to a mob we're currently restraining (with grab-grab combo)
	VAR_PRIVATE/datum/weakref/restraining_mob
	/// Probability of successfully blocking attacks while on throw mode
	var/block_chance = 75

/datum/martial_art/cqc/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(new_holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))

/datum/martial_art/cqc/deactivate_style(mob/living/remove_from)
	UnregisterSignal(remove_from, list(COMSIG_ATOM_ATTACKBY, COMSIG_LIVING_CHECK_BLOCK))
	return ..()

///Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/cqc/proc/on_attackby(mob/living/cqc_user, obj/item/attack_weapon, mob/attacker, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(attack_weapon, /obj/item/melee/touch_attack))
		return
	if(!can_use(cqc_user))
		return
	cqc_user.visible_message(
		span_danger("[cqc_user.declent_ru(NOMINATIVE)] выворачивает руку [attacker.declent_ru(ACCUSATIVE)], перенаправляя [attack_weapon.declent_ru(ACCUSATIVE)] в сторону [genderize_ru(attacker.gender, "атакующего", "атакующей", "атакующего", "атакующих")]!"),
		span_userdanger("Стараясь избежать [attack_weapon.declent_ru(GENITIVE)] [attacker.declent_ru(ACCUSATIVE)], вы выкручиваете [attacker.ru_p_them()] руку, направляя оружие обратно в [attacker.ru_p_theirs()]!"),
	)
	var/obj/item/melee/touch_attack/touch_weapon = attack_weapon
	var/datum/action/cooldown/spell/touch/touch_spell = touch_weapon.spell_which_made_us?.resolve()
	if(!touch_spell)
		return
	INVOKE_ASYNC(touch_spell, TYPE_PROC_REF(/datum/action/cooldown/spell/touch, do_hand_hit), touch_weapon, attacker, attacker)
	return COMPONENT_NO_AFTERATTACK

/datum/martial_art/cqc/proc/check_block(mob/living/cqc_user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	SIGNAL_HANDLER

	if(!can_use(cqc_user) || !cqc_user.throw_mode || INCAPACITATED_IGNORING(cqc_user, INCAPABLE_GRAB))
		return NONE
	if(attack_type == PROJECTILE_ATTACK)
		return NONE

	var/blocking_text = "блокируете"
	var/blocking_text_s = "блокирует"
	var/potential_block_chance = block_chance

	if(attack_type == OVERWHELMING_ATTACK)
		blocking_text = "уклоняетесь"
		blocking_text_s = "уклоняется"
		potential_block_chance = clamp(round(potential_block_chance / (attack_type == OVERWHELMING_ATTACK ? 2 : 1), 1), 0, 100)

	if(!prob(potential_block_chance))
		return NONE

	var/mob/living/attacker = GET_ASSAILANT(hitby)
	if(istype(attacker) && cqc_user.Adjacent(attacker))
		cqc_user.visible_message(
			span_danger("[capitalize(cqc_user.declent_ru(NOMINATIVE))] [blocking_text_s] [attacker] и выкручивает руку [attacker.declent_ru(GENITIVE)] за [attacker.ru_p_them()] спиной!"),
			span_userdanger("Вы [blocking_text] [attack_text]!"),
		)
		attacker.Stun(4 SECONDS)
	else
		cqc_user.visible_message(
			span_danger("[capitalize(cqc_user.declent_ru(NOMINATIVE))] [blocking_text_s] [attack_text]!"),
			span_userdanger("Вы [blocking_text] [attack_text]!"),
		)
	return SUCCESSFUL_BLOCK


/datum/martial_art/cqc/reset_streak(mob/living/new_target)
	if(!IS_WEAKREF_OF(new_target, restraining_mob))
		restraining_mob = null
	return ..()

/datum/martial_art/cqc/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, SLAM_COMBO))
		reset_streak()
		return Slam(attacker, defender)
	if(findtext(streak, KICK_COMBO))
		reset_streak()
		return Kick(attacker, defender)
	if(findtext(streak, RESTRAIN_COMBO))
		reset_streak()
		return Restrain(attacker, defender)
	if(findtext(streak, PRESSURE_COMBO))
		reset_streak()
		return Pressure(attacker, defender)
	if(findtext(streak, CONSECUTIVE_COMBO))
		reset_streak()
		return Consecutive(attacker, defender)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/attacker, mob/living/defender)
	if(defender.body_position != STANDING_UP)
		return FALSE

	attacker.do_attack_animation(defender)
	defender.visible_message(
		span_danger("[attacker.declent_ru(NOMINATIVE)] швыряет [defender.declent_ru(ACCUSATIVE)] на землю!"),
		span_userdanger("[capitalize(attacker)] швыряет вас на землю!"),
		span_hear("Вы слышите противный звук удара по телу!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("Вы швыряете [defender.declent_ru(ACCUSATIVE)] на землю!"))
	playsound(attacker, 'sound/items/weapons/slam.ogg', 50, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.Paralyze(12 SECONDS)
	log_combat(attacker, defender, "slammed (CQC)")
	return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/attacker, mob/living/defender)
	if(defender.stat != CONSCIOUS)
		return FALSE

	attacker.do_attack_animation(defender)
	if(defender.body_position == LYING_DOWN && !defender.IsUnconscious() && defender.get_stamina_loss() >= 100)
		log_combat(attacker, defender, "knocked out (Head kick)(CQC)")
		defender.visible_message(
			span_danger("[attacker.declent_ru(NOMINATIVE)] пинает голову [defender.declent_ru(GENITIVE)], выводя [defender.ru_p_them()] из сознания!"),
			span_userdanger("Вы потеряли сознание после пинка [attacker.declent_ru(GENITIVE)]!"),
			span_hear("Вы слышите противный звук удара по телу!"),
			null,
			attacker,
		)
		to_chat(attacker, span_danger("Вы пинаете голову [defender.declent_ru(GENITIVE)], выводя [defender.ru_p_them()] из сознания!"))
		playsound(attacker, 'sound/items/weapons/genhit1.ogg', 50, TRUE, -1)

		var/helmet_protection = defender.run_armor_check(BODY_ZONE_HEAD, MELEE)
		defender.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, helmet_protection)
		defender.apply_effect(10 SECONDS, EFFECT_UNCONSCIOUS, helmet_protection)
		defender.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15, 150)

	else
		defender.visible_message(
			span_danger("[capitalize(attacker.declent_ru(NOMINATIVE))] отбрасывает [defender.declent_ru(ACCUSATIVE)] назад!"),
			span_userdanger("Вы были отброшены [attacker.declent_ru(INSTRUMENTAL)]!"),
			span_hear("Вы слышите противный звук удара по телу!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("Вы отбрасываете [defender.declent_ru(ACCUSATIVE)] назад!"))
		playsound(attacker, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
		defender.throw_at(throw_target, 1, 14, attacker)
		defender.apply_damage(10, attacker.get_attack_type())
		if(defender.body_position == LYING_DOWN && !defender.IsUnconscious())
			defender.adjust_stamina_loss(45)
		log_combat(attacker, defender, "kicked (CQC)")

	return TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender)
	log_combat(attacker, defender, "pressured (CQC)")
	defender.visible_message(
		span_danger("[attacker.declent_ru(NOMINATIVE)] бьёт [defender.declent_ru(ACCUSATIVE)] в шею!"),
		span_userdanger("Вас бьёт в шею [attacker.declent_ru(NOMINATIVE)]!"),
		span_hear("Вы слышите противный звук удара по телу!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("Вы бьёте [defender.declent_ru(ACCUSATIVE)] в шею!"))
	defender.adjust_stamina_loss(60)
	playsound(attacker, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/attacker, mob/living/defender)
	if(restraining_mob?.resolve())
		return FALSE
	if(defender.stat != CONSCIOUS)
		return FALSE

	log_combat(attacker, defender, "restrained (CQC)")
	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] берёт [defender.declent_ru(ACCUSATIVE)] в захват!"),
		span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] берёт вас в захват!"),
		span_hear("Вы слышите шарканье и приглушенный стон!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("Вы берёте [defender.declent_ru(ACCUSATIVE)] в захват!"))
	defender.adjust_stamina_loss(20)
	defender.Stun(10 SECONDS)
	restraining_mob = WEAKREF(defender)
	addtimer(VARSET_CALLBACK(src, restraining_mob, null), 5 SECONDS, TIMER_UNIQUE)
	return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/attacker, mob/living/defender)
	if(defender.stat != CONSCIOUS)
		return FALSE

	attacker.do_attack_animation(defender)
	log_combat(attacker, defender, "consecutive CQC'd (CQC)")
	defender.visible_message(
		span_danger("[attacker.declent_ru(NOMINATIVE)] последовательно наносит удары в живот, шею и спину [defender.declent_ru(DATIVE)]."), \
		span_userdanger("Вы чувствуете, как [attacker.declent_ru(NOMINATIVE)] наносит последовательные удары в ваш живот, шею и спину!"),
		span_hear("Вы слышите противный звук удара по телу!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("Вы наносите последовательные удары по животу, шее и спине [defender.declent_ru(DATIVE)]!"))
	playsound(defender, 'sound/items/weapons/cqchit2.ogg', 50, TRUE, -1)
	var/obj/item/held_item = defender.get_active_held_item()
	if(held_item && defender.temporarilyRemoveItemFromInventory(held_item))
		attacker.put_in_hands(held_item)
	defender.adjust_stamina_loss(50)
	defender.apply_damage(25, attacker.get_attack_type())
	return TRUE

/datum/martial_art/cqc/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender)
		return MARTIAL_ATTACK_INVALID
	if(defender.check_block(attacker, 0, attacker.declent_ru(ACCUSATIVE), UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	if(check_streak(attacker, defender)) //if a combo is made no grab upgrade is done
		return MARTIAL_ATTACK_SUCCESS
	if(attacker.body_position == LYING_DOWN)
		return MARTIAL_ATTACK_INVALID

	var/old_grab_state = attacker.grab_state
	defender.grabbedby(attacker, TRUE)
	if(old_grab_state == GRAB_PASSIVE)
		defender.drop_all_held_items()
		attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
		log_combat(attacker, defender, "grabbed", addition="aggressively")
		defender.visible_message(
			span_warning("[attacker.declent_ru(NOMINATIVE)] яростно хватает [defender.declent_ru(ACCUSATIVE)]!"),
			span_userdanger("Вас яростно хватает [attacker.declent_ru(NOMINATIVE)]!"),
			span_hear("Вы слышите звуки яростной борьбы!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("Вы яростно хватаете [defender.declent_ru(ACCUSATIVE)]!"))
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/cqc/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', 100)
			defender.visible_message(
				span_danger("[attacker.declent_ru(NOMINATIVE)] сворачивает шею [defender.declent_ru(DATIVE)]!"),
				span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] [genderize_ru(attacker.gender,"свернул","свернула","свернуло","свернули")] вашу шею!"),
				span_hear("Вы слышите мерзкий хруст!"),
				ignored_mobs = attacker
			)
			to_chat(attacker, span_danger("Одним быстрым движением вы сворачиваете шею [defender.declent_ru(GENITIVE)]!"))
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	if(defender.check_block(attacker, 10, attacker.declent_ru(ACCUSATIVE), UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	if(attacker.resting && defender.stat != DEAD && defender.body_position == STANDING_UP)
		defender.visible_message(
			span_danger("[attacker.declent_ru(NOMINATIVE)] делает подсечку [defender.declent_ru(DATIVE)]!"),
			span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] делает вам подсечку!"),
			span_hear("Вы слышите противный звук удара по телу!"),
			null,
			attacker,
		)
		to_chat(attacker, span_danger("Вы делаете подсечку [defender.declent_ru(DATIVE)]!"))
		playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		attacker.do_attack_animation(defender)
		defender.apply_damage(10, BRUTE)
		defender.Knockdown(5 SECONDS)
		log_combat(attacker, defender, "sweeped (CQC)")
		reset_streak()
		return MARTIAL_ATTACK_SUCCESS

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	attacker.do_attack_animation(defender)
	var/picked_hit_type = pick("CQC", "Большой Босс")
	var/bonus_damage = 13
	if(defender.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = pick("пинать", "топтать")
	defender.apply_damage(bonus_damage, BRUTE)

	playsound(defender, (picked_hit_type == "пинать" || picked_hit_type == "топтать") ? 'sound/items/weapons/cqchit2.ogg' : 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
	switch(picked_hit_type)
		if ("пинать")
			defender.visible_message(
				span_danger("[attacker.declent_ru(NOMINATIVE)] пинает [defender.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] [genderize_ru(attacker.gender, "пнул", "пнула", "пнуло", "пнули")] вас!"),
				span_hear("Вы слышите противный звук удара по телу!"),
					COMBAT_MESSAGE_RANGE,
					attacker,
			)
			to_chat(attacker, span_danger("Вы пинаете [defender.declent_ru(ACCUSATIVE)]!"))

		if ("топтать")
			defender.visible_message(
				span_danger("[attacker.declent_ru(NOMINATIVE)] топчет [defender.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] [genderize_ru(attacker.gender,"растоптал","растоптала","растоптало","растоптали")] вас!"),
				span_hear("Вы слышите противный звук удара по телу!"),
				COMBAT_MESSAGE_RANGE,
				attacker,
			)
			to_chat(attacker, span_danger("Вы топчете [defender.declent_ru(ACCUSATIVE)]!"))
	log_combat(attacker, defender, "attacked ([picked_hit_type])(CQC)")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/cqc/disarm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, attacker.declent_ru(ACCUSATIVE), UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	if(IS_WEAKREF_OF(attacker.pulling, restraining_mob))
		log_combat(attacker, defender, "disarmed (CQC)", addition = "knocked out (CQC Chokehold)")
		defender.visible_message(
			span_danger("[attacker.declent_ru(NOMINATIVE)] берёт [defender.declent_ru(ACCUSATIVE)] на удушающий захват!"),
			span_userdanger("[capitalize(attacker.declent_ru(NOMINATIVE))] берёт вас на удушающий захват!"),
			span_hear("Вы слышите шарканье и приглушенный стон!"),
			null,
			attacker,
		)
		to_chat(attacker, span_danger("Вы берёте [defender.declent_ru(ACCUSATIVE)] в удушающий захват!"))
		defender.SetSleeping(40 SECONDS)
		restraining_mob = null
		if(attacker.grab_state < GRAB_NECK && !HAS_TRAIT(attacker, TRAIT_PACIFISM))
			attacker.setGrabState(GRAB_NECK)
		return MARTIAL_ATTACK_SUCCESS

	attacker.do_attack_animation(defender, ATTACK_EFFECT_DISARM)
	if(prob(65) && (defender.stat == CONSCIOUS || !defender.IsParalyzed() || !restraining_mob?.resolve()))
		var/obj/item/disarmed_item = defender.get_active_held_item()
		if(disarmed_item && defender.temporarilyRemoveItemFromInventory(disarmed_item))
			defender.dropItemToGround(disarmed_item)
			if(isturf(disarmed_item.loc)) //If it fell on the ground we can take it, otherwise assume it's attached to something.
				attacker.put_in_hands(disarmed_item)
			else
				disarmed_item = null
		else
			disarmed_item = null

		defender.visible_message(
			span_danger("[attacker.declent_ru(NOMINATIVE)] бьёт [defender.declent_ru(ACCUSATIVE)] в челюсть рукой[disarmed_item ? ", выбивая из [defender.ru_p_them()] рук [disarmed_item.declent_ru(ACCUSATIVE)]" : ""]!"),
			span_userdanger("[attacker.declent_ru(NOMINATIVE)] бьёт вам в челюсть,[disarmed_item ? " выбивая из ваших рук [disarmed_item.declent_ru(ACCUSATIVE)] и" : ""] дезориентируя вас!"),
			span_hear("Вы слышите противный звук удара по телу!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("Вы бьёте в челюсть [defender.declent_ru(ACCUSATIVE)],[disarmed_item ? " выбивая из [defender.ru_p_them()] рук [disarmed_item.declent_ru(ACCUSATIVE)] и" : ""] оставляя [defender.ru_p_them()] дезориентированным!"))
		playsound(defender, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
		defender.set_jitter_if_lower(4 SECONDS)
		defender.apply_damage(5, attacker.get_attack_type())
		log_combat(attacker, defender, "disarmed (CQC)", addition = disarmed_item ? "(disarmed of [disarmed_item])" : null)
		return MARTIAL_ATTACK_SUCCESS

	defender.visible_message(
		span_danger("У [attacker.declent_ru(NOMINATIVE)] не выходит разоружить [defender.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(attacker.declent_ru(DATIVE))] почти удалось вас разоружить!"),
		span_hear("Вы слышите свист!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_warning("У вас не выходит разоружить [defender.declent_ru(ACCUSATIVE)]!"))
	playsound(defender, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "failed to disarm (CQC)")
	return MARTIAL_ATTACK_FAIL


/datum/martial_art/cqc/get_style_help()
	. = list()

	. += "<b><i>Вы пытаетесь вспомнить некоторые основы CQC.</i></b>"

	. += "[span_notice("Бросок")]: Захват, Удар. Впечатайте оппонента в землю, опрокидывая его."
	. += "[span_notice("CQC пинок")]: Удар, Удар. Отбросьте оппонента от себя. Отбрасывание оглушённого противника наносит урон выносливости."
	. += "[span_notice("Сдерживание")]: Захват, Захват. Удерживает в захвате и обезоруживает оппонента, чтобы вырубить его удушающим приёмом."
	. += "[span_notice("Давление")]: Толчок, Захват. Значительный урон по выносливости."
	. += "[span_notice("Последовательный CQC")]: Толчок, Толчок, Удар. Основной атакующий приём, наносящий огромный урон и значительный урон выносливости."

	. += "<b><i>В дополнение, включив режим броска при нападении, вы переходите в режим активной защиты, где у вас есть шанс заблокировать удары противника, а иногда даже провести контратаку.</i></b>"
	return .

///Subtype of CQC. Only used for the chef.
/datum/martial_art/cqc/under_siege
	name = "Кулинария близкого контакта"
	///List of all areas that CQC will work in, defaults to Kitchen.
	var/list/kitchen_areas = list(/area/station/service/kitchen)

/// Refreshes the valid areas from the cook's mapping config, adding areas in config to the list of possible areas.
/datum/martial_art/cqc/under_siege/proc/refresh_valid_areas()
	var/list/additional_cqc_areas = CHECK_MAP_JOB_CHANGE(JOB_COOK, "additional_cqc_areas")
	if(!additional_cqc_areas)
		return

	if(!islist(additional_cqc_areas))
		stack_trace("Incorrect CQC area format from mapping configs. Expected /list, got: \[[additional_cqc_areas.type]\]")
		return

	for(var/path_as_text in additional_cqc_areas)
		var/path = text2path(path_as_text)
		if(!ispath(path, /area))
			stack_trace("Invalid path in mapping config for chef CQC: \[[path_as_text]\]")
			continue

		kitchen_areas |= path

/// Limits where the chef's CQC can be used to only whitelisted areas.
/datum/martial_art/cqc/under_siege/can_use(mob/living/martial_artist)
	if(!is_type_in_list(get_area(martial_artist), kitchen_areas))
		return FALSE
	return ..()

#undef SLAM_COMBO
#undef KICK_COMBO
#undef RESTRAIN_COMBO
#undef PRESSURE_COMBO
#undef CONSECUTIVE_COMBO
