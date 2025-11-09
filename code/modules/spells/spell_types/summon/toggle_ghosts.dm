/datum/action/cooldown/spell/toggle_ghosts
	name = "Toggle Ghosts"
	desc = ""
	button_icon = 'icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"
	spell_requirements = NONE

/datum/action/cooldown/spell/toggle_ghosts/proc/hide_ghosts(mob/living/cast_on)
	cast_on.set_invis_see(SEE_INVISIBLE_LIVING)

/datum/action/cooldown/spell/toggle_ghosts/proc/show_ghosts(mob/living/cast_on)
	cast_on.set_invis_see(SEE_INVISIBLE_GHOSTS)

/datum/action/cooldown/spell/toggle_ghosts/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.see_invisible == SEE_INVISIBLE_GHOSTS)
		hide_ghosts(cast_on)
	else
		show_ghosts(cast_on)
