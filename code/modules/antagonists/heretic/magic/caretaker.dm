/datum/action/cooldown/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Completely conceals your identity, but does not make you invisible.  Can be activated early to disable it. \
		While cloaked, you move faster, but undergo actions much slower. \
		Taking damage while cloaked may cause it to lift suddenly, causing negative effects. "
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 6 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	
	var/caretaking_traits = list(TRAIT_HANDS_BLOCKED, GODMODE)
	var/caretaking = FALSE

/datum/action/cooldown/spell/caretaker/Remove(mob/living/remove_from)
	stop_caretaking()
	return ..()

/datum/action/cooldown/spell/caretaker/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/caretaker/cast(atom/cast_on)
	if(caretaking)
		start_caretaking()
	else
		stop_caretaking()
	return TRUE

/datum/action/cooldown/spell/caretaker/proc/on_focus_lost()
	SIGNAL_HANDLER
	stop_caretaking()
	to_chat(owner, span_danger("Without a focus, your refuge weakens and dissipates"))

/datum/action/cooldown/spell/caretaker/proc/start_caretaking()
	for(var/trait in caretaking_traits)
		ADD_TRAIT(owner, trait, MAGIC_TRAIT)
	animate(owner, alpha = 80,time = 10)
	owner.density = FALSE
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))

/datum/action/cooldown/spell/caretaker/proc/stop_caretaking()
	for(var/trait in caretaking_traits)
		REMOVE_TRAIT(owner, trait, MAGIC_TRAIT)
	owner.alpha = initial(owner.alpha)
	owner.density = initial(owner.density)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))