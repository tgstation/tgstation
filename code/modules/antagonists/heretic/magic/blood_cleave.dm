/datum/action/cooldown/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The radius of the cleave effect
	var/cleave_radius = 1

/datum/action/cooldown/spell/pointed/cleave/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/cleave/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/list/mob/living/carbon/human/nearby = list(cast_on)
	for(var/mob/living/carbon/human/nearby_human in range(cleave_radius, cast_on))
		nearby += nearby_human

	for(var/mob/living/carbon/human/victim as anything in nearby)
		if(victim == owner)
			continue
		if(victim.can_block_magic())
			victim.visible_message(
				span_danger("[victim]'s flashes in a firey glow, but repels the blaze!"),
				span_danger("Your body begins to flash a firey glow, but you are protected!!")
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			span_danger("[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!"),
			span_danger("Your veins burst from within and unholy flame erupts from your blood!")
		)

		var/obj/item/bodypart/bodypart = pick(victim.bodyparts)
		var/datum/wound/slash/critical/crit_wound = new()
		crit_wound.apply_wound(bodypart)
		victim.apply_damage(20, BURN, wound_bonus = CANT_WOUND)

		new /obj/effect/temp_visual/cleave(victim.drop_location())

	return TRUE

/datum/action/cooldown/spell/pointed/cleave/long
	name = "Lesser Cleave"
	cooldown_time = 65 SECONDS

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
