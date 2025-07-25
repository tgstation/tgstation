/datum/martial_art
	/// Player readable name of the martial art
	var/name = "Martial Art"
	/// ID of the martial art
	var/id = ""
	/// The streak of attacks the user has performed
	VAR_FINAL/streak = ""
	/// The maximum length of streaks allowed
	var/max_streak_length = 6

	/// Are we being actively used by a mob?
	var/active = FALSE
	/// Where this martial art is from, sometimes the same as the holder if it's tied to them
	/// If the origin is deleted, this martial art will be too.
	VAR_PRIVATE/datum/origin
	/// The current mob associated with this martial art datum. Do not set directly.
	VAR_PRIVATE/mob/living/holder
	/// Weakref to the last mob we attacked, for determining when to reset streaks
	VAR_PRIVATE/datum/weakref/current_target

	/// Path to verb to display help text for this martial art.
	var/help_verb
	/// If TRUE, this martial art smashes tables when performing table slams and head smashes
	var/smashes_tables = FALSE
	/// If TRUE, a combo meter will be displayed on the HUD for the current streak
	var/display_combos = FALSE
	///The Combo HUD given to display comboes, if we're set to display them.
	var/atom/movable/screen/combo/combo_display
	/// The length of time until streaks are auto-reset.
	var/combo_timer = 6 SECONDS
	/// Timer ID for the combo reset timer.
	var/timerid
	/// If TRUE, this style allows you to punch people despite being a pacifist (IE: Boxing, which does no damage)
	var/pacifist_style = FALSE
	/// If TRUE, the user is locked to using this martial art, and can't swap to other ones they know.
	/// If the mob has two locked martial arts, it's first come first serve.
	var/locked_to_use = FALSE

/datum/martial_art/serialize_list(list/options, list/semvers)
	. = ..()

	.["name"] = name
	.["id"] = id
	.["pacifist_style"] = pacifist_style

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

/datum/martial_art/New(datum/new_origin)
	set_origin(new_origin)

/datum/martial_art/Destroy()
	if(!isnull(holder))
		unlearn(holder)
	if(!isnull(origin))
		set_origin(null)
	return ..()

/datum/martial_art/proc/set_origin(datum/new_origin)
	if(origin)
		UnregisterSignal(origin, COMSIG_QDELETING)
		origin = null
	if(isnull(new_origin))
		return
	src.origin = new_origin
	RegisterSignal(origin, COMSIG_QDELETING, PROC_REF(clear_origin))

/datum/martial_art/proc/clear_origin()
	SIGNAL_HANDLER
	qdel(src)

/datum/martial_art/proc/clear_holder(datum/source)
	SIGNAL_HANDLER
	unlearn(holder)

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
		combo_display.update_icon_state(streak, combo_timer - 2 SECONDS)

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
		combo_display.update_icon_state(streak)

/datum/martial_art/proc/smash_table(mob/living/source, mob/living/pushed_mob, obj/structure/table/table)
	SIGNAL_HANDLER
	if(smashes_tables)
		table.deconstruct(FALSE)

/**
 * Teaches the passed mob this martial art.
 *
 * Arguments
 * * mob/living/new_holder - The mob to teach this martial art to.
 *
 * Returns
 * * TRUE - The martial art was successfully taught.
 * * FALSE - The mob failed to learn the martial art, for whatever reason.
 */
/datum/martial_art/proc/teach(mob/living/new_holder)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!can_teach(new_holder) || holder == new_holder)
		return FALSE

	holder = new_holder
	if(origin != new_holder)
		RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(clear_holder))
	// locked martial arts always get inserted as the next up
	// (so if you learn two locked martial arts, and you get rid of the first, the second will slot itself in)
	if(locked_to_use && LAZYLEN(new_holder.martial_arts) >= 2)
		LAZYINSERT(new_holder.martial_arts, 2, src)
	else
		LAZYADD(new_holder.martial_arts, src)
	if(LAZYLEN(new_holder.martial_arts) >= 2)
		// newly learned martials are preferred to be the active one
		add_verb(new_holder, /mob/living/proc/verb_switch_style)
		// if the active one is locked, this will no-op, which is fine
		new_holder.switch_style(GET_ACTIVE_MARTIAL_ART(new_holder), src)
	else if(!active)
		activate_style(new_holder)
	return TRUE

/**
 * Checks if the passed mob can be taught this martial art.
 *
 * Arguments
 * * mob/living/new_holder - The mob to check
 *
 * Returns
 * * TRUE - The mob can be taught this martial art
 * * FALSE - The mob cannot be taught this martial art
 */
/datum/martial_art/proc/can_teach(mob/living/new_holder)
	return isliving(new_holder)

/**
 * Removes this martial art from the passed mob.
 *
 * Arguments
 * * mob/living/old_holder - The mob to remove this martial art from.
 */
/datum/martial_art/proc/unlearn(mob/living/old_holder)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(old_holder != holder)
		return FALSE

	if(LAZYLEN(old_holder.martial_arts) >= 2 && !QDELING(old_holder))
		old_holder.switch_style(src, GET_NEXT_MARTIAL_ART(old_holder))
	else if(active)
		deactivate_style(old_holder)
	if(origin != old_holder)
		UnregisterSignal(old_holder, COMSIG_QDELETING)
	LAZYREMOVE(old_holder.martial_arts, src)
	holder = null
	if(LAZYLEN(old_holder.martial_arts) <= 1)
		remove_verb(old_holder, /mob/living/proc/verb_switch_style)
	return TRUE

/**
 * Called when this martial art is added to a mob.
 */
/datum/martial_art/proc/activate_style(mob/living/new_holder)
	SHOULD_CALL_PARENT(TRUE)
	active = TRUE
	if(help_verb)
		add_verb(new_holder, help_verb)
	RegisterSignal(new_holder, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(unarmed_strike))
	RegisterSignal(new_holder, COMSIG_LIVING_GRAB, PROC_REF(attempt_grab))
	RegisterSignals(new_holder, list(COMSIG_LIVING_TABLE_SLAMMING, COMSIG_LIVING_TABLE_LIMB_SLAMMING), PROC_REF(smash_table))
	if(display_combos)
		if(new_holder.hud_used)
			on_hud_created(new_holder)
		else
			RegisterSignal(new_holder, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

/**
 * Called when this martial art is removed from a mob.
 */
/datum/martial_art/proc/deactivate_style(mob/living/remove_from)
	SHOULD_CALL_PARENT(TRUE)
	active = FALSE
	if(help_verb)
		remove_verb(remove_from, help_verb)
	UnregisterSignal(remove_from, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_LIVING_GRAB, COMSIG_LIVING_TABLE_SLAMMING, COMSIG_LIVING_TABLE_LIMB_SLAMMING))
	if(!isnull(combo_display))
		var/datum/hud/hud_used = remove_from.hud_used
		hud_used.infodisplay -= combo_display
		hud_used.show_hud(hud_used.hud_version)
		QDEL_NULL(combo_display)

///Gives the owner of the martial art the combo HUD.
/datum/martial_art/proc/on_hud_created(mob/source)
	SIGNAL_HANDLER
	var/datum/hud/hud_used = source.hud_used
	combo_display = new(null, hud_used)
	hud_used.infodisplay += combo_display
	hud_used.show_hud(hud_used.hud_version)

/mob/living/proc/verb_switch_style()
	set name = "Swap Style"
	set desc = "Switch to a different martial arts style."
	set category = "IC"

	var/datum/martial_art/current = GET_ACTIVE_MARTIAL_ART(src)
	var/datum/martial_art/next = GET_NEXT_MARTIAL_ART(src)

	if(current.locked_to_use)
		to_chat(src, span_warning("You can't stop practicing [current]! It's too ingrained in your muscle memory."))
		return

	switch_style(GET_ACTIVE_MARTIAL_ART(src), GET_NEXT_MARTIAL_ART(src))
	to_chat(src, span_notice("You stop practicing [current] and start practicing [next]."))

/// Deactivates the current martial art and activates the next one.
/mob/living/proc/switch_style(datum/martial_art/current_martial, datum/martial_art/next_martial)
	if(current_martial.locked_to_use)
		return
	// something's wrong if this assertion fails, but not terribly wrong that we need a stack trace
	if(!current_martial.active || next_martial.active)
		return

	current_martial.deactivate_style(src)
	next_martial.activate_style(src)
	// front of the list with ye
	LAZYREMOVE(martial_arts, next_martial)
	LAZYINSERT(martial_arts, 1, next_martial)
	// back of the list with ye
	LAZYREMOVE(martial_arts, current_martial)
	LAZYADD(martial_arts, current_martial)
