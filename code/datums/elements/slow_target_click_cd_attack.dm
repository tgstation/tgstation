/// Applied to items: Applies a status effect to the target that slows their click CD
/datum/element/slow_target_click_cd_attack
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// How much click CD to add to the target's clicks
	var/reduction

/datum/element/slow_target_click_cd_attack/Attach(datum/target, reduction = 0.2 SECONDS)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.reduction = reduction
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(try_slow))

/datum/element/slow_target_click_cd_attack/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)

/datum/element/slow_target_click_cd_attack/proc/try_slow(obj/item/source, atom/hit, mob/user)
	SIGNAL_HANDLER

	if(!isliving(hit))
		return
	var/mob/living/target = hit
	target.apply_status_effect(/datum/status_effect/cd_slow, reduction, REF(src))

/// Applied by [/datum/element/slow_target_click_cd_attack] to slow the target's click CD
/datum/status_effect/cd_slow
	id = "cd_slow"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	/// How much click CD to add to the target's clicks
	var/reduction
	/// The source of the slow, they don't stack
	var/source

/datum/status_effect/cd_slow/on_creation(mob/living/new_owner, reduction, source)
	src.reduction = reduction
	src.source = source
	return ..()

/datum/status_effect/cd_slow/on_apply()
	for(var/datum/status_effect/cd_slow/slow in owner)
		if(slow.source == src.source)
			slow.reduction = max(slow.reduction, src.reduction)
			return FALSE

	return TRUE

/datum/status_effect/cd_slow/nextmove_adjust()
	return reduction
