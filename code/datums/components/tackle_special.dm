#define MAX_TABLE_MESSES 8 // how many things can we knock off a table at once?

/**
  *#tackle.dm
  *
  * For when you want to throw a person at something and have fun stuff happen
  *
  * This component is made for carbon mobs (really, humans), and allows its parent to throw themselves and perform tackles. This is done by enabling throw mode, then clicking on your
  *	  intended target with an empty hand. You will then launch toward your target. If you hit a carbon, you'll roll to see how hard you hit them. If you hit a solid non-mob, you'll
  *	  roll to see how badly you just messed yourself up. If, along your journey, you hit a table, you'll slam onto it and send up to MAX_TABLE_MESSES (8) /obj/items on the table flying,
  *	  and take a bit of extra damage and stun for each thing launched.
  *
  * There are 2 """skill rolls""" involved here, which are handled and explained in sack() and rollTackle() (for roll 1, carbons), and splat() (for roll 2, walls and solid objects)
*/
/datum/component/tackler/guardian
	/// The mob we're currently protecting
	var/mob/living/protectee
	/// How long our protection lasts
	var/aegis_duration = 5 SECONDS

/datum/component/tackler/guardian/Initialize(stamina_cost = 25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 0, min_distance = min_distance)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	..()

/datum/component/tackler/guardian/Destroy()
	protectee = null
	..()

/**
 * sack()
 *
 * sack() is called when you actually smack into something, assuming we're mid-tackle. First it deals with smacking into non-carbons, in two cases:
 * * If it's a non-carbon mob, we don't care, get out of here and do normal thrown-into-mob stuff
 * * Else, if it's something dense (walls, machinery, structures, most things other than the floor), go to splat() and get ready for some high grade shit
 *
 * If it's a carbon we hit, we'll call rollTackle() which rolls a die and calculates modifiers for both the tackler and target, then gives us a number. Negatives favor the target, while positives favor the tackler.
 * Check [rollTackle()][/datum/component/tackler/guardian/proc/rollTackle] for a more thorough explanation on the modifiers at play.
 *
 * Then, we figure out what effect we want, and we get to work! Note that with standard gripper gloves and no modifiers, the range of rolls is (-3, 3). The results are as follows, based on what we rolled:
 * * -inf to -5: Seriously botched tackle, tackler suffers a concussion, brute damage, and a 3 second paralyze, target suffers nothing
 * * -4 to -2: weak tackle, tackler gets 3 second knockdown, target gets shove slowdown but is otherwise fine
 * * -1 to 0: decent tackle, tackler gets up a bit quicker than the target
 * * 1: solid tackle, tackler has more of an advantage getting up quicker
 * * 2 to 4: expert tackle, tackler has sizeable advantage and lands on their feet with a free passive grab
 * * 5 to inf: MONSTER tackle, tackler gets up immediately and gets a free aggressive grab, target takes sizeable stamina damage from the hit and is paralyzed for one and a half seconds and knocked down for three seconds
 *
 * Finally, we return a bitflag to [COMSIG_MOVABLE_IMPACT] that forces the hitpush to false so that we don't knock them away.
*/
/datum/component/tackler/guardian/sack(mob/living/carbon/user, atom/hit)
	if(!tackling || !tackle)
		return

	if(!iscarbon(hit))
		if(hit.density)
			return splat(user, hit)
		return

	user.throw_mode_off()
	var/mob/living/carbon/target = hit
	//var/mob/living/carbon/human/S = user

	if(target.buckling)
		return splat(user, hit)

	tackling = FALSE
	tackle.gentle = TRUE

	target.apply_status_effect(/datum/status_effect/aegis, user)

	return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH

