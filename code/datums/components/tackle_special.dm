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

/datum/component/tackler/guardian/sack(mob/living/carbon/user, atom/hit)
	if(!tackling || !tackle)
		return

	if(!iscarbon(hit))
		if(hit.density)
			return splat(user, hit)
		return

	user.throw_mode_off()
	var/mob/living/carbon/target = hit
	if(target.buckling)
		return splat(user, hit)

	tackling = FALSE
	tackle.gentle = TRUE

	target.apply_status_effect(STATUS_EFFECT_AEGIS, user)

	return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH
