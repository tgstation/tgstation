/datum/action/cooldown/spell/touch/smite
	name = "Smite"
	desc = "This spell charges your hand with an unholy energy \
		that can be used to cause a touched victim to violently explode."
	button_icon_state = "gib"
	sound = 'sound/magic/disintegrate.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "EI NATH!!"
	sparks_amt = 4

	hand_path = /obj/item/melee/touch_attack/smite

/datum/action/cooldown/spell/touch/smite/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(!isliving(victim))
		return FALSE

	do_sparks(sparks_amt, FALSE, get_turf(victim))
	for(var/mob/living/nearby_spectator in view(caster, 7))
		if(nearby_spectator == caster)
			continue
		nearby_spectator.flash_act(affect_silicon = FALSE)

	var/mob/living/living_victim = victim
	if(living_victim.can_block_magic(antimagic_flags))
		caster.visible_message(
			span_warning("The feedback blows [caster]'s arm off!"),
			span_userdanger("The spell bounces from [living_victim]'s skin back into your arm!"),
		)
		caster.flash_act()
		var/obj/item/bodypart/to_dismember = caster.get_holding_bodypart_of_item(hand)
		to_dismember?.dismember()
		return TRUE

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		var/obj/item/clothing/suit/worn_suit = human_victim.wear_suit
		if(istype(worn_suit, /obj/item/clothing/suit/hooded/bloated_human))
			human_victim.visible_message(span_danger("[victim]'s [worn_suit] explodes off of them into a puddle of gore!"))
			human_victim.dropItemToGround(worn_suit)
			qdel(worn_suit)
			new /obj/effect/gibspawner(get_turf(victim))
			return TRUE

	living_victim.gib()
	return TRUE

/obj/item/melee/touch_attack/smite
	name = "\improper smiting touch"
	desc = "This hand of mine glows with an awesome power!"
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
