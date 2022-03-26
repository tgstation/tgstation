
/datum/action/cooldown/spell/pointed/projectile/finger_guns
	name = "Finger Guns"
	desc = "Shoot up to three mimed bullets from your fingers that damage and mute their targets. \
		Can't be used if you have something in your hands."
	background_icon_state = "bg_mime"
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "finger_guns0"
	panel = "Mime"

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	spell_requirements = (SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_HUMAN)
	spell_max_level = 1

	invocation_type = INVOCATION_EMOTE
	invocation_self_message = span_danger("You fire your finger gun!")

	base_icon_state = "finger_guns"
	active_msg = "You draw your fingers!"
	deactive_msg = "You put your fingers at ease. Another time."
	cast_range = 20
	projectile_type = /obj/projectile/bullet/mime
	projectile_amount = 3

/datum/action/cooldown/spell/pointed/projectile/finger_guns/New()
	. = ..()
	AddComponent(/datum/component/mime_spell, CALLBACK(src, .proc/get_invocation_content))

/datum/action/cooldown/spell/pointed/projectile/finger_guns/proc/get_invocation_content(mob/living/carbon/human/caster)
	return "<b>[caster.real_name]</b> fires [caster.p_their()] finger gun!"

/datum/action/cooldown/spell/pointed/projectile/finger_guns/can_invoke(feedback = TRUE)
	if(invocation_type == INVOCATION_EMOTE)
		if(!ishuman(owner))
			return FALSE

		var/mob/living/carbon/human/human_owner = owner
		if(human_owner.incapacitated())
			if(feedback)
				to_chat(owner, span_warning("You can't properly point your fingers while incapacitated."))
			return FALSE
		if(human_owner.get_active_held_item())
			if(feedback)
				to_chat(owner, span_warning("You can't properly fire your finger guns with something in your hand."))
			return FALSE

	return ..()
