/datum/martial_art
	/// Player readable name of the martial art
	var/name = "Martial Art"
	/// ID of the martial art
	var/id = ""
	/// The streak of attacks the user has performed
	var/streak = ""
	/// The maximum length of streaks allowed
	var/max_streak_length = 6

	/// The current mob associated with this martial art datum. Do not set directly.
	VAR_PRIVATE/mob/living/holder
	/// Weakref to the last mob we attacked, for determining when to reset streaks
	VAR_PRIVATE/datum/weakref/current_target
	/// Used for temporary martial arts.
	/// This is a reference to the last martial art that was replaced by this one.
	VAR_PRIVATE/datum/martial_art/base

	/// Path to verb to display help text for this martial art.
	var/help_verb
	/// If TRUE, this martial art can be overridden and stored (via base) by other martial arts if deemed "temporary" via teach().
	var/allow_temp_override = TRUE
	/// If TRUE, this martial art smashes tables when performing table slams and head smashes
	var/smashes_tables = FALSE
	/// If TRUE, a combo meter will be displayed on the HUD for the current streak
	var/display_combos = FALSE
	/// The length of time until streaks are auto-reset.
	var/combo_timer = 6 SECONDS
	/// Timer ID for the combo reset timer.
	var/timerid
	/// If TRUE, this style allows you to punch people despite being a pacifist (IE: Boxing, which does no damage)
	var/pacifist_style = FALSE

/datum/martial_art/Destroy()
	if(!isnull(holder))
		remove(holder)
	return ..()

/datum/martial_art/serialize_list(list/options, list/semvers)
	. = ..()

	.["name"] = name
	.["id"] = id
	.["pacifist_style"] = pacifist_style

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

/// Signal proc for [COMSIG_LIVING_UNARMED_ATTACK] to hook into the appropriate proc
/datum/martial_art/proc/unarmed_strike(mob/living/source, atom/attack_target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!proximity || !isliving(attack_target))
		return NONE

	if(HAS_TRAIT(attack_target, TRAIT_MARTIAL_ARTS_IMMUNE))
		return NONE

	if(!can_use(source))
		return NONE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return disarm_act(source, attack_target)

	if(source.combat_mode)
		if(HAS_TRAIT(source, TRAIT_PACIFISM) && !pacifist_style)
			return NONE

		return harm_act(source, attack_target)

	return help_act(source, attack_target)

/// Signal proc for [COMSIG_LIVING_GRAB] to hook into the grab
/datum/martial_art/proc/attempt_grab(mob/living/source, mob/living/grabbing)
	SIGNAL_HANDLER

	if(HAS_TRAIT(grabbing, TRAIT_MARTIAL_ARTS_IMMUNE))
		return NONE

	if(!source.can_unarmed_attack()) // For parity with unarmed attacks
		return NONE

	if(!can_use(source))
		return NONE

	return grab_act(source, grabbing)

/**
 * Called when help-intenting on someone
 *
 * What is checked going into this:
 * Adjacency, [TRAIT_MARTIAL_ARTS_IMMUNE], attacker incapacitated, can_unarmed_attack, can_use
 *
 * What is NOT:
 * check_block
 *
 * Arguments
 * * mob/living/attacker - The mob attacking
 * * mob/living/defender - The mob being attacked
 *
 * Returns
 * * MARTIAL_ATTACK_INVALID - The attack is not valid, do normal unarmed attack
 * * MARTIAL_ATTACK_FAIL - The attack is valid, but failed. No followup attack is made.
 * * MARTIAL_ATTACK_SUCCESS - The attack is valid, and succeeded. No followup attack is made.
 */
/datum/martial_art/proc/help_act(mob/living/attacker, mob/living/defender)
	SHOULD_CALL_PARENT(FALSE)
	PROTECTED_PROC(TRUE)
	return MARTIAL_ATTACK_INVALID

/**
 * Called when disarm-intenting on someone
 *
 * What is checked going into this:
 * Adjacency, [TRAIT_MARTIAL_ARTS_IMMUNE], attacker incapacitated, can_unarmed_attack, can_use
 *
 * What is NOT:
 * check_block
 *
 * Arguments
 * * mob/living/attacker - The mob attacking
 * * mob/living/defender - The mob being attacked
 *
 * Returns
 * * MARTIAL_ATTACK_INVALID - The attack is not valid, do normal unarmed attack
 * * MARTIAL_ATTACK_FAIL - The attack is valid, but failed. No followup attack is made.
 * * MARTIAL_ATTACK_SUCCESS - The attack is valid, and succeeded. No followup attack is made.
 */
/datum/martial_art/proc/disarm_act(mob/living/attacker, mob/living/defender)
	SHOULD_CALL_PARENT(FALSE)
	PROTECTED_PROC(TRUE)
	return MARTIAL_ATTACK_INVALID

/**
 * Called when harm-intenting on someone
 *
 * What is checked going into this:
 * Adjacency, [TRAIT_MARTIAL_ARTS_IMMUNE], attacker incapacitated, can_unarmed_attack, can_use
 *
 * What is NOT:
 * check_block
 *
 * Arguments
 * * mob/living/attacker - The mob attacking
 * * mob/living/defender - The mob being attacked
 *
 * Returns
 * * MARTIAL_ATTACK_INVALID - The attack is not valid, do normal unarmed attack
 * * MARTIAL_ATTACK_FAIL - The attack is valid, but failed. No followup attack is made.
 * * MARTIAL_ATTACK_SUCCESS - The attack is valid, and succeeded. No followup attack is made.
 */
/datum/martial_art/proc/harm_act(mob/living/attacker, mob/living/defender)
	SHOULD_CALL_PARENT(FALSE)
	PROTECTED_PROC(TRUE)
	return MARTIAL_ATTACK_INVALID

/**
 * Called when grabbing someone
 *
 * What is checked going into this:
 * Adjacency, [TRAIT_MARTIAL_ARTS_IMMUNE], attacker incapacitated, can_unarmed_attack, can_use
 *
 * What is NOT:
 * check_block
 *
 * Arguments
 * * mob/living/attacker - The mob attacking
 * * mob/living/defender - The mob being attacked
 *
 * Returns
 * * MARTIAL_ATTACK_INVALID - The attack is not valid, do normal unarmed attack
 * * MARTIAL_ATTACK_FAIL - The attack is valid, but failed. No followup attack is made.
 * * MARTIAL_ATTACK_SUCCESS - The attack is valid, and succeeded. No followup attack is made.
 */
/datum/martial_art/proc/grab_act(mob/living/attacker, mob/living/defender)
	SHOULD_CALL_PARENT(FALSE)
	PROTECTED_PROC(TRUE)
	return MARTIAL_ATTACK_INVALID

/**
 * Checks if the passed mob can use this martial art.
 *
 * Arguments
 * * mob/living/martial_artist - The mob to check
 *
 * Returns
 * * TRUE - The mob can use this martial art
 * * FALSE - The mob cannot use this martial art
 */
/datum/martial_art/proc/can_use(mob/living/martial_artist)
	return TRUE

/**
 * Adds the passed element to the current streak, resetting it if the target is not the same as the last target.
 *
 * Arguments
 * * element - The element to add to the streak. This is some one letter string.
 * * mob/living/defender - The mob being attacked
 */
/datum/martial_art/proc/add_to_streak(element, mob/living/defender)
	if(!IS_WEAKREF_OF(defender, current_target))
		reset_streak(defender)
	streak += element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	if(display_combos)
		timerid = addtimer(CALLBACK(src, PROC_REF(reset_streak), null, FALSE), combo_timer, TIMER_UNIQUE | TIMER_STOPPABLE)
		holder.hud_used?.combo_display.update_icon_state(streak, combo_timer - 2 SECONDS)

/**
 * Resets the current streak.
 *
 * Arguments
 * * mob/living/new_target - (Optional) The mob being attacked while the reset is occurring.
 * * update_icon - If TRUE, the combo display will be updated.
 */
/datum/martial_art/proc/reset_streak(mob/living/new_target, update_icon = TRUE)
	if(timerid)
		deltimer(timerid)
	current_target = WEAKREF(new_target)
	streak = ""
	if(display_combos && update_icon)
		holder.hud_used?.combo_display.update_icon_state(streak)

/**
 * Teaches the passed mob this martial art.
 *
 * Arguments
 * * mob/living/new_holder - The mob to teach this martial art to.
 * * make_temporary - If FALSE, this martial art will completely replace any existing martial arts.
 * If TRUE, any existing martial art will be stored in the base variable, and will be restored when this martial art is removed.
 * This can only occur if allow_temp_override is TRUE.
 *
 * Returns
 * * TRUE - The martial art was successfully taught.
 * * FALSE - The mob failed to learn the martial art, for whatever reason.
 */
/datum/martial_art/proc/teach(mob/living/new_holder, make_temporary = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(!istype(new_holder) || isnull(new_holder.mind))
		return FALSE

	var/datum/martial_art/existing_martial = new_holder.mind.martial_art
	if(!isnull(existing_martial))
		if(make_temporary && !existing_martial.allow_temp_override)
			return FALSE

		if(!isnull(existing_martial.base))
			store_martial_art(existing_martial.base)
			existing_martial.unstore_martial_art()
		else if(make_temporary)
			store_martial_art(existing_martial)

		// Nulls out any existing martial art, it'll get GC'd if nothing owns it
		existing_martial.remove(new_holder)

	new_holder.mind.martial_art = src
	holder = new_holder
	on_teach(new_holder)
	return TRUE

/// Stores the passed martial art in the base var.
/datum/martial_art/proc/store_martial_art(datum/martial_art/martial)
	if(!isnull(base))
		UnregisterSignal(base, COMSIG_QDELETING)

	base = martial
	RegisterSignal(base, COMSIG_QDELETING, PROC_REF(base_deleted))

/// Unstores the base var.
/datum/martial_art/proc/unstore_martial_art()
	UnregisterSignal(base, COMSIG_QDELETING)
	base = null

/datum/martial_art/proc/base_deleted(datum/source)
	SIGNAL_HANDLER
	base = null

/**
 * Removes this martial art from the passed mob AND their mind.
 *
 * Arguments
 * * mob/living/old_holder - The mob to remove this martial art from.
 */
/datum/martial_art/proc/remove(mob/living/old_holder)
	SHOULD_CALL_PARENT(TRUE)

	ASSERT(old_holder == holder)
	ASSERT(old_holder.mind.martial_art == src)

	on_remove(old_holder)
	old_holder.mind.martial_art = null
	if(!isnull(base))
		base.teach(old_holder)
		unstore_martial_art()
	holder = null

/**
 * A helper proc to remove the martial art from the passed mob fully, e
 * ven if stored in another martial art's base.
 *
 * Arguments
 * * mob/living/maybe_holder - The mob to check.
 *
 * Returns
 * * TRUE - If the martial art was removed in some way
 * * FALSE - If nothing happened
 */
/datum/martial_art/proc/fully_remove(mob/living/maybe_holder)
	var/datum/martial_art/holder_art = maybe_holder.mind?.martial_art
	if(isnull(holder_art))
		return FALSE

	if(holder_art == src)
		remove(maybe_holder)
		return TRUE

	if(holder_art.base == src)
		holder_art.unstore_martial_art()
		return TRUE

	return FALSE

/**
 * Called when this martial art is added to a mob.
 */
/datum/martial_art/proc/on_teach(mob/living/new_holder)
	if(help_verb)
		add_verb(new_holder, help_verb)
	RegisterSignal(new_holder, COMSIG_QDELETING, PROC_REF(holder_deleted))
	RegisterSignal(new_holder, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(unarmed_strike))
	RegisterSignal(new_holder, COMSIG_LIVING_GRAB, PROC_REF(attempt_grab))
	RegisterSignal(new_holder, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, PROC_REF(transfer_martial_arts))

/**
 * Called when this martial art is removed from a mob.
 */
/datum/martial_art/proc/on_remove(mob/living/remove_from)
	if(help_verb)
		remove_verb(remove_from, help_verb)
	UnregisterSignal(remove_from, list(COMSIG_QDELETING, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_LIVING_GRAB, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF))

/datum/martial_art/proc/holder_deleted(datum/source)
	SIGNAL_HANDLER
	holder = null

/// Signal proc for [COMSIG_MOB_MIND_TRANSFERRED_OUT_OF] to pass martial arts between bodies on mind transfer
/// By this point the martial art's holder is the old body, but the mind that owns it is in the new body
/datum/martial_art/proc/transfer_martial_arts(mob/living/old_body, mob/living/new_body)
	SIGNAL_HANDLER

	// This has some notable issues in that martial arts granted by items like Krav Maga
	// will follow the body swap, the easiest fix would be to move martial arts off of the mind

	if(!isnull(base)) // If we're home to a temporary one just don't touch it, give the base to the new body and leave it at that
		base.teach(new_body)
		unstore_martial_art()
		return

	on_remove(old_body) // on_remove rather than remove, because by this point the mind is already in the new body, which remove handles.
	teach(new_body)
