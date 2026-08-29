// ============================================================
//  INFECTION ABILITY
// ============================================================

/// Ability for the infector to infect a nearby human with the Khaaroot virus.
/// Requires a 5-second channeled aggressive grab on the target.
/datum/action/cooldown/spell/pointed/khaaroot_infect
	name = "заражение Кхаарут"
	desc = "Внедрить остатки вируса Кхаарут в разум цели, подчиняя её воле улья. Цель должна находиться рядом и не иметь ментальной защиты."
	button_icon = 'modular_bandastation/prime_only/icons/khaaroot.dmi'
	button_icon_state = "infect"
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION
	cast_range = 1
	/// How long the infection channel lasts
	var/channel_time = 9 SECONDS
	/// Timer IDs for periodic gasp effects during channel
	var/list/gasp_timers = list()
	/// Whether we're currently channeling the infection
	var/channeling = FALSE

/datum/action/cooldown/spell/pointed/khaaroot_infect/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/H = cast_on
	if(H.stat == DEAD)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/khaaroot_infect/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return channeling

/datum/action/cooldown/spell/pointed/khaaroot_infect/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(channeling)
		if(feedback)
			to_chat(owner, span_warning("Вы уже заражаете цель!"))
		return FALSE
	return TRUE

/// Validate all infection preconditions and hivemind status before the channel begins
/datum/action/cooldown/spell/pointed/khaaroot_infect/proc/validate_infection_target(mob/living/carbon/human/target)
	var/datum/status_effect/khaaroot_survivor/effect = owner.has_status_effect(/datum/status_effect/khaaroot_survivor)
	if(!effect || !effect.hivemind)
		to_chat(owner, span_warning("Ваш вирус Кхаарут недостаточно активен для заражения других."))
		owner.balloon_alert(owner, "вирус неактивен")
		return FALSE
	if(!target.mind)
		to_chat(owner, span_warning("Цель не имеет разума для подчинения."))
		owner.balloon_alert(owner, "нет разума")
		return FALSE
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		to_chat(owner, span_warning("Разум цели защищён от воздействия Кхаарут."))
		owner.balloon_alert(owner, "разум защищён")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(owner, span_warning("Щит разума цели блокирует проникновение вируса."))
		owner.balloon_alert(owner, "Щит разума")
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/khaaroot_thrall))
		to_chat(owner, span_warning("Цель уже является частью улья Кхаарут."))
		owner.balloon_alert(owner, "уже в улье")
		return FALSE
	if(target.mind.has_antag_datum(/datum/antagonist/khaaroot_source))
		to_chat(owner, span_warning("Невозможно заразить источник улья."))
		owner.balloon_alert(owner, "это источник")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/khaaroot_infect/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/mob/living/carbon/human/target = cast_on
	var/mob/living/caster = owner

	if(!validate_infection_target(target))
		return SPELL_CANCEL_CAST

	if(caster.pulling && caster.pulling != target)
		caster.stop_pulling()

	if(!caster.pulling || caster.pulling != target)
		if(caster.grab(target) != GRAB_SUCCESS)
			to_chat(caster, span_warning("Не удалось схватить [target.declent_ru(ACCUSATIVE)] для заражения!"))
			caster.balloon_alert(caster, "не схватить")
			return SPELL_CANCEL_CAST

	if(caster.grab_state < GRAB_AGGRESSIVE)
		caster.setGrabState(GRAB_AGGRESSIVE)

	if(caster.pulling != target || caster.grab_state < GRAB_AGGRESSIVE)
		to_chat(caster, span_warning("Не удаётся удержать [target.declent_ru(ACCUSATIVE)] в захвате!"))
		caster.balloon_alert(caster, "не удержать")
		if(caster.pulling == target)
			caster.stop_pulling()
		return SPELL_CANCEL_CAST

	caster.visible_message(
		span_danger("[caster.declent_ru(NOMINATIVE)] хватает [target.declent_ru(ACCUSATIVE)] за горло! В воздухе чувствуется запах разложения..."),
		span_userdanger("Вы хватаете [target.declent_ru(ACCUSATIVE)] и начинаете впрыскивать вирус Кхаарут!"),
	)
	to_chat(target, span_userdanger("[caster.declent_ru(NOMINATIVE)] хватает вас! Вы чувствуете, как что-то чужеродное проникает в ваше тело!"))

	playsound(caster, 'sound/effects/blob/attackblob.ogg', 50, TRUE)

	if(!HAS_TRAIT(target, TRAIT_NO_BREATHLESS_DAMAGE))
		gasp_timers += addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, emote), "gasp"), 1 SECONDS, TIMER_STOPPABLE)
		gasp_timers += addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, emote), "gasp"), 2.5 SECONDS, TIMER_STOPPABLE)
		gasp_timers += addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, emote), "gasp"), 4 SECONDS, TIMER_STOPPABLE)
		gasp_timers += addtimer(CALLBACK(target, TYPE_PROC_REF(/atom, do_alert_animation)), 2.5 SECONDS, TIMER_STOPPABLE)

	channeling = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)

	var/datum/callback/extra_checks = CALLBACK(src, PROC_REF(check_channel_valid), WEAKREF(target), WEAKREF(caster))
	if(!do_after(caster, channel_time, target, timed_action_flags = NONE, extra_checks = extra_checks))
		cleanup_channel(target, caster, interrupted = TRUE)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/khaaroot_infect/proc/check_channel_valid(datum/weakref/target_ref, datum/weakref/caster_ref)
	var/mob/living/target = target_ref?.resolve()
	var/mob/living/caster = caster_ref?.resolve()
	if(!target || !caster)
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!caster.Adjacent(target))
		return FALSE
	if(caster.pulling != target || caster.grab_state < GRAB_AGGRESSIVE)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/khaaroot_infect/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	var/mob/living/caster = owner

	cleanup_channel(target, caster, interrupted = FALSE)

	var/datum/status_effect/khaaroot_survivor/effect = caster.has_status_effect(/datum/status_effect/khaaroot_survivor)
	if(!effect || !effect.hivemind)
		to_chat(caster, span_warning("Ваш вирус Кхаарут внезапно ослаб! Заражение не удалось."))
		caster.balloon_alert(caster, "вирус ослаб")
		return

	effect.hivemind.infect(target, caster)

/datum/action/cooldown/spell/pointed/khaaroot_infect/proc/cleanup_channel(mob/living/target, mob/living/caster, interrupted)
	for(var/timer_id in gasp_timers)
		deltimer(timer_id)
	gasp_timers.Cut()

	if(caster.pulling == target)
		caster.stop_pulling()

	channeling = FALSE
	build_all_button_icons(UPDATE_BUTTON_STATUS)

	if(interrupted)
		caster.visible_message(
			span_danger("Заражение прервано! [caster.declent_ru(NOMINATIVE)] отпускает [target.declent_ru(ACCUSATIVE)]."),
			span_warning("Заражение [target.declent_ru(GENITIVE)] прервано!"),
		)
		to_chat(target, span_warning("Чужеродное влияние отступает... Вы свободны от захвата."))
		caster.balloon_alert(caster, "прервано")
		target.balloon_alert(target, "свободен")


// ============================================================
//  HIVEMIND COMMUNICATION
// ============================================================

/// Innate action for hivemind communication — available to both infector and thralls.
/datum/action/cooldown/khaaroot_hivemind_comm
	name = "речь Улья Кхаарут"
	desc = "Отправить мысленное сообщение всем участникам улья Кхаарут."
	button_icon = 'modular_bandastation/prime_only/icons/khaaroot.dmi'
	button_icon_state = "hivemind_com"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

	/// Weakref to the hivemind controller
	var/datum/weakref/hivemind_ref

/datum/action/cooldown/khaaroot_hivemind_comm/New(datum/khaaroot_hivemind/hivemind)
	. = ..()
	if(hivemind)
		hivemind_ref = WEAKREF(hivemind)

/datum/action/cooldown/khaaroot_hivemind_comm/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/cooldown/khaaroot_hivemind_comm/Activate(atom/target)
	var/datum/khaaroot_hivemind/hivemind = hivemind_ref?.resolve()
	if(!hivemind)
		to_chat(owner, span_warning("Связь с ульем потеряна."))
		return

	var/prompt = "Введите сообщение для улья:"
	if(owner.mind)
		var/datum/antagonist/khaaroot_thrall/antag = owner.mind.has_antag_datum(/datum/antagonist/khaaroot_thrall)
		if(antag?.thrall_objective)
			prompt = "◆ ВАША ТЕКУЩАЯ ЗАДАЧА\n«[antag.thrall_objective]»\n\n[prompt]"

	var/message = tgui_input_text(owner, prompt, "Улей Кхаарут", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return

	log_directed_talk(owner, hivemind.get_infector_mob(), message, LOG_SAY, "khaaroot hivemind")
	hivemind.broadcast_message(message, owner)
	StartCooldown()


// ============================================================
//  CONTROL PANEL
// ============================================================

/// Innate action for the infector to open the hivemind control panel.
/datum/action/cooldown/khaaroot_hivemind_panel
	name = "панель Улья Кхаарут"
	desc = "Открыть панель управления ульем Кхаарут для управления заражёнными."
	button_icon = 'modular_bandastation/prime_only/icons/khaaroot.dmi'
	button_icon_state = "hivemind_panel"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 0
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

	/// Weakref to the hivemind controller
	var/datum/weakref/hivemind_ref

/datum/action/cooldown/khaaroot_hivemind_panel/New(datum/khaaroot_hivemind/hivemind)
	. = ..()
	if(hivemind)
		hivemind_ref = WEAKREF(hivemind)

/datum/action/cooldown/khaaroot_hivemind_panel/IsAvailable(feedback = FALSE)
	return ..() && (owner.stat != DEAD)

/datum/action/cooldown/khaaroot_hivemind_panel/Activate(atom/target)
	var/datum/khaaroot_hivemind/hivemind = hivemind_ref?.resolve()
	if(!hivemind)
		to_chat(owner, span_warning("Связь с ульем потеряна."))
		return
	if(!hivemind.is_infector(owner))
		to_chat(owner, span_warning("Только источник улья может открыть панель управления."))
		return
	hivemind.ui_interact(owner)
	StartCooldown()
