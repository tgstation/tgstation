/// Checks for RIGHT_CLICK in modifiers and runs resolve_right_click_attack if so. Returns TRUE if normal chain blocked.
/mob/living/proc/right_click_attack_chain(atom/target, list/modifiers)
	if (!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	var/secondary_result = resolve_right_click_attack(target, modifiers)

	if (secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
		return TRUE
	else if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
		CRASH("resolve_right_click_attack (probably attack_hand_secondary) did not return a SECONDARY_ATTACK_* define.")

/mob/living/carbon/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		// Only thing we can do without hands is check ourself.
		if(src == attack_target)
			check_self_for_injuries()
			return TRUE
		// .. Or bite.
		return ..()

	if(!has_active_hand()) //can't attack without a hand.
		var/obj/item/bodypart/check_arm = get_active_hand()
		if(check_arm?.bodypart_disabled)
			to_chat(src, span_warning("Your [check_arm.name] is in no condition to be used."))
			return FALSE

		to_chat(src, span_notice("You look at your arm and sigh."))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, attack_target, proximity_flag, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return
	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, attack_target, proximity_flag, modifiers)

	return ..()

	/*
	if(!right_click_attack_chain(attack_target, modifiers) && !dna?.species?.spec_unarmedattack(src, attack_target, modifiers)) //Because species like monkeys dont use attack hand
		attack_target.attack_hand(src, modifiers)
	*/

/mob/living/carbon/select_unarmed_strike(list/modifiers)
	. = ..()
	if(.)
		return

	if(combat_mode)
		// figure out a better way to do this.
		if(HAS_TRAIT(src, TRAIT_HULK))
			return GLOB.attack_styles[/datum/attack_style/unarmed/generic_damage/hulk]

		// melbert todo : needs to handle kicking
		var/obj/item/organ/internal/brain/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/attacking_bodypart = brain?.get_attacking_limb() || get_active_hand()
		return attacking_bodypart.attack_style

	return GLOB.attack_styles[/datum/attack_style/unarmed/help]

/mob/living/carbon/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_hand_secondary(src, modifiers)

/mob/living/carbon/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_hand(src, modifiers)

/// Return TRUE to cancel other attack hand effects that respect it. Modifiers is the assoc list for click info such as if it was a right click.
/atom/proc/attack_hand(mob/user, list/modifiers)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

/// When the user uses their hand on an item while holding right-click
/// Returns a SECONDARY_ATTACK_* value.
/atom/proc/attack_hand_secondary(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(isAdminGhostAI(user)) //admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user, require_adjacent_turf = TRUE)
	if(!user.can_interact_with(src, interaction_flags_atom & INTERACT_ATOM_ALLOW_USER_LOCATION))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED))
		var/ignore_flags = NONE
		if(interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED)
			ignore_flags |= IGNORE_RESTRAINTS
		if(!(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB))
			ignore_flags |= IGNORE_GRAB

		if(user.incapacitated(ignore_flags))
			return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	//Check if both user and atom are at the same location
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		SEND_SIGNAL(src, COMSIG_ATOM_UI_INTERACT, user)
		return ui_interact(user)
	return FALSE

/mob/living/RangedAttack(atom/A, modifiers)
	. = ..()
	if(.)
		return

	var/datum/attack_style/unarmed/hit_style = select_unarmed_strike(modifiers)
	if(hit_style)
		testing("[src] is attacking with [hit_style], targeting [A]. (Ranged)")
		changeNext_move(hit_style.cd * 0.8)
		hit_style.process_attack(src, null, A)
		return TRUE

/mob/living/ranged_secondary_attack(atom/atom_target, modifiers)
	. = ..()
	if(.)
		return

	var/datum/attack_style/unarmed/hit_style = select_unarmed_strike(modifiers)
	if(hit_style)
		testing("[src] is attacking with [hit_style], targeting [atom_target]. (Ranged secondary)")
		changeNext_move(hit_style.cd * 0.8)
		hit_style.process_attack(src, null, atom_target, TRUE)
		return TRUE

/mob/living/carbon/human/RangedAttack(atom/A, modifiers)
	. = ..()
	if(.)
		return

	if(isturf(A) && get_dist(src,A) <= 1)
		Move_Pulled(A)
		return TRUE

/*
	Animals & All Unspecified
*/

/mob/living/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		// Melbert todo : handle bite handling here
		if(proximity_flag)
			return handle_bite(attack_target)
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_UNARMED_ATTACK, attack_target, proximity_flag, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE

	if(ismovable(attack_target) && !isliving(attack_target))
		if(!right_click_attack_chain(attack_target, modifiers))
			resolve_unarmed_attack(attack_target, modifiers)
		return TRUE

	var/datum/attack_style/unarmed/hit_style = select_unarmed_strike(modifiers)
	if(hit_style)
		testing("[src] is attacking with [hit_style], targeting [attack_target]. (Melee)")
		changeNext_move(hit_style.cd * 0.8)
		hit_style.process_attack(src, null, attack_target)
		return TRUE
	return FALSE

/mob/living/proc/select_unarmed_strike(list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		. ||= default_disarm_attack_style

	if(combat_mode)
		. ||= default_harm_attack_style

	return .

/mob/living/proc/handle_bite(atom/attack_target)
	var/datum/attack_style/unarmed/bite_style = GLOB.attack_styles[/datum/attack_style/unarmed/generic_damage/bite]
	return bite_style?.process_attack(src, null, attack_target)

/mob/living/silicon/handle_bite(atom/attack_target)
	return // ??

/mob/living/carbon/handle_bite(atom/attack_target)
	if(get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	return ..()

/mob/living/carbon/human/handle_bite(atom/attack_target)
	if(!HAS_TRAIT(src, TRAIT_HUMAN_BITER))
		return FALSE
	return ..()

/**
 * Called when the unarmed attack hasn't been stopped by the LIVING_UNARMED_ATTACK_BLOCKED macro or the right_click_attack_chain proc.
 * This will call an attack proc that can vary from mob type to mob type on the target.
 */
/mob/living/proc/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_animal(src, modifiers)

/**
 * Called when an unarmed attack performed with right click hasn't been stopped by the LIVING_UNARMED_ATTACK_BLOCKED macro.
 * This will call a secondary attack proc that can vary from mob type to mob type on the target.
 * Sometimes, a target is interacted differently when right_clicked, in that case the secondary attack proc should return
 * a SECONDARY_ATTACK_* value that's not SECONDARY_ATTACK_CALL_NORMAL.
 * Otherwise, it should just return SECONDARY_ATTACK_CALL_NORMAL. Failure to do so will result in an exception (runtime error).
 */
/mob/living/proc/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_animal_secondary(src, modifiers)

/atom/proc/attack_animal(mob/user, list/modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)

/**
 * Called when a simple animal or basic mob right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_animal_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

///When a basic mob attacks something, either by AI or user.
/atom/proc/attack_basic_mob(mob/user, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_BASIC_MOB, user)
	return handle_basic_attack(user, modifiers) //return value of attack animal, this is how much damage was dealt to the attacked thing

///This exists so stuff can override the default call of attack_animal for attack_basic_mob
///Remove this when simple animals are removed and everything can be handled on attack basic mob.
/atom/proc/handle_basic_attack(user, modifiers)
	return attack_animal(user, modifiers)

/**
 * This is called when a monkey that is NOT an advanced tool user clicks on this atom with an empty hand in melee range.
 * It is also called by [xenomorphs][/mob/living/carbon/alien] under similar conditions.
 *
 * In most cases, it may end up redirecting to normal human attack hand.
 *
 * However if the monkey is right clicking, it will not call this, but call attack_hand_secondary instead.
 *
 * Return TRUE on successful handling and FALSE on no handling done / handling failed.
 */
/atom/proc/attack_paw(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE

/mob/living/carbon/alien/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_alien(src, modifiers)

/mob/living/carbon/alien/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_alien_secondary(src, modifiers)

/**
 * This is called when an xenomorphs ([/mob/living/carbon/alien]) clicks on this atom with an empty hand in melee range.
 *
 * By default it ends up doing identical behavior to monkeys (attack_paw)
 *
 */
/atom/proc/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	return attack_paw(user, modifiers)

/**
 * Called when an alien right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_alien_secondary(mob/living/carbon/alien/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

// Babby aliens
/mob/living/carbon/alien/larva/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_larva(src, modifiers)

/mob/living/carbon/alien/larva/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_larva_secondary(src, modifiers)

/atom/proc/attack_larva(mob/user, list/modifiers)
	return

/**
 * Called when an alien larva right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_larva_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/resolve_unarmed_attack(atom/attack_target, proximity_flag, list/modifiers)
	if(isturf(attack_target))
		return ..()
	attack_target.attack_slime(src, modifiers)

/mob/living/simple_animal/slime/resolve_right_click_attack(atom/target, list/modifiers)
	if(isturf(target))
		return ..()
	return target.attack_slime_secondary(src, modifiers)

/atom/proc/attack_slime(mob/user, list/modifiers)
	return

/**
 * Called when a slime mob right clicks an atom (that is not a turf).
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_slime_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/*
	Drones
*/

/mob/living/simple_animal/drone/resolve_unarmed_attack(atom/attack_target, proximity_flag, list/modifiers)
	attack_target.attack_drone(src, modifiers)

/mob/living/simple_animal/drone/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_drone_secondary(src, modifiers)

/// Defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.
/atom/proc/attack_drone(mob/living/simple_animal/drone/user, list/modifiers)
	return attack_hand(user, modifiers)

/**
 * Called when a maintenance drone right clicks an atom.
 * Defaults to attack_hand_secondary.
 * When overriding it, remember that it ought to return a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_drone_secondary(mob/living/simple_animal/drone/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_pai(src, modifiers)

/mob/living/silicon/pai/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_pai_secondary(src, modifiers)

/atom/proc/attack_pai(mob/user, list/modifiers)
	return

/**
 * Called when a pAI right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_pai_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/*
	Simple animals
*/

/mob/living/simple_animal/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(dextrous && (isitem(attack_target) || !combat_mode))
		attack_target.attack_hand(src, modifiers)
		update_held_items()
	else
		return ..()

/mob/living/simple_animal/resolve_right_click_attack(atom/target, list/modifiers)
	if(dextrous && (isitem(target) || !combat_mode))
		. = target.attack_hand_secondary(src, modifiers)
		update_held_items()
	else
		return ..()

/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	GiveTarget(attack_target)
	if(dextrous && (isitem(attack_target) || !combat_mode))
		return ..()
	else
		AttackingTarget(attack_target)

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
