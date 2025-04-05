/**
 * On use in hand, heals you over time and removes injury movement debuffs. Also makes you a bit sad.
 * On use when implanted, fully heals. Automatically fully heals if you would enter crit.
 */
/obj/item/organ/monster_core/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to help keep your body going, but it will rapidly decay into uselessness."
	desc_preserved = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	desc_inert = "All that remains of a hivelord. It has decayed, and is completely useless."
	user_status = /datum/status_effect/regenerative_core
	actions_types = list(/datum/action/cooldown/monster_core_action/regenerative_core)
	icon_state = "hivelord_core"
	icon_state_inert = "hivelord_core_decayed"

/obj/item/organ/monster_core/regenerative_core/preserve(implanted = FALSE)
	if (implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))
	return ..()

/obj/item/organ/monster_core/regenerative_core/go_inert()
	. = .. ()
	if (!.)
		return
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))

/obj/item/organ/monster_core/regenerative_core/on_life(seconds_per_tick, times_fired)
	. = ..()
	if (owner.health <= owner.crit_threshold)
		trigger_organ_action(TRIGGER_FORCE_AVAILABLE)

/obj/item/organ/monster_core/regenerative_core/on_triggered_internal()
	owner.revive(HEAL_ALL & ~HEAL_REFRESH_ORGANS)
	qdel(src)

/// Log applications and apply moodlet.
/obj/item/organ/monster_core/regenerative_core/apply_to(mob/living/target, mob/user)
	target.add_mood_event(MOOD_CATEGORY_LEGION_CORE, /datum/mood_event/healsbadman)
	if (target != user)
		target.visible_message(span_notice("[user] forces [target] to apply [src]... Black tendrils entangle and reinforce [target.p_them()]!"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
	else
		to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
	return ..()

/// Different graphics/desc for the lavaland legion
/obj/item/organ/monster_core/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness."
	desc_preserved = "The core has been stabilized, allowing you to use it to heal completely without danger of decay."
	desc_inert = "The core has decayed, and is completely useless."
	icon_state = "legion_core"
	icon_state_inert = "legion_core_decayed"
	icon_state_preserved = "legion_core_stable"

/// Action used by the regenerative core
/datum/action/cooldown/monster_core_action/regenerative_core
	name = "Regenerate"
	desc = "Fully regenerate your body, consuming your regenerative core in the process. \
		This process will trigger automatically if you are badly wounded."
	button_icon_state = "legion_core_stable"
