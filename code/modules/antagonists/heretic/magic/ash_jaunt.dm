/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls, removing restraints if empowered."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "ash_shift"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	exit_jaunt_sound = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 1.3 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/red
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
	/// If we are on fire while wearing ash robes, we can empower our next cast
	var/empowered_cast = FALSE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_FIRE_STACKS_UPDATED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_FIRE_STACKS_UPDATED)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/do_jaunt(mob/living/cast_on)
	jaunt_duration = (empowered_cast ? 1.5 SECONDS : initial(jaunt_duration))
	return ..()

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/do_steam_effects()
	return

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"
