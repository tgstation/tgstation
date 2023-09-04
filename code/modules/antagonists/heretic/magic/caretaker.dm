/datum/action/cooldown/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Makes you transparent and not dense.  Cannot be used near living sentient beings. \
		While in refuge, you cannot use your hands or spells, and you are immune to slowdown. \
		You are also invincible, but pretty much cannot hurt anyone. Cancelled by being hit with an antimagic item."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	
	var/list/caretaking_traits = list(TRAIT_HANDS_BLOCKED, TRAIT_IGNORESLOWDOWN)
	var/caretaking = FALSE

/datum/action/cooldown/spell/caretaker/Remove(mob/living/remove_from)
	if(caretaking)
		stop_caretaking()
	return ..()

/datum/action/cooldown/spell/caretaker/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/caretaker/cast(atom/cast_on)
	. = ..()
	for(var/mob/living/alive in orange(5, owner))
		if(alive.stat != DEAD && alive.client)
			owner.balloon_alert(owner, "there are heathens!")
			return FALSE

	if(caretaking)
		stop_caretaking()
	else
		start_caretaking()
	return TRUE

/datum/action/cooldown/spell/caretaker/proc/nullrod_handler(datum/source, obj/item/weapon)
	SIGNAL_HANDLER
	if(weapon.GetComponent(/datum/component/anti_magic))
		stop_caretaking()
		playsound(get_turf(owner), 'sound/effects/curse1.ogg', 80, TRUE)
		owner.visible_message(span_warning("[weapon] repels the haze around [owner]!"))

/datum/action/cooldown/spell/caretaker/proc/on_focus_lost()
	SIGNAL_HANDLER
	if(caretaking)
		stop_caretaking()
		to_chat(owner, span_danger("Without a focus, your refuge weakens and dissipates!"))

/datum/action/cooldown/spell/caretaker/proc/prevent_spell_usage(datum/source, datum/spell)
	SIGNAL_HANDLER
	if(spell != src)
		owner.balloon_alert(owner, "may not cast spells in refuge!")
		return SPELL_CANCEL_CAST

/datum/action/cooldown/spell/caretaker/proc/start_caretaking()
	for(var/trait in caretaking_traits)
		ADD_TRAIT(owner, trait, MAGIC_TRAIT)
	owner.status_flags |= GODMODE
	animate(owner, alpha = 40,time = 0.5 SECONDS)
	owner.density = FALSE
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))
	RegisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(prevent_spell_usage))
	RegisterSignal(owner, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(nullrod_handler))
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	caretaking = TRUE

/datum/action/cooldown/spell/caretaker/proc/stop_caretaking()
	for(var/trait in caretaking_traits)
		REMOVE_TRAIT(owner, trait, MAGIC_TRAIT)
	owner.status_flags &= ~GODMODE
	owner.alpha = initial(owner.alpha)
	owner.density = initial(owner.density)
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	UnregisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST)
	UnregisterSignal(owner, COMSIG_ATOM_AFTER_ATTACKEDBY)
	UnregisterSignal(owner, COMSIG_ATOM_EXAMINE)
	owner.visible_message(
			span_warning("The haze around [owner] disappears, leaving them materialized!"),
			span_notice("You exit the refuge."),
		)
	caretaking = FALSE

/datum/action/cooldown/spell/caretaker/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("[user.p_Theyre()] enveloped in an unholy haze!")
