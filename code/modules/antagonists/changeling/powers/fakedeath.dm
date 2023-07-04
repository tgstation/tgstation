/datum/action/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_death"
	chemical_cost = 15
	dna_cost = CHANGELING_POWER_INNATE
	req_dna = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE

	/// How long it takes for revival to ready upon entering stasis.
	/// The changelin can opt to stay in fakedeath for longer, though.
	var/fakedeath_duration = 40 SECONDS
	/// If TRUE, we're ready to revive and can click the button to heal.
	var/revive_ready = FALSE

//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fakedeath/sting_action(mob/living/user)
	..()
	if(revive_ready)
		INVOKE_ASYNC(src, PROC_REF(revive), user)
		disable_revive(user) // this should be already called via signal, but just incase something wacky happens

	else
		to_chat(user, span_notice("We begin our stasis, preparing energy to arise once more."))
		enable_fakedeath(user)

	return TRUE

/// Used to enable fakedeath and register relevant signals / start timers
/datum/action/changeling/fakedeath/proc/enable_fakedeath(mob/living/changeling)
	if(revive_ready || HAS_TRAIT_FROM(changeling, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		return

	changeling.fakedeath(CHANGELING_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), changeling), fakedeath_duration, TIMER_UNIQUE)
	RegisterSignal(changeling, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA), PROC_REF(fakedeath_reset))

/// Sets [revive_ready] to FALSE and updates the button icons.
/datum/action/changeling/fakedeath/proc/disable_revive(mob/living/changeling)
	if(!revive_ready)
		return

	chemical_cost = 15
	revive_ready = FALSE
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)
	UnregisterSignal(changeling, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA))

/// Sets [revive_ready] to TRUE and updates the button icons.
/datum/action/changeling/fakedeath/proc/enable_revive(mob/living/changeling)
	if(revive_ready)
		return

	chemical_cost = 0
	revive_ready = TRUE
	build_all_button_icons(UPDATE_BUTTON_NAME|UPDATE_BUTTON_ICON)

/// Signal proc to stop the revival process if the changeling exits their stasis early.
/datum/action/changeling/fakedeath/proc/fakedeath_reset(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT_FROM(source, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		return

	disable_revive(source)

/datum/action/changeling/fakedeath/proc/revive(mob/living/carbon/user)
	if(!istype(user))
		return
	if(!HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		return

	user.cure_fakedeath(CHANGELING_TRAIT)
	// Heal all damage and some minor afflictions,
	var/flags_to_heal = (HEAL_DAMAGE|HEAL_BODY|HEAL_STATUS|HEAL_CC_STATUS)
	// but leave out limbs so we can do it specially
	user.revive(flags_to_heal & ~HEAL_LIMBS)
	to_chat(user, span_notice("We have revived ourselves."))

	var/static/list/dont_regenerate = list(BODY_ZONE_HEAD) // headless changelings are funny
	if(!length(user.get_missing_limbs() - dont_regenerate))
		return

	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	user.visible_message(
		span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
		span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
		span_hear("You hear organic matter ripping and tearing!"),
	)
	user.emote("scream")
	// Manually call this (outside of revive/fullheal) so we can pass our blacklist
	user.regenerate_limbs(dont_regenerate)

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(QDELETED(src) || QDELETED(user))
		return

	var/datum/antagonist/changeling/ling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(QDELETED(ling) || !(src in ling.innate_powers + ling.purchased_powers)) // checking both innate and purchased for full coverage
		return
	if(!HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		return

	to_chat(user, span_notice("We are ready to revive."))
	enable_revive(user)

/datum/action/changeling/fakedeath/can_sting(mob/living/user)
	if(revive_ready)
		return ..()

	if(!can_enter_stasis(user))
		return
	//Confirmation for living changelings if they want to fake their death
	if(user.stat != DEAD)
		if(tgui_alert(user, "Are we sure we wish to fake our own death?", "Feign Death", list("Yes", "No")) != "Yes")
			return
		if(QDELETED(user) || QDELETED(src) || !can_enter_stasis(user))
			return

	return ..()

/datum/action/changeling/fakedeath/proc/can_enter_stasis(mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_DEATHCOMA, CHANGELING_TRAIT))
		user.balloon_alert(user, "already reviving!")
		return FALSE
	return TRUE

/datum/action/changeling/fakedeath/update_button_name(atom/movable/screen/movable/action_button/button, force)
	if(revive_ready)
		name = "Revive"
		desc = "We arise once more."
	else
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
	return ..()

/datum/action/changeling/fakedeath/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = revive_ready ? "revive" : "fake_death"
	return ..()
