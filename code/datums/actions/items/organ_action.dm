/datum/action/item_action/organ_action
	name = "Organ Action"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/attached_organ = target
	if(!attached_organ.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle
	name = "Toggle Organ"

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Toggle [organ_target.name]"

/datum/action/item_action/organ_action/use
	name = "Use Organ"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Use [organ_target.name]"

/datum/action/item_action/organ_action/cooldown
	name = "Use Organ"
	/// How long we have to wait between uses.
	var/activate_cooldown_length
	/// The cooldown between button uses.
	COOLDOWN_DECLARE(activate_cooldown)

/datum/action/item_action/organ_action/cooldown/New(Target, cooldown = 5 MINUTES)
	..()
	activate_cooldown_length = cooldown
	var/obj/item/organ/organ_target = target
	name = "Use [organ_target.name]"

/datum/action/item_action/organ_action/cooldown/IsAvailable()
	. = ..()
	if (!.)
		return
	if(!COOLDOWN_FINISHED(src, activate_cooldown))
		return FALSE
	return TRUE

/datum/action/item_action/organ_action/cooldown/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	COOLDOWN_START(src, activate_cooldown, activate_cooldown_length)
	UpdateButtons()
	addtimer(CALLBACK(src, .proc/UpdateButtons), activate_cooldown_length + 1)
	return TRUE
