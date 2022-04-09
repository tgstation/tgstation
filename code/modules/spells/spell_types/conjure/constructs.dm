/datum/action/cooldown/spell/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "artificer"
	sound = 'sound/magic/summonitems_generic.ogg'

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/constructshell)

/datum/action/cooldown/spell/conjure/construct/lesser
	background_icon_state = "bg_demon"
	cooldown_time = 3 MINUTES

/datum/action/cooldown/spell/conjure/construct/lesser/cult
	cooldown_time = 250 SECONDS
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB // MELBERT TODO
