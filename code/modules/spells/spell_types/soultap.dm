/// The amount of health taken per tap.
#define HEALTH_LOST_PER_SOUL_TAP 20

/**
 * SOUL TAP!
 *
 * Trades 20 max health for a refresh on all of your spells.
 * I was considering making it depend on the cooldowns of your spells, but I want to support "Big spell wizard" with this loadout.
 * The two spells that sound most problematic with this is mindswap and lichdom,
 * but soul tap requires clothes for mindswap and lichdom takes your soul.
 */
/obj/effect/proc_holder/spell/self/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "soultap"
	invocation = "AT ANY COST!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_NECROMANCY //i could see why this wouldn't be necromancy but messing with souls or whatever. ectomancy?
	charge_max = 1 SECONDS
	cooldown_min = 1 SECONDS
	level_max = 0

/obj/effect/proc_holder/spell/self/tap/cast(list/targets, mob/living/user = usr)
	if(HAS_TRAIT(user, TRAIT_NO_SOUL))
		to_chat(user, span_warning("You have no soul to tap into!"))
		return

	to_chat(user, span_danger("Your body feels drained and there is a burning pain in your chest."))
	user.maxHealth -= HEALTH_LOST_PER_SOUL_TAP
	user.health = min(user.health, user.maxHealth)
	if(user.maxHealth <= 0)
		to_chat(user, span_userdanger("Your weakened soul is completely consumed by the tap!"))
		ADD_TRAIT(user, TRAIT_NO_SOUL, MAGIC_TRAIT)
		return

	for(var/obj/effect/proc_holder/spell/spell in user.mind.spell_list)
		spell.charge_counter = spell.charge_max
		spell.recharging = FALSE
		spell.update_appearance()

#undef HEALTH_LOST_PER_SOUL_TAP
