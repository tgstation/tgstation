/datum/action/cooldown/spell/conjure/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "artificer"
	sound = 'sound/magic/summonitems_generic.ogg'

	school = SCHOOL_CONJURATION
	charge_max = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	range = 0

	summon_type = list(/obj/structure/constructshell)
