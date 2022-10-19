/datum/action/cooldown/spell/shadow_cloak
	name = "Shadow Cloak"
	desc = "Completely conceals your identity, but does not make you invisible. \
		Can be activated early to disable it. "
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 6 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	/// How long before we automatically uncloak?
	var/uncloak_time = 3 MINUTES
	/// A timer id, for the uncloak timer
	var/uncloak_timer
	/// The cloak image we overlay on the caster
	var/image/cloak_image

/datum/action/cooldown/spell/shadow_cloak/Remove(mob/living/remove_from)
	uncloak_mob(remove_from)
	return ..()

/datum/action/cooldown/spell/shadow_cloak/before_cast(atom/cast_on)
	. = ..()
	cooldown_time = initial(cooldown_time)
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
	if(cloak_image)
		cooldown_time = max(1 MINUTES - (timeleft(uncloak_timer) / 3), 6 SECONDS)
		uncloak_mob(cast_on)

	else
		cloak_mob(cast_on)
		uncloak_timer = addtimer(CALLBACK(src, .proc/timed_uncloak, cast_on), uncloak_time, TIMER_STOPPABLE)

/datum/action/cooldown/spell/shadow_cloak/proc/timed_uncloak(atom/cast_on)
	if(QDELETED(src) || QDELETED(cast_on))
		return

	uncloak_mob(cast_on)
	StartCooldown(1 MINUTES)

/datum/action/cooldown/spell/shadow_cloak/proc/cloak_mob(atom/cast_on)
	if(cloak_image)
		return

	// Make them appear shadowy
	cloak_image = image('icons/effects/effects.dmi', cast_on, "curse", dir = cast_on.dir)
	cloak_image.override = TRUE
	cast_on.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, name, cloak_image)

	playsound(cast_on, 'sound/chemistry/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
	ADD_TRAIT(cast_on, TRAIT_UNKNOWN, name)
	ADD_TRAIT(cast_on, TRAIT_SILENT_FOOTSTEPS, name)
	cast_on.AddElement(/datum/element/shadow_trail)
	RegisterSignal(cast_on, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)
	RegisterSignal(cast_on, COMSIG_LIVING_SET_BODY_POSITION, .proc/on_body_position_change)
	RegisterSignal(cast_on, COMSIG_MOB_STATCHANGE, .proc/on_stat_change)
	RegisterSignal(cast_on, COMSIG_MOB_APPLY_DAMAGE, .proc/on_damaged)

/datum/action/cooldown/spell/shadow_cloak/proc/uncloak_mob(atom/cast_on)
	if(!cloak_image)
		return

	deltimer(uncloak_timer)
	uncloak_timer = null
	cast_on.remove_alt_appearance(name)
	QDEL_NULL(cloak_image)

	playsound(cast_on, 'sound/effects/curseattack.ogg', 50)
	REMOVE_TRAIT(cast_on, TRAIT_UNKNOWN, name)
	REMOVE_TRAIT(cast_on, TRAIT_SILENT_FOOTSTEPS, name)
	cast_on.RemoveElement(/datum/element/shadow_trail)
	UnregisterSignal(cast_on, list(COMSIG_ATOM_DIR_CHANGE,
		COMSIG_LIVING_SET_BODY_POSITION,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_APPLY_DAMAGE,
	))

/datum/action/cooldown/spell/shadow_cloak/proc/on_dir_change(datum/source, dir, newdir)
	SIGNAL_HANDLER

	cloak_image?.dir = newdir

/datum/action/cooldown/spell/shadow_cloak/proc/on_body_position_change(datum/source, new_value)
	SIGNAL_HANDLER

	/*
	if(new_value == LYING_DOWN)
		cloak_image.transform = turn(cloak_image.transform, 90)
	else
		cloak_image.transform = turn(cloak_image.transform, -90)
	*/
	to_chat(source, "Test")

/datum/action/cooldown/spell/shadow_cloak/proc/on_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	if(new_stat >= UNCONSCIOUS)
		uncloak_mob(source)

/datum/action/cooldown/spell/shadow_cloak/proc/on_damaged(datum/source, damage, damagetype)
	SIGNAL_HANDLER

	if(damage < 5)
		return

	if(prob(damage + 25))
		uncloak_mob(source)
