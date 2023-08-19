/datum/action/cooldown/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1
	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/flesh/critical/cleave

/datum/action/cooldown/spell/pointed/cleave/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/cleave/cast(mob/living/carbon/human/cast_on)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
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
		var/datum/wound/slash/flesh/crit_wound = new wound_type()
		crit_wound.apply_wound(bodypart)
		victim.apply_damage(20, BURN, wound_bonus = CANT_WOUND)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/action/cooldown/spell/pointed/cleave/long
	name = "Lesser Cleave"
	cooldown_time = 60 SECONDS
	wound_type = /datum/wound/slash/flesh/severe

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
