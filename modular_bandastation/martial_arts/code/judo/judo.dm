/datum/martial_art/judo
	name = "Corporate Judo"
	id = "corporate judo"
	help_verb = /mob/living/proc/judo_help
	display_combos = TRUE
	max_streak_length = 12
	combo_timer = 15 SECONDS
	VAR_PRIVATE/datum/action/discombobulate/discombobulate

/datum/martial_art/judo/New()
	. = ..()
	discombobulate = new(src)

/datum/martial_art/judo/Destroy()
	discombobulate = null
	return ..()

/datum/martial_art/judo/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(holder, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(check_baton))
	for(var/obj/item/item in new_holder.held_items)
		check_baton(equipped_item = item, slot = ITEM_SLOT_HANDS)

	to_chat(new_holder, span_userdanger("Наниты, содержащиеся в поясе, наделяют вас мастерством обладателя черного пояса по корпоративному дзюдо!"))
	to_chat(new_holder, span_notice("Вы можете посмотреть приёмы во вкладке IC."))
	discombobulate.Grant(new_holder)

/datum/martial_art/judo/deactivate_style(mob/living/remove_from)
	UnregisterSignal(holder, COMSIG_MOB_EQUIPPED_ITEM)
	to_chat(remove_from, span_userdanger("Вы забываете мастерство корпоративного дзюдо..."))
	discombobulate?.Remove(remove_from)
	return ..()

/datum/martial_art/judo/proc/check_baton(datum/source, obj/item/equipped_item, slot)
	SIGNAL_HANDLER
	if(!istype(equipped_item, /obj/item/melee/baton))
		return

	if(slot != ITEM_SLOT_HANDS)
		return

	to_chat(holder, span_warning("Вам против[genderize_ru(equipped_item.gender, "ен", "на", "но", "ны")] [equipped_item.declent_ru(NOMINATIVE)]!"))
	holder.dropItemToGround(equipped_item)

//Increased harm damage
/datum/martial_art/judo/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	var/picked_hit_type = GLOB.ru_attack_verbs[pick("chops", "slices", "strikes")]
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	defender.apply_damage(6, BRUTE)
	playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE)
	defender.visible_message(
		span_danger("[attacker.declent_ru(NOMINATIVE)] [picked_hit_type] [defender.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("[attacker.declent_ru(NOMINATIVE)] [picked_hit_type] вас!")
	)
	log_combat(attacker, defender, "melee attack ([src])")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/judo/disarm_act(mob/living/attacker, mob/living/defender)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	if(attacker == defender)//there is no disarming yourself, so we need to let user know
		to_chat(attacker, span_notice("Вы добавили толчек в комбо."))
		return MARTIAL_ATTACK_FAIL

	return MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/grab_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, "захват", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/help_act(mob/living/attacker, mob/living/defender)
	if(check_one_click_combo(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	add_to_streak("E", defender)
	attacker.changeNext_move(CLICK_CD_MELEE / 2)
	return check_streak(attacker, defender) ? MARTIAL_ATTACK_SUCCESS : MARTIAL_ATTACK_INVALID

/datum/martial_art/judo/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, GOLDENBLAST_COMBO))
		reset_streak()
		return goldenblast(attacker, defender)
	// must be upper than eyepoke
	if(check_with_no_reset(WHEELTHROW_COMBO))
		reset_streak()
		return wheelthrow(attacker, defender)
	if(check_with_no_reset(ARMBAR_COMBO))
		return armbar(attacker, defender)
	if(check_with_no_reset(EYEPOKE_COMBO))
		return eyepoke(attacker, defender)
	if(check_with_no_reset(JUDOTHROW_COMBO))
		return judothrow(attacker, defender)
	return FALSE

/datum/martial_art/judo/proc/check_one_click_combo(mob/living/attacker, mob/living/defender)
	if(streak == DISCOMBOBULATE_COMBO)
		reset_streak()
		return discombobulate(attacker, defender)

///Used to make combos in other combos
/datum/martial_art/judo/proc/check_with_no_reset(combo)
	var/combo_len = length(combo)
	if(combo_len > length(streak))
		return FALSE
	return findtext(streak, combo, -1 * combo_len)

/datum/martial_art/judo/proc/armbar(mob/living/attacker, mob/living/defender)
	if(defender.body_position != LYING_DOWN)
		return FALSE
	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] берёт [defender.declent_ru(ACCUSATIVE)] в захват!"),
		span_userdanger("[attacker.declent_ru(NOMINATIVE)] берёт вас в захват!")
	)
	playsound(get_turf(attacker), 'sound/items/weapons/slashmiss.ogg', 40, TRUE)
	if(attacker.body_position != LYING_DOWN)
		defender.drop_all_held_items()
	defender.apply_damage(45, STAMINA)
	defender.apply_status_effect(/datum/status_effect/judo_armbar)
	defender.Knockdown(5 SECONDS)
	log_combat(attacker, defender, "armbar ([src])")
	return TRUE

/datum/martial_art/judo/proc/eyepoke(mob/living/attacker, mob/living/defender)
	if(defender.is_pepper_proof()) //not all eye_cover flags really cover eyes.
		to_chat(attacker, "Глаза цели защищены от удара.")
		return FALSE

	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] тыкает в глаза [defender.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("[attacker.declent_ru(ACCUSATIVE)] тыкает вам в глаза!")
	)
	playsound(get_turf(attacker), 'sound/items/weapons/whip.ogg', 40, TRUE)
	defender.apply_damage(10, BRUTE)
	defender.set_eye_blur_if_lower(30 SECONDS)
	defender.adjust_temp_blindness(2 SECONDS)
	log_combat(attacker, defender, "eye poke ([src])")
	return TRUE

/datum/martial_art/judo/proc/goldenblast(mob/living/attacker, mob/living/defender)
	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] бьёт [defender.declent_ru(ACCUSATIVE)] энергией, прижимая к земле!"),
		span_userdanger("[attacker.declent_ru(NOMINATIVE)] делает странные жесты руками, дико кричит и тычет вам прямо в грудь! Вы чувствуете, как гнев ЗОЛОТОГО РАЗРЯДА пронзает ваше тело! Вы совершенно обробастены!")
	)
	playsound(get_turf(defender), 'sound/items/weapons/taser.ogg', 55, TRUE)
	defender.SpinAnimation(10, 1)
	do_sparks(5, FALSE, defender)
	attacker.say("ЗОЛОТОЙ РАЗРЯД!")
	playsound(get_turf(attacker), 'modular_bandastation/martial_arts/sound/goldenblast.ogg', 60, TRUE)
	defender.apply_damage(120, STAMINA)
	defender.Knockdown(30 SECONDS)
	defender.set_confusion(30 SECONDS)
	log_combat(attacker, defender, "golden blast ([src])")
	return TRUE

/datum/martial_art/judo/proc/judothrow(mob/living/attacker, mob/living/defender)
	if((attacker.body_position == LYING_DOWN) || (defender.body_position == LYING_DOWN))
		return FALSE
	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] бросает [defender.declent_ru(ACCUSATIVE)] на землю!"),
		span_userdanger("[attacker.declent_ru(NOMINATIVE)] бросает вас на землю!")
	)
	playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE)
	defender.apply_damage(25, STAMINA)
	defender.Knockdown(7 SECONDS)
	log_combat(attacker, defender, "judo throw ([src])")
	return TRUE

/datum/martial_art/judo/proc/wheelthrow(mob/living/attacker, mob/living/defender)
	if((defender.body_position != LYING_DOWN) || !defender.has_status_effect(/datum/status_effect/judo_armbar))
		return FALSE

	if(attacker.body_position != LYING_DOWN)
		defender.visible_message(
			span_warning("[attacker.declent_ru(NOMINATIVE)] бросает [defender.declent_ru(ACCUSATIVE)] через плечо, и стукает об землю!"),
			span_userdanger("[attacker.declent_ru(NOMINATIVE)] бросает вас через плечо,стукая об землю!")
		)
		playsound(get_turf(attacker), 'sound/effects/magic/tail_swing.ogg', 40, TRUE)
		defender.SpinAnimation(10, 1)
	else
		defender.visible_message(
			span_warning("[attacker.declent_ru(NOMINATIVE)] прижимает [defender.declent_ru(ACCUSATIVE)] к земле."),
			span_userdanger("[attacker.declent_ru(NOMINATIVE)] прижимает вас к земле!")
		)
		playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE)

	defender.apply_damage(120, STAMINA)
	defender.Knockdown(15 SECONDS)
	defender.set_confusion(10 SECONDS)
	log_combat(attacker, defender, "wheel throw / floor pin ([src])")
	return TRUE

/datum/martial_art/judo/proc/discombobulate(mob/living/attacker, mob/living/defender)
	defender.visible_message(
		span_warning("[attacker.declent_ru(NOMINATIVE)] бьёт [attacker.declent_ru(ACCUSATIVE)] ладонью по голове!"),
		span_userdanger("[attacker.declent_ru(NOMINATIVE)] ударяет вас ладонью!")
	)
	playsound(get_turf(attacker), 'sound/items/weapons/slap.ogg', 40, TRUE)
	defender.apply_damage(10, STAMINA)
	defender.adjust_confusion(5 SECONDS)
	log_combat(attacker, defender, "discombobulate ([src])")
	return TRUE

/datum/action/discombobulate
	name = "Сбить с толку"
	desc = "Нанесите противнику удар по уху, ненадолго сбив его с толку."
	button_icon = 'modular_bandastation/martial_arts/icons/actions.dmi'
	button_icon_state = "discombobulate"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/discombobulate/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == DISCOMBOBULATE_COMBO)
		owner.visible_message(
			span_danger("[owner.declent_ru(NOMINATIVE)] встает в нейтральную стойку."),
			span_bolditalic("Вы не готовите новых приёмов.")
		)
		source.streak = ""
	else
		owner.visible_message(
			span_danger("[owner.declent_ru(NOMINATIVE)] встает в сбивающую стойку!"),
			span_bolditalic("Ваше следующеё приём это 'сбить с толку'.")
		)
		source.streak = DISCOMBOBULATE_COMBO
