/datum/action/cooldown/mob_cooldown/blood_worm/invade
	name = "Захват трупа"
	desc = "Захватите труп гуманоида, сделав его своим носителем."

	button_icon_state = "invade_corpse"

	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

	unset_after_click = FALSE // Unsetting is handled explicitly.

/datum/action/cooldown/mob_cooldown/blood_worm/invade/Grant(mob/granted_to)
	. = ..()
	if (!owner)
		return
	RegisterSignal(owner, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_dragged_onto))

/datum/action/cooldown/mob_cooldown/blood_worm/invade/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, COMSIG_MOUSEDROP_ONTO)

/datum/action/cooldown/mob_cooldown/blood_worm/invade/IsAvailable(feedback)
	if (!istype(owner, /mob/living/basic/blood_worm))
		return FALSE
	return ..()

/// If we drag ourselves onto a corpse (or a live human) then try and climb in
/datum/action/cooldown/mob_cooldown/blood_worm/invade/proc/on_dragged_onto(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if (user != owner || !ishuman(over))
		return
	INVOKE_ASYNC(src, PROC_REF(Activate), over)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO

/datum/action/cooldown/mob_cooldown/blood_worm/invade/Activate(atom/target)
	if (!ishuman(target))
		return FALSE

	var/mob/living/basic/blood_worm/worm = owner
	var/mob/living/carbon/human/victim = target

	if (!worm.Adjacent(victim))
		victim.balloon_alert(worm, "слишком далеко!")
		return FALSE
	if (!victim.IsReachableBy(worm))
		victim.balloon_alert(worm, "не достать!")
		return FALSE

	unset_click_ability(worm, refund_cooldown = FALSE) // If you fail after this point, it's because your attempt got interrupted or because the victim is invalid.

	if (!invade_check(worm, victim, feedback = TRUE))
		return TRUE // Don't bite the victim.

	worm.visible_message(
		message = span_danger("[worm.declent_ru(NOMINATIVE)] начинает проникать в [victim.declent_ru(ACCUSATIVE)]!"),
		self_message = span_notice("Вы начинаете проникать в [victim.declent_ru(ACCUSATIVE)]."),
		blind_message = span_hear("Вы слышите мерзкий, хлюпающий звук.")
	)

	if (!do_after(worm, 5 SECONDS, victim, extra_checks = CALLBACK(src, PROC_REF(invade_check), worm, victim)))
		return TRUE // Don't bite the victim.

	worm.enter_host(victim)

	return ..()

/// See if we can invade something
/datum/action/cooldown/mob_cooldown/blood_worm/invade/proc/invade_check(mob/living/basic/blood_worm/worm, mob/living/carbon/human/victim, feedback = FALSE)
	if (HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST))
		if (feedback)
			victim.balloon_alert(worm, "уже носитель!")
		return FALSE
	if (victim.stat != DEAD)
		if (feedback)
			victim.balloon_alert(worm, "всё ещё жив!")
		return FALSE
	if (!CAN_HAVE_BLOOD(victim))
		if (feedback)
			victim.balloon_alert(worm, "нет крови!")
		return FALSE
	if (victim.get_blood_volume() + worm.health * BLOOD_WORM_HEALTH_TO_BLOOD <= worm.get_eject_volume_threshold())
		if (feedback)
			victim.balloon_alert(worm, "недостаточно крови, чтобы взять под контроль!")
		return FALSE
	return TRUE
