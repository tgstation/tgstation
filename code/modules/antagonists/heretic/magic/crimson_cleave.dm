/datum/action/cooldown/spell/pointed/crimson_cleave
	name = "Crimson Cleave"
	desc = "A targeted spell that heals you while damaging the enemy. \
		It cleanses you of all wounds as well."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "FL'MS O'ET'RN'ITY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 5

	/// The radius of the cleave effect
	var/cleave_radius = 1
	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/flesh/critical/cleave

/datum/action/cooldown/spell/pointed/crimson_cleave/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/cooldown/spell/pointed/crimson_cleave/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/crimson_cleave/cast(atom/cast_on)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		for(var/obj/item/bodypart/limbs as anything in carbon_owner.bodyparts)
			for(var/datum/wound/iter_wound as anything in limbs.wounds)
				iter_wound.remove_wound()

	var/mob/living/living_owner = owner
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				span_danger("[victim]'s flashes in a firey glow, but repels the blaze!"),
				span_danger("Your body begins to flash a firey glow, but you are protected!!")
			)
			continue

		victim.visible_message(
			span_danger("[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!"),
			span_danger("Your veins burst from within and unholy flame erupts from your blood!")
		)

		victim.apply_damage(15, BRUTE, wound_bonus = CANT_WOUND)
		living_owner.adjustBruteLoss(-15)

		if(victim.blood_volume)
			victim.blood_volume -= 15
			if(living_owner.blood_volume && living_owner.blood_volume < (BLOOD_VOLUME_MAXIMUM - 50))
				living_owner.blood_volume += 15

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE
