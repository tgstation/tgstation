/datum/action/cooldown/spell/conjure/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "artificer"
	sound = 'sound/magic/summonitems_generic.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	range = 0

	summon_type = list(/obj/structure/constructshell)
