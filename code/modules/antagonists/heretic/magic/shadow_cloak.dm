/datum/action/cooldown/spell/shadow_cloak
	name = "Shadow CLoak"
	desc = "Completely conceals your identity. Does not make you invisible. Can be activated early to disable it again. "
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 3 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/cooldown/spell/shadow_cloak/Remove(mob/living/remove_from)
	uncloak_mob(remove_from)
	return ..()

/datum/action/cooldown/spell/shadow_cloak/before_cast(atom/cast_on)
	. = ..()
	sound = pick(
		'sound/effects/curse1.ogg',
		'sound/effects/curse2.ogg',
		'sound/effects/curse3.ogg',
		'sound/effects/curse4.ogg',
		'sound/effects/curse5.ogg',
		'sound/effects/curse6.ogg',
	)

/datum/action/cooldown/spell/shadow_cloak/cast(atom/cast_on)
	. = ..()
	cloak_mob(cast_on)
	addtimer(CALLBACK(src, .proc/timed_uncloak, cast_on), 3 MINUTES)

/datum/action/cooldown/spell/shadow_cloak/proc/timed_uncloak(atom/cast_on)
	if(QDELETED(src) || QDELETED(cast_on))
		return

	uncloak_mob(cast_on)
	StartCooldown(1 MINUTE)

/datum/action/cooldown/spell/shadow_cloak/proc/cloak_mob(atom/cast_on)
	if(HAS_TRAIT_FROM(cast_on, TRAIT_UNKNOWN, name))
		return

	playsound(cast_on, 'sound/chemistry/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
	ADD_TRAIT(cast_on, TRAIT_UNKNOWN, name)
	ADD_TRAIT(cast_on, TRAIT_SILENT_FOOTSTEPS, name)

/datum/action/cooldown/spell/shadow_cloak/proc/uncloak_mob(atom/cast_on)
	if(!HAS_TRAIT_FROM(cast_on, TRAIT_UNKNOWN, name))
		return

	playsound(cast_on, 'sound/effects/curseattack.ogg', 50)
	REMOVE_TRAIT(cast_on, TRAIT_UNKNOWN, name)
	REMOVE_TRAIT(cast_on, TRAIT_SILENT_FOOTSTEPS, name)
