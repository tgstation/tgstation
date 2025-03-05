/datum/action/cooldown/spell/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell charges your hand with the power to turn victims into inert statues for a long period of time."
	button_icon_state = "statue"
	sound = 'sound/effects/magic/fleshtostone.ogg'

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "STAUN EI!!"

	hand_path = /obj/item/melee/touch_attack/flesh_to_stone

/datum/action/cooldown/spell/touch/flesh_to_stone/on_antimagic_triggered(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	to_chat(caster, span_warning("The spell can't seem to affect [victim]!"))
	to_chat(victim, span_warning("You feel your flesh turn to stone for a moment, then revert back!"))

/datum/action/cooldown/spell/touch/flesh_to_stone/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/living_victim = victim
	if(living_victim.can_block_magic(antimagic_flags))
		return TRUE

	living_victim.Stun(4 SECONDS)
	living_victim.petrify()
	return TRUE

/obj/item/melee/touch_attack/flesh_to_stone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "fleshtostone"
	inhand_icon_state = "fleshtostone"
