/**
 * On use in hand, makes you run really fast for 5 seconds and ignore injury movement decrease.
 * On use when implanted, run for longer and ignore all negative movement. Automatically triggers if health is low (to escape).
 */
/obj/item/organ/internal/monster_core/rush_gland
	name = "rush gland"
	desc = "A lobstrosity's engorged adrenal gland. You can squeeze it to get a rush of energy on demand."
	desc_preserved = "A lobstrosity's engorged adrenal gland. It is preserved, allowing you to use it for a burst of speed whenever you need it."
	desc_inert = "A lobstrosity's adrenal gland. It is all shrivelled up."
	user_status = /datum/status_effect/lobster_rush

#define HEALTH_DANGER_ZONE 30

/obj/item/organ/internal/monster_core/rush_gland/should_apply_on_life()
	if (owner.health <= HEALTH_DANGER_ZONE)
		to_chat(owner, span_notice("The stress on your body triggers [src]!"))
		return TRUE
	return FALSE

#undef HEALTH_DANGER_ZONE

/obj/item/organ/internal/monster_core/rush_gland/activate_implanted()
	owner.apply_status_effect(/datum/status_effect/lobster_rush/extended)
	return ..()
