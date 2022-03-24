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
/datum/action/cooldown/spell/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	button_icon_state = "soultap"

	// I could see why this wouldn't be necromancy, but messing with souls or whatever. Ectomancy?
	school = SCHOOL_NECROMANCY
	cooldown_time = 1 SECONDS
	spell_max_level = 1

	invocation = "AT ANY COST!"
	invocation_type = INVOCATION_SHOUT

/datum/action/cooldown/spell/tap/is_valid_target(atom/cast_on)
	if(HAS_TRAIT(cast_on, TRAIT_NO_SOUL))
		to_chat(cast_on, span_warning("You have no soul to tap into!"))
		return FALSE

	return isliving(cast_on)

/datum/action/cooldown/spell/tap/cast(mob/living/cast_on)
	. = ..()
	to_chat(cast_on, span_danger("Your body feels drained and there is a burning pain in your chest."))
	cast_on.maxHealth -= HEALTH_LOST_PER_SOUL_TAP
	cast_on.health = min(cast_on.health, cast_on.maxHealth)
	if(cast_on.maxHealth <= 0)
		to_chat(cast_on, span_userdanger("Your weakened soul is completely consumed by the tap!"))
		ADD_TRAIT(cast_on, TRAIT_NO_SOUL, MAGIC_TRAIT)
		return

	for(var/datum/action/cooldown/spell/spell in cast_on.actions)
		spell.next_use_time = world.time
		spell.UpdateButtonIcon()

#undef HEALTH_LOST_PER_SOUL_TAP
