/**
 * On use in hand, heals you over time and removes injury movement debuffs. Also makes you a bit sad.
 * On use when implanted, fully heals. Automatically fully heals if you would enter crit.
 */
/obj/item/organ/internal/monster_core/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to help keep your body going, but it will rapidly decay into uselessness."
	desc_preserved = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	desc_inert = "All that remains of a hivelord. It has decayed, and is completely useless."
	user_status = /datum/status_effect/regenerative_core
	moodlet = /datum/mood_event/healsbadman

/obj/item/organ/internal/monster_core/regenerative_core/preserve(implanted = FALSE)
	if (implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))
	return ..()

/obj/item/organ/internal/monster_core/regenerative_core/go_inert()
	. = .. ()
	if (!.)
		return
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))

/obj/item/organ/internal/monster_core/regenerative_core/on_life(delta_time, times_fired)
	. = ..()
	if (owner.health <= owner.crit_threshold)
		activate_implanted()

/obj/item/organ/internal/monster_core/regenerative_core/activate_implanted()
	owner.revive(full_heal = TRUE, admin_revive = FALSE)
	qdel(src)

/// Log applications.
/obj/item/organ/internal/monster_core/regenerative_core/apply_to(mob/living/target, mob/user)
	if (target != user)
		target.visible_message(span_notice("[user] forces [target] to apply [src]... Black tendrils entangle and reinforce [target.p_them()]!"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
	else
		to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
	return ..()

/// Different graphics/desc for the lavaland legion
/obj/item/organ/internal/monster_core/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness."
	desc_preserved = "The core has been stabilized, allowing you to use it to heal completely without danger of decay."
	desc_inert = "The core has decayed, and is completely useless."
	icon_state = "legion_soul_unstable"
	icon_state_inert = "legion_soul_inert"
	icon_state_preserved = "legion_soul"
