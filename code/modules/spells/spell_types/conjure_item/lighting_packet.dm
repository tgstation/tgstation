
/datum/action/cooldown/spell/conjure_item/spellpacket
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a bolt of pure power, \
		a lightning bolt will appear in your hand, that - when thrown - will stun the target."
	button_icon_state = "thrownlightning"

	cooldown_time = 1 SECONDS
	spell_max_level = 1

	item_type = /obj/item/spellpacket/lightningbolt
	requires_hands = TRUE

/datum/action/cooldown/spell/conjure_item/spellpacket/cast(mob/living/carbon/cast_on)
	. = ..()
	cast_on.throw_mode_on(THROW_MODE_TOGGLE)

/obj/item/spellpacket/lightningbolt
	name = "\improper Lightning bolt"
	desc = "A bolt of power, crackles with electricity."
	icon = 'icons/obj/weapons/thrown.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/thrown_righthand.dmi'
	icon_state = "lightning"
	w_class = WEIGHT_CLASS_TINY

/obj/item/spellpacket/lightningbolt/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return

	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(!hit_living.can_block_magic())
			hit_living.electrocute_act(80, src, flags = SHOCK_ILLUSION | SHOCK_NOGLOVES)
		playsound(src, 'sound/effects/magic/lightningshock.ogg', 50, TRUE)
	qdel(src)

/obj/item/spellpacket/lightningbolt/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = INFINITY, gentle, quickstart = TRUE, throw_type_path = /datum/thrownthing)
	. = ..()
	if(ishuman(thrower))
		var/mob/living/carbon/human/human_thrower = thrower
		human_thrower.say("LIGHTNINGBOLT!!", forced = "spell")
