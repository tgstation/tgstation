/datum/action/cooldown/spell/return_back
	name = "Return"
	desc = "Activates your return beacon."
	sound = 'sound/magic/Repulse.ogg'
	button_icon_state = "lightning"
	spell_requirements = NONE
	invocation = "Return on!"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_EVOCATION


/datum/action/cooldown/spell/return_back/can_cast_spell(feedback)
	return TRUE


/datum/action/cooldown/spell/return_back/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	if(!istype(cast_on))
		return

	var/mob/dead/observer/ghost = user.ghostize(FALSE)

	var/datum/effect_system/spark_spread/quantum/sparks = new
	sparks.set_up(10, 1, user)
	sparks.attach(user.loc)
	sparks.start()

	qdel(user)


	// Get them back to their regular name.
	ghost.set_ghost_appearance()
	if(ghost.client && ghost.client.prefs)
		ghost.deadchat_name = ghost.client.prefs?.read_preference(/datum/preference/name/real_name)
