/**
 * spirit holding component; for items to have spirits inside of them for "advice"
 *
 * Used for the possessed blade and fantasy affixes
 */
/datum/component/spirit_holding
	///bool on if this component is currently polling for observers to inhabit the item
	var/attempting_awakening = FALSE
	///mob contained in the item.
	var/mob/living/simple_animal/shade/bound_spirit

/datum/component/spirit_holding/Initialize()
	if(!ismovable(parent)) //you may apply this to mobs, i take no responsibility for how that works out
		return COMPONENT_INCOMPATIBLE

/datum/component/spirit_holding/Destroy(force, silent)
	. = ..()
	if(bound_spirit)
		QDEL_NULL(bound_spirit)

/datum/component/spirit_holding/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_destroy))

/datum/component/spirit_holding/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_ATTACK_SELF, COMSIG_PARENT_QDELETING))

///signal fired on examining the parent
/datum/component/spirit_holding/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!bound_spirit)
		examine_list += span_notice("[parent] sleeps. Use [parent] in your hands to attempt to awaken it.")
		return
	examine_list += span_notice("[parent] is alive.")

///signal fired on self attacking parent
/datum/component/spirit_holding/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_spirit_awaken), user)

/**
 * attempt_spirit_awaken: called from on_attack_self, polls ghosts to possess the item in the form
 * of a mob sitting inside the item itself
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/spirit_holding/proc/attempt_spirit_awaken(mob/awakener)
	if(attempting_awakening)
		to_chat(awakener, span_warning("You are already trying to awaken [parent]!"))
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(awakener, span_warning("Anomalous otherworldly energies block you from awakening [parent]!"))
		return

	attempting_awakening = TRUE
	to_chat(awakener, span_notice("You attempt to wake the spirit of [parent]..."))

	var/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the spirit of [awakener.real_name]'s blade?", ROLE_PAI, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)
	if(!LAZYLEN(candidates))
		to_chat(awakener, span_warning("[parent] is dormant. Maybe you can try again later."))
		attempting_awakening = FALSE
		return

	//Immediately unregister to prevent making a new spirit
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)

	var/mob/dead/observer/chosen_spirit = pick(candidates)
	bound_spirit = new(parent)
	bound_spirit.ckey = chosen_spirit.ckey
	bound_spirit.fully_replace_character_name(null, "The spirit of [parent]")
	bound_spirit.status_flags |= GODMODE
	bound_spirit.copy_languages(awakener, LANGUAGE_MASTER) //Make sure the sword can understand and communicate with the awakener.
	bound_spirit.update_atom_languages()
	bound_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue

	//Add new signals for parent and stop attempting to awaken
	RegisterSignal(parent, COMSIG_ATOM_RELAYMOVE, PROC_REF(block_buckle_message))
	RegisterSignal(parent, COMSIG_BIBLE_SMACKED, PROC_REF(on_bible_smacked))

	// Now that all of the important things are in place for our spirit, it's time for them to choose their name.
	var/valid_input_name = custom_name(awakener)
	if(valid_input_name)
		bound_spirit.fully_replace_character_name(null, "The spirit of [valid_input_name]")

	attempting_awakening = FALSE

/**
 * custom_name : Simply sends a tgui input text box to the blade asking what name they want to be called, and retries it if the input is invalid.
 *
 * Arguments:
 * * awakener: user who interacted with the blade
 */
/datum/component/spirit_holding/proc/custom_name(mob/awakener)
	var/chosen_name = sanitize_name(tgui_input_text(bound_spirit, "What are you named?", "Spectral Nomenclature", max_length = MAX_NAME_LEN))
	if(!chosen_name) // with the way that sanitize_name works, it'll actually send the error message to the awakener as well.
		to_chat(awakener, span_warning("Your blade did not select a valid name! Please wait as they try again.")) // more verbose than what sanitize_name might pass in it's error message
		return custom_name(awakener)
	return chosen_name

///signal fired from a mob moving inside the parent
/datum/component/spirit_holding/proc/block_buckle_message(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	return COMSIG_BLOCK_RELAYMOVE

/datum/component/spirit_holding/proc/on_bible_smacked(datum/source, mob/living/user, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_exorcism), user)

/**
 * attempt_exorcism: called from on_bible_smacked, takes time and if successful
 * resets the item to a pre-possessed state
 *
 * Arguments:
 * * exorcist: user who is attempting to remove the spirit
 */
/datum/component/spirit_holding/proc/attempt_exorcism(mob/exorcist)
	var/atom/movable/exorcised_movable = parent
	to_chat(exorcist, span_notice("You begin to exorcise [parent]..."))
	playsound(parent, 'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
	if(!do_after(exorcist, 4 SECONDS, target = exorcised_movable))
		return
	playsound(parent, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	UnregisterSignal(exorcised_movable, list(COMSIG_ATOM_RELAYMOVE, COMSIG_BIBLE_SMACKED))
	RegisterSignal(exorcised_movable, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	to_chat(bound_spirit, span_userdanger("You were exorcised!"))
	QDEL_NULL(bound_spirit)
	exorcised_movable.name = initial(exorcised_movable.name)
	exorcist.visible_message(span_notice("[exorcist] exorcises [exorcised_movable]!"), \
						span_notice("You successfully exorcise [exorcised_movable]!"))
	return COMSIG_END_BIBLE_CHAIN

///signal fired from parent being destroyed
/datum/component/spirit_holding/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	to_chat(bound_spirit, span_userdanger("You were destroyed!"))
	QDEL_NULL(bound_spirit)
