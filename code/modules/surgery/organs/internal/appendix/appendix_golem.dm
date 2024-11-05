
/obj/item/organ/appendix/golem
	name = "internal forge"
	desc = "This expanded digestive chamber allows golems to smelt minerals, provided that they are immersed in lava."
	icon_state = "ethereal_heart-off"
	color = COLOR_GOLEM_GRAY
	organ_flags = ORGAN_MINERAL
	/// Action which performs smelting
	var/datum/action/cooldown/internal_smelting/smelter

/obj/item/organ/appendix/golem/Initialize(mapload)
	. = ..()
	smelter = new(src)

/obj/item/organ/appendix/golem/on_mob_insert(mob/living/carbon/organ_owner)
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_for_lava))

/// Give the action while in lava
/obj/item/organ/appendix/golem/proc/check_for_lava(mob/living/owner)
	SIGNAL_HANDLER
	if (!islava(owner.loc))
		smelter.Remove(owner)
		return
	if (smelter.owner != owner)
		smelter.Grant(owner)

/obj/item/organ/appendix/golem/on_mob_remove(mob/living/carbon/organ_owner)
	UnregisterSignal(organ_owner, COMSIG_MOVABLE_MOVED)
	smelter?.Remove(organ_owner) // Might have been deleted by Destroy already
	return ..()

/obj/item/organ/appendix/golem/Destroy()
	QDEL_NULL(smelter)
	return ..()

/// Lets golems smelt ore with their organs
/datum/action/cooldown/internal_smelting
	name = "Internal Forge"
	desc = "While stood in lava you can use your internal forge to smelt ores into processed bars."
	button_icon = 'icons/obj/stack_objects.dmi'
	button_icon_state = "sheet-adamantine_2"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// Time it takes to smelt one ore into one result
	var/smelt_speed = 2 SECONDS
	/// Amount to speed up by every completion
	var/speed_up_interval = 0.2 SECONDS
	/// Minimum time to take to smelt one ore into one result
	var/minimum_smelt_speed = 1 SECONDS

/datum/action/cooldown/internal_smelting/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	if (!islava(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "requires lava!")
		return FALSE
	return TRUE

/datum/action/cooldown/internal_smelting/Activate(mob/target)
	. = ..()
	smelt_speed = initial(smelt_speed)
	smelt_held(target)

/// Smelt an item held in one hand and put the result in the other
/datum/action/cooldown/internal_smelting/proc/smelt_held(mob/target)
	var/obj/item/stack/ore/held_ore = locate(/obj/item/stack/ore) in target.held_items
	if (!held_ore?.refined_type)
		target.balloon_alert(target, "nothing to smelt!")
		return
	target.balloon_alert(owner, "smelting...")
	if (!do_after(target, smelt_speed, target = held_ore, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(IsAvailable), FALSE), interaction_key = REF(src)))
		return
	var/obj/item/smelted = new held_ore.refined_type
	held_ore.use(1)
	target.put_in_hands(smelted)
	if (!held_ore)
		target.balloon_alert(target, "no ore left!")
		return
	smelt_speed = max(smelt_speed - speed_up_interval, minimum_smelt_speed)
	smelt_held(target)
