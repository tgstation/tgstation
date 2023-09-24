/**
 * Manual heart pumping component. Requires the holder to pump their heart manually every
 * so often or die.
 *
 * Mainly used by the cursed heart.
 */
/datum/component/manual_heart
	/// The action for pumping your heart
	var/datum/action/cooldown/manual_heart/pump_action
	var/last_pump = 0
	var/add_colour = TRUE //So we're not constantly recreating colour datums
	/// How long between needed pumps; you can pump one second early
	var/pump_delay = 3 SECONDS
	/// How much blood volume you lose every missed pump, this is a flat amount not a percentage!
	var/blood_loss = BLOOD_VOLUME_NORMAL * 0.2 // 20% of normal volume, missing five pumps is instant death

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0

/datum/component/manual_heart/Initialize(pump_delay = 3 SECONDS, blood_loss = BLOOD_VOLUME_NORMAL * 0.2, heal_brute = 0, heal_burn = 0, heal_oxy = 0)
	//Non-Carbon mobs can't have hearts, and should never receive this component.
	if (!iscarbon(parent))
		stack_trace("Manual Heart component added to [parent] ([parent?.type]) which is not a /mob/living/carbon subtype.")
		return COMPONENT_INCOMPATIBLE

	src.pump_delay = pump_delay
	src.blood_loss = blood_loss
	src.heal_brute = heal_brute
	src.heal_burn = heal_burn
	src.heal_oxy = heal_oxy

	pump_action = new(src)
	pump_action.cooldown_time = pump_delay - (1 SECONDS) //you can pump up to a second early
	pump_action.Grant(parent)

	var/mob/living/carbon/carbon_parent = parent
	var/obj/item/organ/internal/heart/parent_heart = carbon_parent.get_organ_slot(ORGAN_SLOT_HEART)
	if(parent_heart && !HAS_TRAIT(carbon_parent, TRAIT_NOBLOOD) && carbon_parent.stat != DEAD)
		START_PROCESSING(SSdcs, src)
		last_pump = world.time

	to_chat(parent, span_userdanger("Your heart no longer beats automatically! You have to pump it manually - otherwise you'll die!"))

/datum/component/manual_heart/Destroy()
	to_chat(parent, span_userdanger("You feel your heart start beating normally again!"))
	var/mob/living/carbon/carbon_parent = parent
	if(istype(carbon_parent))
		carbon_parent.remove_client_colour(/datum/client_colour/manual_heart_blood)
	QDEL_NULL(pump_action)
	return ..()

/datum/component/manual_heart/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(check_removed_organ))
	RegisterSignal(parent, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_added_organ))
	RegisterSignals(parent, list(COMSIG_LIVING_DEATH, SIGNAL_ADDTRAIT(TRAIT_NOBLOOD)), PROC_REF(pause))
	RegisterSignals(parent, list(COMSIG_LIVING_REVIVE, SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD)), PROC_REF(restart))

/datum/component/manual_heart/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN, COMSIG_LIVING_REVIVE, COMSIG_LIVING_DEATH, SIGNAL_ADDTRAIT(TRAIT_NOBLOOD), SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD)))

/datum/component/manual_heart/proc/restart()
	SIGNAL_HANDLER

	if(check_valid())
		last_pump = world.time
		START_PROCESSING(SSdcs, src)

/datum/component/manual_heart/proc/pause()
	SIGNAL_HANDLER

	STOP_PROCESSING(SSdcs, src)

/// Worker proc that checks logic for if a pump can happen, and applies effects/notifications from doing so
/datum/component/manual_heart/proc/on_pump(mob/owner)
	last_pump = world.time
	playsound(owner,'sound/effects/singlebeat.ogg', 40, TRUE)
	owner.balloon_alert(owner, "your heart beats")

	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner

	if(HAS_TRAIT(carbon_owner, TRAIT_NOBLOOD))
		return
	carbon_owner.blood_volume = min(carbon_owner.blood_volume + (blood_loss * 0.5), BLOOD_VOLUME_MAXIMUM)
	carbon_owner.remove_client_colour(/datum/client_colour/manual_heart_blood)
	add_colour = TRUE
	carbon_owner.adjustBruteLoss(-heal_brute)
	carbon_owner.adjustFireLoss(-heal_burn)
	carbon_owner.adjustOxyLoss(-heal_oxy)

/datum/component/manual_heart/process()
	var/mob/living/carbon/carbon_parent = parent

	//If they aren't connected, don't kill them.
	if(!istype(carbon_parent) || !carbon_parent.client)
		last_pump = world.time
		return

	if(world.time <= (last_pump + pump_delay))
		return

	carbon_parent.blood_volume = max(carbon_parent.blood_volume - blood_loss, 0)
	to_chat(carbon_parent, span_userdanger("You have to keep pumping your blood!"))
	last_pump = world.time - (2 SECONDS) //give two full seconds before losing more blood
	if(add_colour)
		carbon_parent.add_client_colour(/datum/client_colour/manual_heart_blood)
		add_colour = FALSE

///If a new heart is added, start processing.
/datum/component/manual_heart/proc/check_added_organ(mob/organ_owner, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/heart/new_heart = new_organ

	if(istype(new_heart) && check_valid())
		last_pump = world.time
		START_PROCESSING(SSdcs, src)

///If the heart is removed, stop processing.
/datum/component/manual_heart/proc/check_removed_organ(mob/organ_owner, obj/item/organ/removed_organ)
	SIGNAL_HANDLER

	var/obj/item/organ/internal/heart/removed_heart = removed_organ

	if(istype(removed_heart))
		STOP_PROCESSING(SSdcs, src)

///Helper proc to check if processing can be restarted.
/datum/component/manual_heart/proc/check_valid()
	var/mob/living/carbon/carbon_parent = parent
	if(!istype(parent))
		return FALSE
	var/obj/item/organ/internal/heart/parent_heart = carbon_parent.get_organ_slot(ORGAN_SLOT_HEART)
	return (parent_heart && !HAS_TRAIT(carbon_parent, TRAIT_NOBLOOD) && carbon_parent.stat != DEAD)

///Action to pump your heart. Cooldown will always be set to 1 second less than the pump delay.
/datum/action/cooldown/manual_heart
	name = "Pump your blood"
	cooldown_time = 2 SECONDS
	check_flags = NONE
	button_icon = 'icons/obj/medical/organs/organs.dmi'
	button_icon_state = "cursedheart-off"

/datum/action/cooldown/manual_heart/Activate(atom/atom_target)
	. = ..()

	var/datum/component/manual_heart/heart = target
	if(!istype(heart))
		CRASH("Manual heart pump action created without corresponding component!")
	heart.on_pump(owner)

///The action button is only available when you're a living carbon with blood and a heart.
/datum/action/cooldown/manual_heart/IsAvailable(feedback = FALSE)
	var/mob/living/carbon/heart_haver = owner
	if(!istype(heart_haver) || HAS_TRAIT(heart_haver, TRAIT_NOBLOOD) || heart_haver.stat == DEAD)
		return FALSE
	var/obj/item/organ/internal/heart/heart_havers_heart = heart_haver.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart_havers_heart)
		return FALSE
	return ..()

/datum/client_colour/manual_heart_blood
	priority = 100 //it's an indicator you're dying, so it's very high priority
	colour = "#FF0000"
