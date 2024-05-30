/// This accessory can be pinned onto someone else
/datum/component/pinnable_accessory
	/// Do we let people know what we're doing?
	var/silent
	/// How long does it take to pin this onto someone?
	var/pinning_time
	/// Optional callback invoked before pinning, will cancel if it returns FALSE
	var/datum/callback/on_pre_pin

/datum/component/pinnable_accessory/Initialize(silent = FALSE, pinning_time = 2 SECONDS, datum/callback/on_pre_pin = null)
	. = ..()
	if (!istype(parent, /obj/item/clothing/accessory))
		return COMPONENT_INCOMPATIBLE
	src.silent = silent
	src.pinning_time = pinning_time
	src.on_pre_pin = on_pre_pin

/datum/component/pinnable_accessory/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_atom_interact))

/datum/component/pinnable_accessory/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM)

/// Called when you whack someone with this accessory
/datum/component/pinnable_accessory/proc/on_atom_interact(obj/item/clothing/accessory/badge, mob/living/user, atom/target, modifiers)
	SIGNAL_HANDLER
	if (!ishuman(target) || target == user)
		return

	INVOKE_ASYNC(src, PROC_REF(try_to_pin), badge, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Actually try to pin it on
/datum/component/pinnable_accessory/proc/try_to_pin(obj/item/clothing/accessory/badge, mob/living/carbon/human/distinguished, mob/user)
	var/obj/item/clothing/under/distinguished_uniform = distinguished.w_uniform
	if(!istype(distinguished_uniform))
		distinguished.balloon_alert(user, "no uniform to pin on!")
		return

	if(!badge.can_attach_accessory(distinguished_uniform, user))
		// Check handles feedback messages and etc
		return

	if (!silent)
		user.visible_message(
			span_notice("[user] tries to pin [badge] on [distinguished]'s chest."),
			span_notice("You try to pin [badge] on [distinguished]'s chest."),
		)

	if (on_pre_pin && !on_pre_pin.Invoke(distinguished, user))
		return
	if(!pin_checks(user, distinguished) || !do_after(user, pinning_time, distinguished, extra_checks = CALLBACK(src, PROC_REF(pin_checks), user, distinguished)))
		return

	var/pinned = distinguished_uniform.attach_accessory(badge, user)
	if (silent)
		return

	if (pinned)
		user.visible_message(
			span_notice("[user] pins [badge] on [distinguished]'s chest."),
			span_notice("You pin [badge] on [distinguished]'s chest."),
		)
	else
		user.visible_message(
			span_warning("[user] fails to pin [badge] on [distinguished]'s chest, seemingly unable to part with it."),
			span_warning("You fail to pin [badge] on [distinguished]'s chest."),
		)

/// Callback for do_after to check if we can still be pinned
/datum/component/pinnable_accessory/proc/pin_checks(mob/living/pinner, mob/living/carbon/human/pinning_on)
	if(QDELETED(parent) || QDELETED(pinner) || QDELETED(pinning_on))
		return FALSE
	if(!pinner.is_holding(parent) || !pinner.Adjacent(pinning_on))
		return FALSE
	var/obj/item/clothing/accessory/badge = parent
	var/obj/item/clothing/under/pinning_on_uniform = pinning_on.w_uniform
	if(!istype(pinning_on_uniform) || !badge.can_attach_accessory(pinning_on_uniform, pinner))
		return FALSE
	return TRUE
